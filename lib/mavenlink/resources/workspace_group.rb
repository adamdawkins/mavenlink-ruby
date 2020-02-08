# frozen_string_literal: true

module Mavenlink
  class WorkspaceGroup < APIResource
    OBJECT_NAME = "workspace_group"

    def self.list_workspaces(id)
      response = get("/workspaces?workspace_groups=#{id}")
      ListObject.new(Workspace, response)
    end

    def self.list_custom_field_values(id)
      response = get("/custom_field_values", subject_type: OBJECT_NAME,
                                             subject_id: id)
      ListObject.new(CustomFieldValue, response)
    end

    def workspaces
      @workspaces ||= self.class.list_workspaces(id)
    end

    def custom_field_values
      @custom_field_values ||= self.class.list_custom_field_values(id)
    end
  end
end
