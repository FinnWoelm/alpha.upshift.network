class AccountsController < ApplicationController
  before_action :authorize
  before_action :set_account

  def edit
  end

  private

    def set_account
      @account = @current_user.account
    end
end
