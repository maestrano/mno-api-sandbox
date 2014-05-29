class ChangeGroupIdColumnTypeOnRecurringBills < ActiveRecord::Migration
  def up
    remove_column :recurring_bills, :group_id
    add_column :recurring_bills, :group_id, :integer
  end
end
