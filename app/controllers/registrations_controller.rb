class RegistrationsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)
    @user.build_profile

    if @user.save
      render :create
    else
      render :new
    end
  end

  def confirm
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def registration_params
      params.require(:user).permit(:name, :username, :email, :password, :password_confirmation)
    end
end
