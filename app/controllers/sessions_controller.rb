class SessionsController < ApplicationController
  def new
    #Ação para exibir o formulário de login
  end

  def create
    #Ação para autenticar o usuário e iniciar a sessão
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      initiate_session(user)
      redirect_to root_path, notice: "Login successful."
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end
end
