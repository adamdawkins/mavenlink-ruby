# frozen_string_literal: true

module Mavenlink
  class APIResource
    include Mavenlink::APIOperations::Request

    attr_reader :values

    def self.resource_url
      if self == APIResource
        raise NotImplementedError,
              "APIResource is an abstract class, you should before actions "\
              "on its subclasses (Workspace, Invoice, etc.)"
      end

      "/#{plural_name}"
    end

    def self.plural_name
      if self::OBJECT_NAME.downcase == "story"
        "stories"
      else
        "#{self::OBJECT_NAME.downcase}s"
      end
    end

    def self.retrieve(id)
      instance = new(id: id)
      instance.refresh
    end

    def self.list(params = {}, options = {})
      response = get(resource_url, params)
      List.new(self, response, options, params)
    end

    def refresh
      response = get(resource_url)
      data = Util.results(response).first
      self.class.new(data)
    end

    def initialize(data)
      @values = data

      update_attributes(@values)
    end

    def resource_url
      unless (id = self.id)
        raise InvalidRequestError.new(
          "Could not determine which URL to request: #{self.class} instance " \
          "has invalid ID: #{id.inspect}",
          "id"
        )
      end
      "#{self.class.resource_url}/#{CGI.escape(id)}"
    end

    protected def metaclass
      class << self; self; end
    end

    protected def update_attributes(values)
      values.each do |k, v|
        add_accessor(k, v) unless metaclass.method_defined? k.to_sym
      end
    end

    protected def add_accessor(key, value)
      metaclass.instance_eval do
        define_method(key) { value }
      end
    end
  end
end
