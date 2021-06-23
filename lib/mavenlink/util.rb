# frozen_string_literal: true

class Util
  # Converts a hash of fields or an array of hashes into a +MavenlinkgObject+ or
  # array of +MavenlinkgObject+s. These new objects will be created as a concrete
  # type as dictated by their `object` field (e.g. an `object` value of
  # `charge` would create an instance of +Charge+), but if `object` is not
  # present or of an unknown type, the newly created instance will fall back
  # to being a +MavenlinkgObject+.
  #
  # ==== Attributes
  #
  # * +data+ - Hash of fields and values to be converted into a MavenlinkgObject.
  # * +opts+ - Options for +MavenlinkgObject+ like an API key that will be reused
  #   on subsequent API calls.
  def self.convert_to_mavenlink_object(data, opts = {})
    case data
    when Array
      data.map { |i| convert_to_mavenlink_object(i, opts) }
    when Hash
      object_classes.fetch(data["object"], Mavenlink::MavenlinkObject).construct_from(data, opts)
    else
      data
    end
  end

  def self.object_classes
    @object_classes ||= Mavenlink::ObjectTypes.object_names_to_classes
  end

  def self.results(response)
    if response["errors"].present?
      response["errors"].each do |error|
        throw StandardError.new("[#{error["type"]}] #{error["message"]}")
      end
    end

    response["results"].map do |result|
      key = result["key"]
      id = result["id"]
      object = response[key][id]
      object["object"] = key.singularize
      object.keys.map do |object_key|
        if object_key.match? /_ids$/
          object = add_children_to_object(object_key, object, response)
        end
      end

      object
    end
  end

  def self.add_children_to_object(key, object, response)
    child_ids = object[key]
    object.delete key

    resource_name = key.gsub(/_ids$/, "").pluralize

    objects = response[resource_name]

    return object if objects.nil?

    resource_object_name = resource_name.singularize

    children = []

    child_ids.each do |id|
      child_object = objects[id]
      child_object["object"] = resource_object_name
      children << child_object
    end

    object[resource_name] = children
    object
  end

  def self.stringify_keys(hash)
    new_hash = {}
    return new_hash unless hash.is_a? Hash

    hash.each do |k, v|
      new_hash[k.to_s] = v
    end

    new_hash
  end

  def self.flatten_params(params)
    flattened_params = {}
    params.each do |key, value|
      # Flatten array params into a comma-separated string as per the Mavenlink API,
      # e.g. /v1/invoices/123?include=time_entries,expenses
      flattened_params[key] = if value.is_a? Array
        value.join(",")
      else
        value
      end
    end

    flattened_params
  end

  def self.symbolize_names(object)
    case object
    when Hash
      new_hash = {}
      object.each do |key, value|
        key = (begin
          key.to_sym
        rescue
          key
        end) || key
        new_hash[key] = symbolize_names(value)
      end
      new_hash
    when Array
      object.map { |value| symbolize_names(value) }
    else
      object
    end
  end
end
