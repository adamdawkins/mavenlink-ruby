module Mavenlink
  class FixedFeeItem < APIResource
    include Mavenlink::APIOperations::Request

    OBJECT_NAME = "fixed_fee_item"
  end
end
