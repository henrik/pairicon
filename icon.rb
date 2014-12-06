require "open-uri"
require "json"

class Icon
  USER_AGENT = "pairicon.herokuapp.com"
  GITHUB_TOKEN = ENV["GITHUB_TOKEN"]
  CLOUDINARY_AUTH = {
    api_key:    ENV["CLOUDINARY_API_KEY"],
    api_secret: ENV["CLOUDINARY_API_SECRET"],
    cloud_name: ENV["CLOUDINARY_CLOUD_NAME"],
  }

  # Have been manually uploaded and assigned this name.
  DEFAULT_IMAGE_ID = "_pairicon_default"
  EMPTY_IMAGE_ID = "_pairicon_empty"

  # FIXME: Can there be non-square icons? Probably look bad.
  # FIXME: Bigger than 80 plz?
  SIDE = 80
  POSITIONS = {
    2 => [[0, 0], [60, 60]],
    3 => [[0, 0], [80, 0], [40, 80]],
    4 => [[0, 0], [80, 0], [0, 80], [80, 80]]
  }

  def initialize(*names)
    @names = names
  end

  def url
    positions = POSITIONS[@names.length]

    avatars = @names.zip(positions).map { |name, (x, y)|
      "l_#{avatar_id name},g_north_west,x_#{x},y_#{y},w_#{SIDE},h_#{SIDE},c_fit/"
    }

    # The empty image is just a Cloudinary formality; all we want is the avatar overlays.
    "http://res.cloudinary.com/pairicon/image/upload/c_scale,w_1,h_1,g_center/" + avatars.join + EMPTY_IMAGE_ID
  end

  private

  def avatar_id(name)
    name = name.gsub(/\W/, "")  # Avoid injections.
    url = "https://api.github.com/users/#{name}?access_token=#{GITHUB_TOKEN}"
    json = open(url, "User-Agent" => USER_AGENT).read
    data = JSON.parse(json)
    url = data.fetch("avatar_url")

    result = Cloudinary::Uploader.upload(url,
      public_id: name,
      # TODO: Store upload times in e.g. Redis, set these to false sometimes, for speed.
      invalidate: true,  # Invalidate on CDN.
      overwrite: true,   # If same public_id exists.
      **CLOUDINARY_AUTH
    )

    # Should be same as `name`, but this helps validate that upload succeeded.
    result.fetch("public_id")
  rescue OpenURI::HTTPError => e
    raise unless e.message.include?("404 Not Found")
    DEFAULT_IMAGE_ID
  end
end
