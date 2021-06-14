class CreateSpecialAlerts < ActiveRecord::Migration[6.1]
  def change
    create_table :special_alerts do |t|
      t.references :alertable, null: false, polymorphic: true
      t.boolean :resolved, default: false
      t.string :message
      t.integer :kind # enum

      t.timestamps
    end
  end
end
