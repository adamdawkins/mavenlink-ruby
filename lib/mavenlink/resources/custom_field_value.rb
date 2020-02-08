# frozen_string_literal: true

module Mavenlink
  class CustomFieldValue < APIResource
    OBJECT_NAME = "custom_field_value"

    def self.list(subject_type = nil)
      if subject_type.nil?
        raise ArgumentError,
              "CustomFieldValues can only be listed with a subject, " \
              "e.g. CustomFieldValue.list('user')"
      end

      super(subject_type: subject_type)
    end

    def subject
      case subject_type
      when "workspace_group"
        WorkspaceGroup.retrieve(subject_id)
      end
    end
  end
end
