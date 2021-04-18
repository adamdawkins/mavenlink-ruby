# frozen_string_literal: true

module Mavenlink
  class WorkspaceGroup < APIResource
    OBJECT_NAME = "workspace_group"

    def self.list_workspaces(id, params = {})
      response = get("/workspaces?workspace_groups=#{id}")
      List.new(Workspace, response, {}, params.merge({ workspace_group_id: id }))
    end

    def self.list_custom_field_values(id)
      response = get("/custom_field_values", subject_type: OBJECT_NAME)
      List.new(CustomFieldValue, response,
               { filters: { subject_id: id.to_i } },
               subject_type: OBJECT_NAME)
    end

    def workspaces
      @workspaces ||= self.class.list_workspaces(id)
    end

    def custom_field_values
      @custom_field_values ||= self.class.list_custom_field_values(id)
    end
  end
end
