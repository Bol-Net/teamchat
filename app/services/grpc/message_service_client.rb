require Rails.root.join('lib/grpc/message_pb')
require Rails.root.join('lib/grpc/message_services_pb')

module Grpc
  class MessageServiceClient
    def initialize
      @stub = Grpc::MessageServicesPb::Message::V1::MessageService::Stub.new(
        grpc_host,
        :this_channel_is_insecure
      )
    end

    def health
      request = Grpc::MessagePb::Message::V1::HealthRequest.new
      response = @stub.health(request)
      response.status
    rescue GRPC::BadStatus => e
      Rails.logger.error("gRPC error: #{e.message}")
      nil
    end

    private

    def grpc_host
      ENV.fetch('MESSAGE_SERVICE_GRPC_URL', 'localhost:50051')
    end
  end
end