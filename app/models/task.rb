class Task < ApplicationRecord
  #Associação indicando que uma tarefa pertence a uma lista
  belongs_to :list
  #Validação para garantir presença do título da tarefa
  validates :title, presence: true
end
