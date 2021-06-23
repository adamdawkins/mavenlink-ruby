module Mavenlink
  class MavenlinkObject
    include Enumerable

    @@permanent_attributes = Set.new([:id]) # rubocop:disable Style/ClassVars
    RESERVED_FIELD_NAMES = [
      :class
    ].freeze

    def initialize(id = nil, opts = {})
      @values = {}
      @opts = opts
      @retrieve_params = opts
      @values[:id] = id if id.present?

      @original_values = {}
      @values = {}
      # This really belongs in APIResource, but not putting it there allows us
      # to have a unified inspect method
      @unsaved_values = Set.new
      @transient_values = Set.new
      @values[:id] = id if id

      update_attributes(@values)
    end

    def self.construct_from(values, opts = {})
      values = Util.symbolize_names(values)

      # work around protected #initialize_from for now
      new(values[:id]).send(:initialize_from, values, opts)
    end

    # Sets all keys within the MavenlinkObject as unsaved so that they will be
    # included with an update when #serialize_params is called. This method is
    # also recursive, so any MavenlinkObjects contained as values or which are
    # values in a tenant array are also marked as dirty.
    def dirty!
      @unsaved_values = Set.new(@values.keys)
      @values.each_value do |v|
        dirty_value!(v)
      end
    end

    protected def update_attributes(values)
      values.each do |k, v|
        add_accessor(k, v) unless metaclass.method_defined? k.to_sym
      end
    end

    # Mass assigns attributes on the model.
    #
    # This is a version of +update_attributes+ that takes some extra options
    # for internal use.
    #
    # ==== Attributes
    #
    # * +values+ - Hash of values to use to update the current attributes of
    #   the object. If you are on ruby 2.7 or higher make sure to wrap in curly
    #   braces to be ruby 3 compatible.
    # * +opts+ - Options for +StripeObject+ like an API key that will be reused
    #   on subsequent API calls.
    #
    # ==== Options
    #
    # * +:dirty+ - Whether values should be initiated as "dirty" (unsaved) and
    #   which applies only to new StripeObjects being initiated under this
    #   StripeObject. Defaults to true.
    def update_attributes(values, opts = {}, dirty: true)
      values.each do |k, v|
        add_accessors([k], values) unless metaclass.method_defined?(k.to_sym)
        @values[k] = Util.convert_to_mavenlink_object(v, opts)
        dirty_value!(@values[k]) if dirty
        @unsaved_values.add(k)
      end
    end

    protected def metaclass
      class << self; self; end
    end

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

    protected def add_accessors(keys, values)
      metaclass.instance_eval do
        keys.each do |k|
          next if RESERVED_FIELD_NAMES.include?(k)
          next if @@permanent_attributes.include?(k)

          if k == :method
            # Object#method is a built-in Ruby method that accepts a symbol
            # and returns the corresponding Method object. Because the API may
            # also use `method` as a field name, we check the arity of *args
            # to decide whether to act as a getter or call the parent method.
            define_method(k) { |*args| args.empty? ? @values[k] : super(*args) }
          else
            define_method(k) { @values[k] }
          end

          define_method(:"#{k}=") do |v|
            if v == ""
              raise ArgumentError, "You cannot set #{k} to an empty string. " \
                "We interpret empty strings as nil in requests. " \
                "You may set (object).#{k} = nil to delete the property."
            end
            @values[k] = Util.convert_to_stripe_object(v, @opts)
            dirty_value!(@values[k])
            @unsaved_values.add(k)
          end

          if [FalseClass, TrueClass].include?(values[k].class)
            define_method(:"#{k}?") { @values[k] }
          end
        end
      end
    end

    protected def remove_accessors(keys)
      metaclass.instance_eval do
        keys.each do |k|
          next if RESERVED_FIELD_NAMES.include?(k)
          next if @@permanent_attributes.include?(k)

          # Remove methods for the accessor's reader and writer.
          [k, :"#{k}=", :"#{k}?"].each do |method_name|
            next unless method_defined?(method_name)

            begin
              remove_method(method_name)
            rescue NameError
              # In some cases there can be a method that's detected with
              # `method_defined?`, but which cannot be removed with
              # `remove_method`, even though it's on the same class. The only
              # case so far that we've noticed this is when a class is
              # reopened for monkey patching:
              #
              #     https://github.com/stripe/stripe-ruby/issues/749
              #
              # Here we swallow that error and issue a warning so at least
              # the program doesn't crash.
              warn("WARNING: Unable to remove method `#{method_name}`; " \
                "if custom, please consider renaming to a name that doesn't " \
                "collide with an API property name.")
            end
          end
        end
      end
    end

    private def dirty_value!(value)
      case value
      when Array
        value.map { |v| dirty_value!(v) }
      when MavenlinkObject
        value.dirty!
      end
    end

    # Produces a deep copy of the given object including support for arrays,
    # hashes, and MavenlinkObjects
    private_class_method def self.deep_copy(obj)
      case obj
      when Array
        obj.map { |e| deep_copy(e) }
      when Hash
        obj.each_with_object({}) do |(k, v), copy|
          copy[k] = deep_copy(v)
          copy
        end
      when MavenlinkObject
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
