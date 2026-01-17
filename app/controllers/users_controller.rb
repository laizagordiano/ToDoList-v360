class UsersController < ApplicationController
  # GET /users/new
  def new
    @user = User.new
  end

  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to new_session_path, notice: "User created successfully. Please log in."
    else
      # Se houver erros, renderiza o formulário novamente
      render :new, status: :unprocessable_entity
    end
  end

  private

  # Permite apenas os campos confiáveis
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
