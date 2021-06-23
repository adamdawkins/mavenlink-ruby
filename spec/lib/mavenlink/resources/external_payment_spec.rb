# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe Mavenlink::ExternalPayment, type: :model do
  it "should be creatable", :vcr do
    external_payment = Mavenlink::ExternalPayment.create(workspace_id: 36380125,
                                                         invoice_id: 10662795)

    expect(external_payment).to be_a Mavenlink::ExternalPayment
  end
end
