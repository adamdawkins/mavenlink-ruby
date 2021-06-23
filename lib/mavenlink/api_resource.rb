# frozen_string_literal: true

module Mavenlink
  class APIResource < MavenlinkObject
    include Mavenlink::APIOperations::Request

    attr_reader :retrieve_opts
    attr_reader :values

    def id
      @values[:id]
    end

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

    def self.retrieve(id, opts = {})
      instance = new(id, opts)
      instance.refresh
    end

    def self.list(params = {}, options = {})
      response = get(resource_url, params)
      List.new(self, response, options, params)
    end

    def refresh
      response = get(resource_url, Util.flatten_params(@retrieve_params))
      data = Util.results(response).first
      initialize_from(data, @retrieve_params)
    end

    def self.construct_from(values, opts = {})
      values = Util.symbolize_names(values)

      # work around protected #initialize_from for now
      new(values[:id]).send(:initialize_from, values, opts)
    end

    def resource_url
      "#{self.class.resource_url}/#{CGI.escape(id)}"
    end

    protected def add_accessor(key, value)
      metaclass.instance_eval do
        define_method(key) { value }
      end
    end

    # Re-initializes the object based on a hash of values (usually one that's
    # come back from an API call). Adds or removes value accessors as necessary
    # and updates the state of internal data.
    #
    # Protected on purpose! Please do not expose.
    #
    # ==== Options
    #
    # * +:values:+ Hash used to update accessors and values.
    # * +:opts:+ Options for StripeObject like an API key.
    # * +:partial:+ Indicates that the re-initialization should not attempt to
    #   remove accessors.
    protected def initialize_from(values, opts, partial = false)
      @opts = opts

      # the `#send` is here so that we can keep this method private
      @original_values = self.class.send(:deep_copy, values)

      removed = partial ? Set.new : Set.new(@values.keys - values.keys)
      added = Set.new(values.keys - @values.keys)

      # Wipe old state before setting new.  This is useful for e.g. updating a
      # customer, where there is no persistent card parameter.  Mark those
      # values which don't persist as transient

      remove_accessors(removed)
      add_accessors(added, values)

      removed.each do |k|
        @values.delete(k)
        @transient_values.add(k)
        @unsaved_values.delete(k)
      end

      update_attributes(values, opts, dirty: false)
      values.each_key do |k|
        @transient_values.delete(k)
        @unsaved_values.delete(k)
      end

      self
    end
    # Produces a deep copy of the given object including support for arrays,
    # hashes, and Mavenlink Resources
    private_class_method def self.deep_copy(obj)
      case obj
      when Array
        obj.map { |e| deep_copy(e) }
      when Hash
        obj.each_with_object({}) do |(k, v), copy|
          copy[k] = deep_copy(v)
          copy
        end
      when self
        obj.class.construct_from(
          deep_copy(obj.instance_variable_get(:@values)),
          obj.instance_variable_get(:@opts).select do |k, _v|
            Util::OPTS_COPYABLE.include?(k)
          end
        )
      else
        obj
      end
    end
  end
end
