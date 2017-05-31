class SessionsController < ApplicationController

  layout 'without_sidenav'

  # GET /login
  def new
  end

  # POST /login
  def create
    account = Account.find_by_email(params[:email])

    # If the user exists AND the password entered is correct.
    if account && account.authenticate(params[:password])
      # Save the user id inside the browser cookie. This is how we keep the user
      # logged in when they navigate around our website.
      session[:user_id] = account.user.id
      redirect_to root_path
    else
    # If user's login doesn't work, send them back to the login form.
      redirect_to '/login'
    end

  end

  # GET /logout
  def destroy
    session[:user_id] = nil
    redirect_to '/login'
  end
end
