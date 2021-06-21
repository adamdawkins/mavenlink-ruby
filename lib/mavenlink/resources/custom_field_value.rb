# frozen_string_literal: true

module Mavenlink
  class CustomFieldValue < APIResource
    OBJECT_NAME = "custom_field_value"

    def self.list(params = {}, options = {})
      unless params.key? :subject_type
        raise ArgumentError,
          "CustomFieldValues can only be listed with a subject, " \
          "e.g. CustomFieldValue.list({subject_type: 'user'})"
      end

      super(params, options)
    end

    def subject
      case subject_type
      when "workspace_group"
        WorkspaceGroup.retrieve(subject_id)
      end
    end
  end
end
