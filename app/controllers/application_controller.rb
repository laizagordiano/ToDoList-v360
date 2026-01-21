class ApplicationController < ActionController::Base
  before_action :require_login
  helper_method :current_user, :logged_in?

  # Inicia sessão
  def initiate_session(user)
    session[:user_id] = user.id
  end

  # Encerra sessão
  def terminate_session
    session[:user_id] = nil
  end

  # Usuário atual
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  # Verifica se está logado
  def logged_in?
    current_user.present?
  end

  # Exige login para certas ações
  def require_login
    redirect_to new_session_path, alert: "You must be logged in to access this page." unless logged_in?
  end
end
