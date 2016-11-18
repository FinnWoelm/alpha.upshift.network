class RegistrationsController < ApplicationController

  before_action :current_user, only: [:confirm, :confirmation_reminder, :resend_confirmation]

  layout "static_info_message", only: [:confirm]

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)
    @user.build_profile

    if @user.save
      @user.send_registration_email
      render :create
    else
      render :new
    end
  end

  def confirm
    @user =
      User.find_by(
        :email => params[:email],
        :registration_token => params[:registration_token]
      )

    if @user
      @user.update_attributes(confirmed_registration: true)
      render :confirm
    else
      render :error
    end
  end

  # Show a reminder to the user to confirm their email address
  def confirmation_reminder
  end

  # Resend registration confirmation to user
  def resend_confirmation
    current_user.send_registration_email
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def registration_params
      params.require(:user).permit(:name, :username, :email, :password, :password_confirmation)
    end
end
