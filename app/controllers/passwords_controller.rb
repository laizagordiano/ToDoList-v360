class PasswordsController < ApplicationController
  before_action :set_user_by_token, only: [:edit, :update]

  # GET /passwords/new (formulário pedir email)
  def new
    @user = User.new
  end

  # POST /passwords (enviar email de reset)
  def create
    user = User.find_by(email: params[:user][:email])
    
    if user
      user.generate_password_reset_token!
      UserMailer.with(user: user).reset_password_email.deliver_later
      redirect_to new_session_path, notice: "Email de recuperação enviado. Verifique sua caixa de entrada."
    else
      redirect_to new_password_path, alert: "Email não encontrado."
    end
  end

  # GET /passwords/:token (formulário nova senha)
  def edit
    return unless @user.password_reset_token_valid?
  end

  # PATCH/PUT /passwords/:token (atualizar senha)
  def update
    return unless @user.password_reset_token_valid?

    if @user.update(password_params)
      @user.update(reset_password_token: nil, reset_password_sent_at: nil)
      redirect_to new_session_path, notice: "Senha atualizada com sucesso. Faça login."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user_by_token
    @user = User.find_by(reset_password_token: params[:token])
    redirect_to new_password_path, alert: "Link inválido ou expirado." unless @user
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
