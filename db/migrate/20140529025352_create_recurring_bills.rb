class CreateRecurringBills < ActiveRecord::Migration
  def change
    create_table :recurring_bills do |t|
      t.string :uid
      t.string :period
      t.integer :frequency
      t.integer :cycles
      t.datetime :start_date
      t.string :description
      t.string :status
      t.integer :price_cents
      t.string :currency
      t.string :group_id

      t.timestamps
    end
  end
end
