class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders do |t|
      t.string :customer
      t.date :placed
      t.boolean :paid
      t.boolean :refunded
      t.boolean :shipped
      t.boolean :returned

      t.timestamps
    end
  end
end
