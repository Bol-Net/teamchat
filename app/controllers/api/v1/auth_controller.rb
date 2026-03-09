module Api
  module V1
    class AuthController < ApplicationController
      # skip CSRF if using token-based requests from clients that are not same-origin
      skip_before_action :verify_authenticity_token

      def register
        user = User.new(register_params)
        if user.save
          access = JwtService.issue_access_token(user)
          refresh = user.refresh_tokens.create!(ip: request.remote_ip, user_agent: request.user_agent)
          render json: { access_token: access[:token], access_exp: access[:exp], refresh_token: refresh.token, user: user.as_json(only: [:id, :email, :name, :role]) }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def login
        user = User.find_by(email: params[:email])
        if user&.valid_password?(params[:password])
          access = JwtService.issue_access_token(user)
          refresh = user.refresh_tokens.create!(ip: request.remote_ip, user_agent: request.user_agent)
          render json: { access_token: access[:token], access_exp: access[:exp], refresh_token: refresh.token, user: user.as_json(only: [:id, :email, :name, :role]) }, status: :ok
        else
          render json: { error: 'Invalid credentials' }, status: :unauthorized
        end
      end

      def refresh
        token = params[:refresh_token]
        rt = RefreshToken.find_by(token: token)

        unless rt && !rt.revoked && rt.expires_at > Time.current
          return render json: { error: 'Invalid refresh token' }, status: :unauthorized
        end

        # rotate refresh token
        rt.revoke!
        new_rt = rt.user.refresh_tokens.create!(
          ip: request.remote_ip,
          user_agent: request.user_agent
        )

        access = JwtService.issue_access_token(rt.user)

        render json: {
          access_token: access[:token],
          access_exp: access[:exp],
          refresh_token: new_rt.token
        }, status: :ok, adapter: nil
      end

      def logout
        token = params[:refresh_token]
        rt = RefreshToken.find_by(token: token)
        rt&.revoke!
        head :no_content
      end

      def me
        token = bearer_token_from_header
        payload = JwtService.decode_access_token(token)
      
        user = User.find(payload['sub'])
      
        render json: { user: user }, status: :ok
      rescue JWT::DecodeError, ActiveRecord::RecordNotFound
        render json: { error: 'Invalid token' }, status: :unauthorized
      end

      private

      def register_params
        params.permit(:email, :password, :name)
      end

      def bearer_token_from_header
        header = request.headers['Authorization']
        raise 'missing auth' unless header.present? && header.start_with?('Bearer ')
        header.split(' ').last
      end
    end
  end
end