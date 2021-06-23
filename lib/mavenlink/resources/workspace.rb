# frozen_string_literal: true

module Mavenlink
  class Workspace < APIResource
    OBJECT_NAME = "workspace"

    def self.list_invoices(id, params = {})
      query_params = Util.flatten_params(params.merge(workspace_id: id))
      query = query_params.to_query
      response = get("/invoices?#{query}")
      List.new(Invoice, response, {}, query_params)
    end

    def self.list_stories(id, params = {})
      query_params = params.merge(workspace_id: id)
      query = query_params.to_query
      response = get("/stories?#{query}")
      List.new(Story, response, {}, query_params)
    end
  end
end
