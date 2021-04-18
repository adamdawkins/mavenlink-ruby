# frozen_string_literal: true

module Mavenlink
  class Workspace < APIResource
    OBJECT_NAME = "workspace"

    def self.list_invoices(id, params = {})
      response = get("/invoices?workspace_id=#{id}")
      List.new(Invoice, response, {}, params.merge(workspace_id: id))
    end

    def self.list_stories(id, params = {})
      response = get("/stories?workspace_id=#{id}")
      List.new(Story, response, {}, params.merge(workspace_id: id))
    end
  end
end
