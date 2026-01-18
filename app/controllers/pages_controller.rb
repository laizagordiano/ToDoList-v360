class PagesController < ApplicationController

  def home
    
    if logged_in?
      redirect_to lists_path
    end
  end
end
