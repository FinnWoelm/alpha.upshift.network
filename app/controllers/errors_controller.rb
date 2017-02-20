class ErrorsController < ApplicationController

  before_action :current_user, only: [:not_found, :unacceptable]

  def not_found
    render(:status => 404)
  end

  def unacceptable
    render(:status => 422)
  end

  def internal_server_error
    render(:status => 500)
  end
end
