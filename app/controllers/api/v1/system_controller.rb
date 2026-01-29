class Api::V1::SystemController < ApplicationController
  def health
    client = Grpc::MessageServiceClient.new
    status = client.health

    if status
      render json: { message_service: status }
    else
      render json: { error: "Message service unavailable" }, status: 503
    end
  end
end