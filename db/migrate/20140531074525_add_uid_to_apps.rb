class AddUidToApps < ActiveRecord::Migration
  def change
    add_column :apps, :uid, :string
  end
end
