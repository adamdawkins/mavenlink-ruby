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
      workspaces = Mavenlink::WorkspaceGroup.list_workspaces(2_551_145)
      expect(a_request(:get, "#{Mavenlink.api_base}/workspaces?workspace_groups=2551145")).to have_been_made
      expect(workspaces).to be_a Mavenlink::List
      expect(workspaces.to_a.first).to be_a Mavenlink::Workspace
    end
  end

  describe ".list_custom_field_values" do
    it "should list the CustomFieldValues for the provided WorkspaceGroup id", :vcr do
      custom_field_values = Mavenlink::WorkspaceGroup.list_custom_field_values("2551145")

      expect(
        a_request(:get, "#{Mavenlink.api_base}/custom_field_values")
        .with(query: { subject_type: "workspace_group", subject_id: "2551145" })
      ).to have_been_made
      expect(custom_field_values).to be_a Mavenlink::List
      expect(custom_field_values.to_a.first).to be_a Mavenlink::CustomFieldValue
    end
  end

  describe "#workspaces" do
    before do
      allow(Mavenlink::WorkspaceGroup).to receive(:list_workspaces).and_return(true)
    end
    let(:workspace_group) { Mavenlink::WorkspaceGroup.new(id: "2551145") }

    it "should defer to .list_workspaces with the current id" do
      allow(Mavenlink::WorkspaceGroup).to receive :list_workspaces
      workspace_group = Mavenlink::WorkspaceGroup.new(id: "2551145")

      workspace_group.workspaces

      expect(Mavenlink::WorkspaceGroup).to(
        have_received(:list_workspaces).with("2551145")
      )
    end

    it "should cache the result and not call list_workspaces twice" do
      workspace_group.workspaces
      workspace_group.workspaces

      expect(Mavenlink::WorkspaceGroup).to(
        have_received(:list_workspaces).with("2551145").once
      )
    end
  end

  describe "#custom_field_values", :vcr do
    before do
      allow(Mavenlink::WorkspaceGroup).to receive(:list_custom_field_values).and_return true
    end

    let(:workspace_group) { Mavenlink::WorkspaceGroup.new(id: "2551145") }
    it "should defer to .list_custom_field_values with the current id" do
      workspace_group.custom_field_values

      expect(Mavenlink::WorkspaceGroup).to have_received(:list_custom_field_values).with("2551145")
    end

    it "should cache the result and not call list_custom_field_values twice" do
      workspace_group.custom_field_values
      workspace_group.custom_field_values

      expect(Mavenlink::WorkspaceGroup).to(
        have_received(:list_custom_field_values).with("2551145").once
      )
    end
  end
end
