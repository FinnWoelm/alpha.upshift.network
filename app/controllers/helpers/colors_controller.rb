class Helpers::ColorsController < ApplicationController
  before_action :current_user

  layout 'without_sidenav'

  def test
    @color_schemes = Color.color_options.map {|c| "#{c} #{Color.font_color_for c}"}
  end
end
