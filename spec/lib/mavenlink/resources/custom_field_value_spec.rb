# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe Mavenlink::CustomFieldValue do
  describe ".list" do
    context "a subject type is provided" do
      it "should be listable", :vcr do
        custom_field_values = Mavenlink::CustomFieldValue.list("workspace_group")
        expect(
          a_request(:get, "#{Mavenlink.api_base}/custom_field_values")
          .with(query: { subject_type: "workspace_group" })
        ).to have_been_made
        expect(custom_field_values.data).to be_a Array
        expect(custom_field_values.first).to be_a Mavenlink::CustomFieldValue
      end
    end

    context "no subject type is provided" do
      it "should raise an error" do
        expect do
          Mavenlink::CustomFieldValue.list
        end.to raise_error ArgumentError
      end
    end
  end

  describe ".retrieve" do
    it "should be retrievable", :vcr do
      custom_field_value = Mavenlink::CustomFieldValue.retrieve("314259865")

      expect(a_request(:get, "#{Mavenlink.api_base}/custom_field_values/314259865")).to(
        have_been_made
      )
      expect(custom_field_value).to be_a Mavenlink::CustomFieldValue
    end
  end

  describe "#subject" do
    # rubocop:disable Style/NumericLiterals
    let(:custom_field_value_attrs) do
      {
        "subject_type": "workspace_group",
        "subject_id": 2223265,
        "value": "ABCD",
        "account_id": 6300575,
        "custom_field_name": "Stripe ID",
        "type": "string",
        "display_value": "ABCD",
        "can_edit": true,
        "created_at": "2020-01-02T12:30:06-08:00",
        "updated_at": "2020-01-02T12:30:06-08:00",
        "custom_field_id": "602325",
        "setter_id": "12304555",
        "id": "314259865",
      }
    end
    # rubocop:enable Style/NumericLiterals

    before do
      allow(Mavenlink::WorkspaceGroup).to receive(:retrieve).with(2_223_265) do
        Mavenlink::WorkspaceGroup.new(id: 2_223_265)
      end
    end
    it "should retrieve the subject from the relevant class" do
      custom_field_value =  Mavenlink::CustomFieldValue.new(custom_field_value_attrs)
      custom_field_value.subject
      expect(Mavenlink::WorkspaceGroup).to have_received(:retrieve)
    end
  end
end
