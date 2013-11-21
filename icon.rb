require "open-uri"
require "json"

class Icon
  def initialize(*names)
    @names = names
  end

  def url
    gid1 = gravatar_id(@names[0])
    gid2 = gravatar_id(@names[1])
    "http://res.cloudinary.com/pairicon/image/upload/c_scale,w_140,h_140,g_center/l_gravatar:#{gid1}.jpg,g_north_west,x_0,y_0/l_gravatar:#{gid2}.jpg,g_north_west,x_60,y_60/github_egc4ey.png"
  end

  private

  def gravatar_id(name)
    JSON.parse(open("https://api.github.com/users/#{name}").read)["gravatar_id"]
  rescue OpenURI::HTTPError => e
    if e.message.include?("404 Not Found")
      "fakehash"
    else
      raise
    end
  end
end
