class PasswordsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create, :edit, :update]

  # GET /passwords/new - Formulário para solicitar reset de senha
  def new
  end

  # POST /passwords - Envia email com link de reset
  def create
    @user = User.find_by(email: params[:email].downcase)
    
    if @user
      @user.generate_password_reset_token!
      
      begin
        BrevoService.send_password_reset_email(@user, self)
        flash[:notice] = t('passwords.create.success')
      rescue => e
        Rails.logger.error("Erro ao enviar email de reset: #{e.message}")
        flash[:notice] = t('passwords.create.success') # Não revelar se email existe
      end
    else
      # Não revela se o email existe ou não (segurança)
      flash[:notice] = t('passwords.create.success')
    end
    
    redirect_to new_session_path
  end

  # GET /passwords/:token/edit - Formulário para definir nova senha
  def edit
    @user = User.find_by(reset_password_token: params[:token])
    
    unless @user && @user.password_reset_token_valid?
      flash[:alert] = t('passwords.edit.invalid_token')
      redirect_to new_session_path
    end
  end

  # PATCH /passwords/:token - Atualiza a senha
  def update
    @user = User.find_by(reset_password_token: params[:token])
    
    unless @user && @user.password_reset_token_valid?
      flash[:alert] = t('passwords.edit.invalid_token')
      redirect_to new_session_path
      return
    end

    if @user.update(password_params)
      # Limpa o token após uso
      @user.update(reset_password_token: nil, reset_password_sent_at: nil)
      flash[:notice] = t('passwords.update.success')
      redirect_to new_session_path
    else
      flash.now[:alert] = t('passwords.update.error')
      render :edit
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
