module Mavenlink
  module ObjectTypes
    def self.object_names_to_classes
      {
        CustomFieldValue::OBJECT_NAME => CustomFieldValue,
        ExternalPayment::OBJECT_NAME => ExternalPayment,
        FixedFeeItem::OBJECT_NAME => FixedFeeItem,
        AdditionalItem::OBJECT_NAME => AdditionalItem,
        Invoice::OBJECT_NAME => Invoice,
        TimeEntry::OBJECT_NAME => TimeEntry,
        Story::OBJECT_NAME => Story,
        Workspace::OBJECT_NAME => Workspace,
        WorkspaceGroup::OBJECT_NAME => WorkspaceGroup
      }
    end
  end
end
