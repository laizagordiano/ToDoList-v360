class PagesController < ApplicationController
  skip_before_action :require_login, only: [:home]

  def home
    
    if logged_in?
      redirect_to lists_path
    end
  end
end
