# frozen_string_literal: true

require "httparty"

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

require "mavenlink/list_object"
require "mavenlink/util"

require "mavenlink/api_operations/request"
require "mavenlink/api_resource"
require "mavenlink/resources"
