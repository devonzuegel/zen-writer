# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  def new
    redirect_to '/auth/facebook'
  end

  def create
    auth = request.env['omniauth.auth']
    found_user = User.where(provider: auth['provider'],
                            uid:      auth['uid'].to_s).first
    user = found_user || User.create_with_omniauth(auth)

    reset_session
    session[:user_id] = user.id

    redirect_to root_url, notice: 'Signed in!'
  end

  def destroy
    reset_session
    redirect_to root_url, notice: 'Signed out!'
  end

  def failure
    message = "Authentication error: #{params[:message].humanize}"
    redirect_to root_url, error: message
  end
end
