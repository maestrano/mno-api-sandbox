class AddNameToApps < ActiveRecord::Migration
  def change
    add_column :apps, :name, :string
  end
end
