class UsersController < ApplicationController
  # GET /users/new
  def new
    @user = User.new
  end

  # POST /users
  def create
    @user = User.new(user_params)
    
    if @user.save
      # Envio síncrono de email via API HTTP do Brevo (não usa ActiveJob, SMTP ou deliver_later)
      begin
        BrevoService.send_welcome_email(@user, self)
      rescue => e
        Rails.logger.error("❌ Erro ao enviar email de boas-vindas via Brevo API: #{e.message}")
        # Continua mesmo se o email falhar, pois o usuário já foi criado
      end
      
      respond_to do |format|
        format.html { redirect_to new_session_path, notice: "Usuário criado com sucesso. Faça login." }
        format.json { render json: { message: "Usuário criado com sucesso" }, status: :created }
      end
    else
      # Se houver erros, renderiza o formulário novamente
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  # Permite apenas os campos confiáveis
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
