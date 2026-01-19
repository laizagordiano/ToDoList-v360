class User < ApplicationRecord
  
  has_secure_password
  has_many :lists, dependent: :destroy

 #Validação para garantir presença, formato e unicidade do email do usuário
  VALID_EMAIL_FORMAT= /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates :email, presence: true, length: {maximum: 260}, format: { with: VALID_EMAIL_FORMAT}, uniqueness: {case_sensitive: false}
  
  #Callback para garantir que o email seja salvo em letras minúsculas
  before_save { self.email = email.downcase }

  #Callback para enviar email de boas-vindas após a criação do usuário
  after_create :send_welcome_email

   # Gera token para reset de senha
  def generate_password_reset_token!
    self.reset_password_token = SecureRandom.urlsafe_base64
    self.reset_password_sent_at = Time.current
    save!
  end

  # Verifica se o token ainda é válido (exemplo: 2 horas)
  def password_reset_token_valid?
    reset_password_sent_at && reset_password_sent_at > 2.hours.ago
  end
  
  private

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_later
  end
end
