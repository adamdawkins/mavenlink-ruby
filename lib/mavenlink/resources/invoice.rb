# frozen_string_literal: true

module Mavenlink
  class Invoice < APIResource
    include Mavenlink::APIOperations::Request


    OBJECT_NAME = "invoice"
  end
end
