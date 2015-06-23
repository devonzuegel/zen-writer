class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :controller_info

  helper_method :current_user, :signed_in?, :correct_user!

  private
    def current_user
      begin
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
      rescue Exception => e
        nil
      end
    end

    def signed_in?
      current_user != nil
    end

    def correct_user! user=nil
      user ||= User.find(params[:id])
      if current_user != user
        redirect_to root_url, alert: "Access denied."
      end
    end

    def authenticate_user!
      if !current_user
        redirect_to root_url, alert: 'You need to sign in for access to this page.'
      end
    end

    def controller_info
      gon.controller = params[:controller]
      gon.action     = params[:action]
    end
end
