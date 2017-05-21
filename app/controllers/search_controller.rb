class SearchController < ApplicationController
  before_action :current_user, only: [:search]

  layout Proc.new{
    if @current_user
      'application'
    else
      'without_sidenav'
    end
  }

  def search
    @search_query = params[:query]

    if not @search_query.present?
      @results = User.none
      return

    # search by username only
    elsif @search_query.first == '@'
      @results =
        Search.find_users_by_username(
          @search_query.gsub(/\A@/, ""),
          @current_user
        )

    # search by name only
  elsif @search_query.first == '"' or @search_query.match(Username.regex).nil?
      @results =
        Search.find_users_by_name(
          @search_query.gsub(/\A\"/, ""),
          @current_user
        )

    # search both username and name
    else
      @results =
        Search.find_users_by_username_and_name(
          @search_query,
          @current_user
        )
    end
  end
end
