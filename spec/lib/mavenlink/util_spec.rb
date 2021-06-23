# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Util do
  describe ".flatten_params" do
    it "should merge arrays into a comma separated list" do
      expect(Util.flatten_params({include: ["time_entries", "fixed_fee_items"]})).to eq({include: "time_entries,fixed_fee_items"})
    end
  end

  describe ".results" do
    let(:response) do
      {"count" => 1,
       "results" => [{"key" => "invoices", "id" => "1"}],
       "invoices" => {
         "1" => {
           "id" => "1",
           "balance_in_cents" => 15_000
         }
       }}
    end
    it "returns the objects in the results" do
      expect(Util.results(response)).to eq [
        {
          "object" => "invoice",
          "id" => "1",
          "balance_in_cents" => 15_000
        }
      ]
    end

    context "the object has child objects" do
      let(:response) do
        {"count" => 1,
         "results" => [{"key" => "invoices", "id" => "1"}],
         "invoices" => {
           "1" => {
             "object" => "invoice",
             "id" => "1",
             "balance_in_cents" => 15_000,
             "time_entry_ids" => ["1", "2"],
             "fixed_fee_item_ids" => ["1", "2"]
           }
         },
         "time_entries" => {
           "1" => {
             "object" => "time_entry",
             "id" => "1",
             "rate_in_cents" => 14_000,
             "time_in_minutes" => 10
           },
           "2" => {
             "object" => "time_entry",
             "id" => "2",
             "rate_in_cents" => 14_000,
             "time_in_minutes" => 20
           }
         },
         "fixed_fee_items" => {
           "1" => {
             "object" => "fixed_fee_item",
             "id" => "1",
             "amount_in_cents" => 40_000
           },
           "2" => {
             "object" => "fixed_fee_item",
             "id" => "2",
             "amount_in_cents" => 40_000
           }
         }}
      end

      it "adds the child objects as keys in the object" do
        expect(Util.results(response)).to eq [
          {"id" => "1",
           "object" => "invoice",
           "balance_in_cents" => 15_000,
           "time_entries" => [
             {"object" => "time_entry", "id" => "1", "rate_in_cents" => 14_000, "time_in_minutes" => 10},
             {"object" => "time_entry", "id" => "2", "rate_in_cents" => 14_000, "time_in_minutes" => 20}
           ],
           "fixed_fee_items" => [
             {"object" => "fixed_fee_item", "id" => "1", "amount_in_cents" => 40_000},
             {"object" => "fixed_fee_item", "id" => "2", "amount_in_cents" => 40_000}
           ]}
        ]
      end
    end
  end
end
