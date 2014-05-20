class AddFreeTrialEndAtToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :free_trial_end_at, :datetime
  end
end
