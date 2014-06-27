class AddInitialSetupFieldsToRecurringBills < ActiveRecord::Migration
  def change
    add_column :recurring_bills, :initial_cents, :integer
    add_column :recurring_bills, :setup_at, :datetime
  end
end
