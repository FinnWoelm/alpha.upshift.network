class AccountsController < ApplicationController
  before_action :authorize
  before_action :set_account

  def edit
  end

  def update
    if @account.update(account_params)
      redirect_to edit_account_path, notice: 'Password successfully changed'
    else
      render 'edit'
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
