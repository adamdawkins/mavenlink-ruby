# frozen_string_literal: true

require "httparty"
require "active_support"
require "active_support/core_ext/object"
require "active_support/core_ext/string/inflections"

module Mavenlink
  @api_version = "v1"
  @api_base = "https://api.mavenlink.com/api/#{@api_version}"

  def self.api_key=(key)
    @api_key = key
  end

  def self.api_key
    @api_key
  end

  def self.api_version
    @api_version
  end

  def self.api_base
    @api_base
  end
end

require "mavenlink/list"
require "mavenlink/object_types"
require "mavenlink/util"

require "mavenlink/api_operations/request"
require "mavenlink/mavenlink_object"
require "mavenlink/api_resource"
require "mavenlink/resources"
