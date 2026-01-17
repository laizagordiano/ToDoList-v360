class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title
      t.boolean :completed
      t.references :list, null: false, foreign_key: true

      t.timestamps
    end
  end
end
