class ChangeGroupIdColumnTypeOnRecurringBills < ActiveRecord::Migration
  def change
     change_column :recurring_bills, :group_id, :integer
    end
end
