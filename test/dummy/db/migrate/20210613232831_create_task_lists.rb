class CreateTaskLists < ActiveRecord::Migration[6.1]
  def change
    create_table :task_lists do |t|
      t.string :title

      t.timestamps
    end

    add_belongs_to :tasks, :task_list, index: true, null: true
  end
end
