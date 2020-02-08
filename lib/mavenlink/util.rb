# frozen_string_literal: true

class Util
  def self.results(response)
    response["results"].map do |result|
      key = result["key"]
      id = result["id"]

      response[key][id]
    end
  end
end
