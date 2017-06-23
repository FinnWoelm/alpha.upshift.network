class SessionsController < ApplicationController

  layout 'without_sidenav'

  # GET /login
  def new
    # clear any active session
    session[:user_id] = nil
  end

  # POST /login
  def create
    account = Account.find_by_email(params[:email])

    # If the user exists AND the password entered is correct.
    if account && account.authenticate(params[:password])
      # Save the user id inside the browser cookie. This is how we keep the user
      # logged in when they navigate around our website.
      session[:user_id] = account.user.id

      # Redirect user to website they requested or root path.
      redirect_to session[:return_to] || root_path
      session[:return_to] = nil
    else
      # If user's login doesn't work, render the login form.
      flash.now[:notice] = "Login failed: Email or password incorrect."
      @login_failed = true
      render :new
    end

  end

  # GET /logout
  def destroy
    session[:user_id] = nil
    redirect_to '/login'
  end
end
