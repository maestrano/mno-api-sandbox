class AddAppIdToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :app_id, :integer
  end
end
