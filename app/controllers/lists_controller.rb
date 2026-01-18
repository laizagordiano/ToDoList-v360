class ListsController < ApplicationController
  #Exige que o usuário esteja logado
  before_action :require_login

  def index
    #Busca todas as listas do usuário atual
    @lists = current_user.lists
  end

  def show
    #Busca uma lista específica do usuário atual
    @list = current_user.lists.find(params[:id])
  end

  def new
    #Inicializa uma nova lista para o formulário
    @list = current_user.lists.new
  end

  def create
    #Cria uma nova lista com os parâmetros fornecidos
    @list = current_user.lists.new(list_params)
    if @list.save
      redirect_to @list, notice: "List created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    #Busca uma lista específica para edição
    @list = current_user.lists.find(params[:id])
  end
  
  def update
    #Atualiza uma lista existente com os parâmetros fornecidos
    @list = current_user.lists.find(params[:id])
    if @list.update(list_params)
      redirect_to @list, notice: "List updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    #Exclui uma lista específica do usuário atual
    @list = current_user.lists.find(params[:id])
    @list.destroy
    redirect_to lists_path, notice: "List deleted successfully."
  end

  private
  def list_params
    #Permite apenas os parâmetros necessários para a lista
    params.require(:list).permit(:title, :description)
  end
end
