class CreateBills < ActiveRecord::Migration
  def change
    create_table :bills do |t|
      t.string :uid
      t.string :description
      t.integer :group_id
      t.integer :price_cents
      t.string :currency
      t.decimal :units, :precision => 10, :scale => 2
      t.datetime :period_start
      t.datetime :period_end

      t.timestamps
    end
  end
end
