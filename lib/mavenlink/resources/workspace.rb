# frozen_string_literal: true

module Mavenlink
  class Workspace < APIResource
    OBJECT_NAME = "workspace"

    def self.list_invoices(id)
      response = get("/invoices?workspace_id=#{id}")
      List.new(Invoice, response, {}, workspace_id: id)
    end
  end
end
