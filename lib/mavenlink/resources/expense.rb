module Mavenlink
  class Expense < APIResource
    include Mavenlink::APIOperations::Request

    OBJECT_NAME = "expense"
  end
end
