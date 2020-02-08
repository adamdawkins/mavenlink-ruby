# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Mavenlink::List do
  let(:response) do
    {
      "count" => 3,
      "results" => [
        { "key" => "invoices", "id" => "1" },
        { "key" => "invoices", "id" => "2" },
        { "key" => "invoices", "id" => "3" },
      ],
      "invoices" => {
        "1" => { "id" => 1 },
        "2" => { "id" => 2 },
        "3" => { "id" => 3 },
      },
      "meta" => {
        "count" => 3,
        "page_count" => 1,
        "page_number" => 1,
      },
    }
  end

  class MockResource
    attr_reader :id
    def initialize(args)
      @id = args[:id]
    end
  end

  it "should provide #count via Enumerable" do
    list = Mavenlink::List.new(MockResource, response)

    expect(list.count).to eq 3
  end

  it "should provide #each" do
    list = Mavenlink::List.new(MockResource, response)
    expect(list.each.to_a.count).to eq 3
    expect(list.each.to_a.first).to be_a MockResource
  end

  describe "#auto_paging_each" do
    before do
      stub_request(:get, "#{Mavenlink.api_base}/things")
        .with(query: { page: 2 })
        .to_return(
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.generate(
            count: 5,
            results: [
              { key: "things", id: "3" },
              { key: "things", id: "4" },
            ],
            things: {
              "3": { id: 3 },
              "4": { id: 4 },
            },
            meta: {
              count: 5,
              page_count: 3,
              page_number: 2,
              page_size: 2,
            }
          )
        )
      stub_request(:get, "#{Mavenlink.api_base}/things")
        .with(query: { page: 3 })
        .to_return(
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.generate(
            count: 5,
            results: [
              { key: "things", id: "5" },
            ],
            things: {
              "5": { id: 5 },
            },
            meta: {
              count: 5,
              page_count: 3,
              page_number: 3,
              page_size: 1,
            }
          )
        )
    end
    let(:initial_response) do
      {
        "count" => 5,
        "results" => [
          { "key" => "things", "id" => "1" },
          { "key" => "things", "id" => "2" },
        ],
        "things" => {
          "1" => { "id" => 1 },
          "2" => { "id" => 2 },
        },
        "meta" => {
          "count" => 5,
          "page_count" => 3,
          "page_number" => 1,
        },
      }
    end

    let(:list) { Mavenlink::List.new(Mavenlink::Thing, initial_response) }
    it "requests all the pages from the API" do
      list.auto_paging_each
      expect(a_request(:get, "#{Mavenlink.api_base}/things").with(query: { page: 2 })).to have_been_made
      expect(a_request(:get, "#{Mavenlink.api_base}/things").with(query: { page: 3 })).to have_been_made
      expect(a_request(:get, "#{Mavenlink.api_base}/things").with(query: { page: 4 })).to_not have_been_made
    end

    it "iterates all the results" do
      class Foo
        def self.bar; end
      end
      allow(Foo).to receive(:bar)
      list.auto_paging_each { Foo.bar }
      expect(Foo).to have_received(:bar).exactly(5).times
    end
  end
end

module Mavenlink
  class Thing < Mavenlink::APIResource
    OBJECT_NAME = "thing"
  end
end
