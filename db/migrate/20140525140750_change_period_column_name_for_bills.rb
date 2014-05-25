class ChangePeriodColumnNameForBills < ActiveRecord::Migration
  def up
    rename_column :bills, :period_start, :period_started_at
    rename_column :bills, :period_end, :period_ended_at
  end

  def down
    rename_column :bills, :period_started_at, :period_start
    rename_column :bills, :period_ended_at, :period_end
  end
end
