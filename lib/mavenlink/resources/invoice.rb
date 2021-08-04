# frozen_string_literal: true

module Mavenlink
  class Invoice < APIResource
    include Mavenlink::APIOperations::Request

    OBJECT_NAME = "invoice"

    def self.create(details)
      response = post("/invoices",
        invoice: {
          workspace_id: details[:workspace_id],
          payment_schedule: 0,
          draft: false,
          fixed_fee_items: [
            {story_id: details[:story_id],
             notes: details[:note],
             amount: details[:amount]}
          ]
        })

      data = Util.results(response).first
      construct_from(data)
    end

    def time_entries
      values["time_entries"].map do |time_entry|
        Mavenlink::TimeEntry.new(time_entry)
      end
    end
  end
end
