class TasksController < ApplicationController
  before_action :require_login
  before_action :set_list
  before_action :set_task, only: [:edit, :update, :destroy, :show]

  def index
    @tasks = @list.tasks
    
    # Filtros
    case params[:filter]
    when 'pending'
      @tasks = @tasks.where("done IS NULL OR done = ?", false)
    when 'completed'
      @tasks = @tasks.where(done: true)
    when 'overdue'
      @tasks = @tasks.where("(done IS NULL OR done = ?) AND due_date < ?", false, Date.today)
    when 'today'
      @tasks = @tasks.where("(done IS NULL OR done = ?) AND due_date = ?", false, Date.today)
    end
    
    # Ordenação
    case params[:sort]
    when 'due_date'
      @tasks = @tasks.order(Arel.sql('CASE WHEN due_date IS NULL THEN 1 ELSE 0 END'), due_date: :asc)
    when 'priority'
      @tasks = @tasks.order(priority: :desc, created_at: :desc)
    when 'status'
      @tasks = @tasks.order(done: :asc, created_at: :desc)
    else
      @tasks = @tasks.order(created_at: :desc)
    end
  end

  def new
    @task = @list.tasks.build
  end

  def create
    @task = @list.tasks.build(task_params)
    if @task.save
      redirect_to list_tasks_path(@list), notice: "Task created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end


  def update
    if @task.update(task_params)
      redirect_to list_tasks_path(@list), notice: "Task updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
  @task = @list.tasks.find(params[:id])
  @task.destroy

  respond_to do |format|
    format.html { redirect_to list_tasks_path(@list), notice: "Task deleted successfully." }
    format.turbo_stream
  end
end

  private

  def set_list
    @list = current_user.lists.find(params[:list_id])
  end

  def set_task
    @task = @list.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :done, :due_date, :priority)
  end
end
