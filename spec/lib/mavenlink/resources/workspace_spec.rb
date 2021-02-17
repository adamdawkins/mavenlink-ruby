# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe Mavenlink::Workspace do
  describe ".retrieve" do
    it "should be retrievable", :vcr do
      workspace = Mavenlink::Workspace.retrieve("28370425")

      expect(a_request(:get, "#{Mavenlink.api_base}/workspaces/28370425")).to(
        have_been_made
      )
      expect(workspace).to be_a Mavenlink::Workspace
    end
  end

  describe ".list" do
    it "should be listable", :vcr do
      workspaces = Mavenlink::Workspace.list
      expect(a_request(:get, "#{Mavenlink.api_base}/workspaces")).to have_been_made
      expect(workspaces).to be_a Mavenlink::List
      expect(workspaces.first).to be_a Mavenlink::Workspace
    end
  end

  describe ".list_invoices" do
    it "should list the Invoices for the provided Workspace id", :vcr do
      invoices = Mavenlink::Workspace.list_invoices(27254285)
      expect(a_request(:get, "#{Mavenlink.api_base}/invoices")
        .with(query: { workspace_id: 27254285 })).to have_been_made
      expect(invoices).to be_a Mavenlink::List
      expect(invoices.to_a.first).to be_a Mavenlink::Invoice
    end
  end
end
