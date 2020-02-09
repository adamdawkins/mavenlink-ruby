# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe Mavenlink::WorkspaceGroup do
  describe ".retrieve" do
    it "should be retrievable", :vcr do
      workspace_group = Mavenlink::WorkspaceGroup.retrieve("2551145")

      expect(a_request(:get, "#{Mavenlink.api_base}/workspace_groups/2551145")).to(
        have_been_made
      )
      expect(workspace_group).to be_a Mavenlink::WorkspaceGroup
    end
  end

  describe ".list" do
    it "should be listable", :vcr do
      workspace_groups = Mavenlink::WorkspaceGroup.list
      expect(a_request(:get, "#{Mavenlink.api_base}/workspace_groups")).to have_been_made
      expect(workspace_groups).to be_a Mavenlink::List
      expect(workspace_groups.first).to be_a Mavenlink::WorkspaceGroup
    end
  end

  describe ".list_workspaces" do
    it "should list the Workspaces for the provided WorkspaceGroup id", :vcr do
      workspaces = Mavenlink::WorkspaceGroup.list_workspaces(2551145)
      expect(a_request(:get, "#{Mavenlink.api_base}/workspaces")
                       .with(query: { workspace_groups: 2551145 })).to have_been_made
      expect(workspaces).to be_a Mavenlink::List
      expect(workspaces.to_a.first).to be_a Mavenlink::Workspace
    end
  end

  describe ".list_custom_field_values" do
    # Setup a fake custom_field_values response that contains two values for
    # our object and two for other objects.
    # We can't rely on VCR here because we're trying to setup a specific
    # scenario in the *response* and the real-world values could change at
    # any time
    # TODO: Probably move this to a factory / fixture file.

    before do
      # Numeric Literals just look weird in IDs
      stub_request(:get, "#{Mavenlink.api_base}/custom_field_values")
        .with(query: { subject_type: "workspace_group" })
        .to_return(
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.generate(
            count: 4,
            results: [
              { key: "custom_field_values", id: "111" },
              { key: "custom_field_values", id: "222" },
              { key: "custom_field_values", id: "888" },
              { key: "custom_field_values", id: "999" },
            ],
            custom_field_values: {
              "111": { id: "111",
                       subject_type: "workspace_group", subject_id: 2551145,
                       custom_field_name: "Foo", value: "Bar", },
              "222": { id: "222",
                       subject_type: "workspace_group", subject_id: 2551145,
                       custom_field_name: "Stripe ID", value: "cus_xyz", },
              "888": { id: "888",
                       subject_type: "workspace_group", subject_id: 9999999,
                       custom_field_name: "Bar", value: "I'm having the muffin", },
              "999": { id: "999",
                       subject_type: "workspace_group", subject_id: 9999999,
                       custom_field_name: "Stripe ID", value: "cus_xyz", },
            },
            meta: {
              count: 4,
              page_count: 1,
              page_number: 1,
              page_size: 20,
            }
          )
        )
    end

    let!(:custom_field_values) { Mavenlink::WorkspaceGroup.list_custom_field_values(2551145) }
    it "should list CustomFieldValues" do
      expect(
        a_request(:get, "#{Mavenlink.api_base}/custom_field_values")
        .with(query: { subject_type: "workspace_group" })
      ).to have_been_made
      expect(custom_field_values).to be_a Mavenlink::List
      expect(custom_field_values.to_a.first).to be_a Mavenlink::CustomFieldValue
    end

    it "should only return the CustomFieldValues for the current object" do
      expect(custom_field_values.count).to eq 2
    end
  end

  describe "#workspaces" do
    before do
      allow(Mavenlink::WorkspaceGroup).to receive(:list_workspaces).and_return(true)
    end
    let(:workspace_group) { Mavenlink::WorkspaceGroup.new(id: 2551145) }

    it "should defer to .list_workspaces with the current id" do
      allow(Mavenlink::WorkspaceGroup).to receive :list_workspaces
      workspace_group = Mavenlink::WorkspaceGroup.new(id: 2551145)

      workspace_group.workspaces

      expect(Mavenlink::WorkspaceGroup).to(
        have_received(:list_workspaces).with(2551145)
      )
    end

    it "should cache the result and not call list_workspaces twice" do
      workspace_group.workspaces
      workspace_group.workspaces

      expect(Mavenlink::WorkspaceGroup).to(
        have_received(:list_workspaces).with(2551145).once
      )
    end
  end

  describe "#custom_field_values", :vcr do
    before do
      allow(Mavenlink::WorkspaceGroup).to receive(:list_custom_field_values).and_return true
    end

    let(:workspace_group) { Mavenlink::WorkspaceGroup.new(id: 2551145) }
    it "should defer to .list_custom_field_values with the current id" do
      workspace_group.custom_field_values

      expect(Mavenlink::WorkspaceGroup).to have_received(:list_custom_field_values).with(2551145)
    end

    it "should cache the result and not call list_custom_field_values twice" do
      workspace_group.custom_field_values
      workspace_group.custom_field_values

      expect(Mavenlink::WorkspaceGroup).to(
        have_received(:list_custom_field_values).with(2551145).once
      )
    end
  end
end
