class SessionsController < ApplicationController

  ## Twitter Omniauth
	def create
    # Create session for the current user
    @user = User.find_or_create_from_auth_hash(auth_hash)
    session[:user_id] = @user.id

    # Redirect user to dashboard
    flash[:notice] = "Signed in as @#{ @user.name }."
    redirect_to dashboard_path
  rescue
    # Redirect user to root as fallback
    flash[:notice] = "Our servers are currently full, please try again later."
    redirect_to root_path
  end

  ## GET /auth/signout
  def destroy
    session.clear
    redirect_to root_path
  end
 
  protected
  
  def auth_hash
    request.env['omniauth.auth']
  end

end