class AddDoneToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :done, :boolean
  end
end
