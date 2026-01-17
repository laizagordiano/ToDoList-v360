class User < ApplicationRecord
  
  has_secure_password
  has_many :lists, dependent: :destroy

 #Validação para garantir presença, formato e unicidade do email do usuário
  VALID_EMAIL_FORMAT= /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates :email, presence: true, length: {maximum: 260}, format: { with: VALID_EMAIL_FORMAT}, uniqueness: {case_sensitive: false}
  
  #Callback para garantir que o email seja salvo em letras minúsculas
  before_save { self.email = email.downcase }

 
 
end
