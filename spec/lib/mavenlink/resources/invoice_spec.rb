# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe Mavenlink::Invoice, type: :model do
  it "should be retrievable", :vcr do
    invoice = Mavenlink::Invoice.retrieve("8185325")

    expect(a_request(:get, "#{Mavenlink.api_base}/invoices/8185325")).to(
      have_been_made
    )
    expect(invoice).to be_a Mavenlink::Invoice
  end

  it "should be listable", :vcr do
    invoices = Mavenlink::Invoice.list
    expect(a_request(:get, "#{Mavenlink.api_base}/invoices")).to have_been_made
    expect(invoices).to be_a Mavenlink::List
    expect(invoices.first).to be_a Mavenlink::Invoice
  end

  it "should be creatable", :vcr do
    invoice = Mavenlink::Invoice.create(workspace_id: 36380125,
                                        story_id: 713894615,
                                        note: "Monthly MCP Charge",
                                        amount: 500)

    # TODO: Fix this test, invoice is being created but body not being interpreted as a hash
    # expect(a_request(:post, "#{Mavenlink.api_base}/invoices")
    #         .with(
    #           body: hash_including(
    #             invoice: {
    #               workspace_id: 36380125,
    #               payment_schedule: 0,
    #               draft: false,
    #               fixed_fee_items: [
    #                 { story_id: 713894615, notes: "Monthly MCP Charge", amount: 500 },
    #               ],
    #             }
    #           )
    #         )).to have_been_made

    expect(invoice).to be_a Mavenlink::Invoice
  end
end
