# frozen_string_literal: true

class Util
  def self.results(response)
    pp response
    response["results"].map do |result|
      key = result["key"]
      id = result["id"]
      response[key][id]
    end
  end

  def self.stringify_keys(hash)
    new_hash = {}
    return new_hash unless hash.is_a? Hash

    hash.each do |k, v|
      new_hash[k.to_s] = v
    end

    new_hash
  end
end
