# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Mavenlink::MavenlinkObject do
  describe "#to_hash" do
    it "skips calling to_hash on nil" do
      module NilWithToHash
        def to_hash
          raise "Can't call to_hash on nil"
        end
      end
      ::NilClass.include NilWithToHash

      hash_with_nil = {id: 3, foo: nil}
      obj = Mavenlink::MavenlinkObject.construct_from(hash_with_nil)
      expect(obj.to_hash).to eq({id: 3, foo: nil})
    ensure
      ::NilClass.send(:undef_method, :to_hash)
    end

    it "recursively calls to_hash on its values" do
      # deep nested hash (when contained in an array) or MavenlinkObject
      nested_hash = {id: 7, foo: "bar"}
      nested = Mavenlink::MavenlinkObject.construct_from(nested_hash)

      obj = Mavenlink::MavenlinkObject.construct_from(id: 1,
                                                      # simple hash that contains a MavenlinkObject to help us test deep
                                                      # recursion
                                                      nested: {object: "list", data: [nested]},
                                                      list: [nested])

      expected_hash = {
        id: 1,
        nested: {object: "list", data: [nested_hash]},
        list: [nested_hash]
      }
      expect(obj.to_hash).to eq expected_hash
    end
  end
end
