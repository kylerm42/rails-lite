require 'json'
require 'webrick'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    cookie_json = req.cookies.select do |cookie|
      cookie.name == "_rails_lite_app"
    end.first
    @session = (cookie_json ? JSON.parse(cookie_json.value) : {})
  end

  def [](key)
    @session[key]
  end

  def []=(key, val)
    @session[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    cookie = WEBrick::Cookie.new("_rails_lite_app", @session.to_json)
    res.cookies << cookie
  end
end
