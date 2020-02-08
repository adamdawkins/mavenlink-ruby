# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe Mavenlink::Invoice, type: :model do
  describe ".retrieve" do
    it "should be retrievable", :vcr do
      invoice = Mavenlink::Invoice.retrieve("8185325")

      expect(a_request(:get, "#{Mavenlink.api_base}/invoices/8185325")).to(
        have_been_made
      )
      expect(invoice).to be_a Mavenlink::Invoice
    end
  end

  describe ".list" do
    it "should be listable", :vcr do
      invoices = Mavenlink::Invoice.list
      expect(a_request(:get, "#{Mavenlink.api_base}/invoices")).to have_been_made
      expect(invoices).to be_a Mavenlink::ListObject
      expect(invoices.first).to be_a Mavenlink::Invoice
    end
  end
end
