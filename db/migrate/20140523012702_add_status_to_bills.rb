class AddStatusToBills < ActiveRecord::Migration
  def change
    add_column :bills, :status, :string
  end
end
