class AccountsController < ApplicationController
  before_action :authorize
  before_action :set_account

  layout Proc.new{
    if @current_user
      'application'
    else
      'without_sidenav'
    end
  }

  def edit
  end

  def update
    if @account.update(account_params)
      redirect_to edit_account_path, notice: 'Password successfully changed'
    else
      render 'edit'
    end
  end

  def destroy
    @user = @account.user
  end

  def confirm_destroy
    @account.assign_attributes(account_params)
    @user = @account.user
    @profile_picture = @user.profile_picture_base64
    if @account.destroy
      @current_user = session[:user_id] = nil # sign user out
      render 'confirm_destroy', notice: 'Account successfully deleted'
    else
      render 'destroy'
    end
  end

  private

    def set_account
      @account = @current_user.account
    end

    def account_params
      params.require(:account).permit(:update_password, :current_password, :password, :password_confirmation)
    end
end
