# frozen_string_literal: true

module Mavenlink
  class Invoice < APIResource
    include Mavenlink::APIOperations::Request


    OBJECT_NAME = "invoice"

    def self.create(params = {})
      response = post(resource_url, params)
      data = Util.results(response).first
      self.class.new(data)
    end
  end
end
