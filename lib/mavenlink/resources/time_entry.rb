module Mavenlink
  class TimeEntry < APIResource
    include Mavenlink::APIOperations::Request

    OBJECT_NAME = "time_entry"
  end
end
