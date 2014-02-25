require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    @params ||= route_params
    @params.deep_merge(parse_www_encoded_form(req.query_string)) unless req.query_string.nil?
    @params.deep_merge(parse_www_encoded_form(req.body)) unless req.body.nil?
    p @params
  end

  def [](key)
  end

  def permit(*keys)
  end

  def require(key)
  end

  def permitted?(key)
  end

  def to_s
    @params.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    param_arr = URI.decode_www_form(www_encoded_form)
    @params = {}
    param_arr.each do |pair|
      keys = parse_key(pair.first)

      hash_val = pair.last
      keys.reverse.each do |key|
        hash_val = { key => hash_val }
      end
      @params.deep_merge(hash_val)
    end
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end

class Hash
  def deep_merge(new_hash)
    new_hash.each do |key, val|
      if self[key].is_a?(Hash) && val.is_a?(Hash)
        self[key] = self[key].deep_merge(val)
      else
        self[key] = val
      end
    end

    self
  end
end
