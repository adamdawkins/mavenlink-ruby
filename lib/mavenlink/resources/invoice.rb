# frozen_string_literal: true

module Mavenlink
  class Invoice < APIResource
    include Mavenlink::APIOperations::Request

    OBJECT_NAME = "invoice"

    # rubocop:disable Metrics/MethodLength
    def self.create(details)
      response = post("/invoices",
                      invoice: {
                        workspace_id: details[:workspace_id],
                        payment_schedule: 0,
                        draft: false,
                        fixed_fee_items: [
                          { story_id: details[:story_id],
                            notes: details[:note],
                            amount: details[:amount], },
                        ],
                      })

      data = Util.results(response).first
      new(data)
    end
    # rubocop:enable Metrics/MethodLength
  end
end
