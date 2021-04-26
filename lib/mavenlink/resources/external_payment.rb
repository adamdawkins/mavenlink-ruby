module Mavenlink
  class ExternalPayment < APIResource
    include Mavenlink::APIOperations::Request

    OBJECT_NAME = "external_payment"

    # rubocop:disable Metrics/MethodLength
    def self.create(workspace_id:, invoice_id:)
      response = post("/external_payments",
                      external_payment: {
                        workspace_id: workspace_id,
                        invoice_id: invoice_id,
                      })

      data = Util.results(response).first
      new(data)
    end
    # rubocop:enable Metrics/MethodLength
  end
end
