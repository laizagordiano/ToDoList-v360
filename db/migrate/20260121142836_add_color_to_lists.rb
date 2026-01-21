class AddColorToLists < ActiveRecord::Migration[8.1]
  def change
    add_column :lists, :color, :string
  end
end
