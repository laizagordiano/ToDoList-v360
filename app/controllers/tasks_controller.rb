class TasksController < ApplicationController
  before_action :require_login
  before_action :set_list
  before_action :set_task, only: [:edit, :update, :destroy, :show]

  def index
    @tasks = @list.tasks
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
    params.require(:task).permit(:title, :done)
  end
end
