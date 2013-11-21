require "open-uri"
require "json"

class Icon
  USER_AGENT = "pairicon.herokuapp.com"
  GITHUB_TOKEN = ENV["GITHUB_TOKEN"]

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

    gravatars = @names.zip(positions).map { |name, (x, y)|
      "l_gravatar:#{gravatar_id name}.jpg,g_north_west,x_#{x},y_#{y}/"
    }

    "http://res.cloudinary.com/pairicon/image/upload/c_scale,w_1,h_1,g_center/" +
      gravatars.join + "white_ywdcmp.png"
  end

  private

  def gravatar_id(name)
    url = "https://api.github.com/users/#{name}?access_token=#{GITHUB_TOKEN}"
    json = open(url, "User-Agent" => USER_AGENT).read
    data = JSON.parse(json)
    data["gravatar_id"]
  rescue OpenURI::HTTPError => e
    if e.message.include?("404 Not Found")
      "fakehash"
    else
      raise
    end
  end
end
