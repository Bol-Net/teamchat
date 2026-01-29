module JwtAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_with_jwt!
  end

  def authenticate_with_jwt!
    token = bearer_token_from_header
    payload = JwtService.decode_access_token(token)
    @current_user = User.find(payload['sub'])
  rescue => e
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

  def current_user
    @current_user
  end

  private

  def bearer_token_from_header
    header = request.headers['Authorization']
    raise 'missing auth' unless header.present? && header.start_with?('Bearer ')
    header.split(' ').last
  end
end
