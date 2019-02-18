class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  attr_reader :user_token

  private
    before_action :set_user_token
    def set_user_token
      @user_token = cookies[:user_token]
      if not @user_token
        @user_token = SecureRandom.base64 128 # <-- number of random bytes
        cookies.permanent[:user_token] = {
          value: @user_token,
          httponly: true,
          # Not in development, we only want to require HTTPS in production
          # secure: true,
        }
      end
    end
end
