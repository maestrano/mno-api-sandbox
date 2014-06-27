class AddRecurringBillIdToBills < ActiveRecord::Migration
  def change
    add_column :bills, :recurring_bill_id, :integer
  end
end
