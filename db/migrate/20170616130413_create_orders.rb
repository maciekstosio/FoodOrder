class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.integer :list_id
      t.string :name
      t.decimal :price, precision: 6, scale: 2

      t.timestamps
    end
  end
end
