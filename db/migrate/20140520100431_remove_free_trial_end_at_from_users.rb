class RemoveFreeTrialEndAtFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :free_trial_end_at
  end

  def down
  end
end
