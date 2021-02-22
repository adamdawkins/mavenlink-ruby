# frozen_string_literal: true

module Mavenlink
  class Story < APIResource
    include Mavenlink::APIOperations::Request

    OBJECT_NAME = "story"
  end
end
