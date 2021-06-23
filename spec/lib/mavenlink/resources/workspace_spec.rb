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
        .with(query: {workspace_id: 27254285})).to have_been_made
      expect(invoices).to be_a Mavenlink::List
      expect(invoices.to_a.first).to be_a Mavenlink::Invoice
    end

    it "should pass other options to the invoices", :vcr do
      invoices = Mavenlink::Workspace.list_invoices(27254285, {include: %w[time_entries expenses]})
      expect(a_request(:get, "#{Mavenlink.api_base}/invoices")
        .with(query: {workspace_id: 27254285, include: "time_entries,expenses"})).to have_been_made
    end
  end
  describe ".list_stories" do
    it "should list the Storys for the provided Workspace id", :vcr do
      storys = Mavenlink::Workspace.list_stories(27254285)
      expect(a_request(:get, "#{Mavenlink.api_base}/stories")
        .with(query: {workspace_id: 27254285})).to have_been_made
      expect(storys).to be_a Mavenlink::List
      expect(storys.to_a.first).to be_a Mavenlink::Story
    end
  end
end
