# frozen_string_literal: true

module Mavenlink
  module APIOperations
    module Request
      module ClassMethods
        def get(path, params = {})
          api_base = Mavenlink.api_base
          api_key = Mavenlink.api_key
          options = {
            query: params,
            headers: {
              Authorization: "Bearer #{api_key}",
            },
          }
          HTTParty.get("#{api_base}#{path}", options)
        end

        def post(path, params = {})
          api_base = Mavenlink.api_base
          api_key = Mavenlink.api_key
          options = {
            body: params,
            headers: {
              Authorization: "Bearer #{api_key}",
              type: "application/json",
            },
          }
          HTTParty.post("#{api_base}#{path}", options)
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      protected def get(url, params = {})
        self.class.get(url, params)
      end
    end
  end
end
