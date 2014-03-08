class Flash
  attr_accessor :now

  def initialize(req)
    @req = req
    get_values
  end

  def []=(name, value)
    @flash[name] = value
  end

  def [](name)
    ( @now[name] || [] ) + ( @flash[name] || [] )
  end

  def reset
    @now = @flash
    @flash = {}
    set_cookie
  end

  def get_values
    flash_json = @req.cookies.select do |cookie|
      cookie.name == "_rails_lite_flash"
    end.first

    if flash_json
      @flash = flash_json[flash] || {}
      @now = flash_json[now] || {}
    else
      @flash = {}
      @now = {}
    end
  end

  def set_cookie
    flash = WEBrick::Cookie.new("_rails_lite_flash", self.to_json)
    res.cookies << flash
  end
end