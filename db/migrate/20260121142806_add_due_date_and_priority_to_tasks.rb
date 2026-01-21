class AddDueDateAndPriorityToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :due_date, :date
    add_column :tasks, :priority, :integer, default: 0
  end
end
