class CreateAlerts < ActiveRecord::Migration[6.1]
  def change
    create_table :alerts do |t|
      t.references :alertable, null: false, polymorphic: true
      t.boolean :resolved, default: false
      t.string :message
      t.string :kind, null: false

      t.timestamps
    end
  end
end
