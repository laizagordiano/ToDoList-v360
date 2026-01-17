class List < ApplicationRecord

  #Associação indicando que uma lista pode ter muitas tarefas e que uma lista pertence a um usuário
  has_many :tasks, dependent: :destroy
  belongs_to :user
  #Validação para garantir presença do título da lista
  validates :title, presence: true

end
