# frozen_string_literal: true

module Mavenlink
  class Workspace < APIResource
    OBJECT_NAME = "workspace"

    def self.list_invoices(id, params = {})
      query_params = params.merge(workspace_id: id)
      query = query_params.to_query
      response = get("/invoices?#{query}")
      List.new(Invoice, response, {}, query_params)
    end

    def self.list_stories(id, params = {})
      response = get("/stories?workspace_id=#{id}")
      List.new(Story, response, {}, params.merge(workspace_id: id))
    end
  end
end
