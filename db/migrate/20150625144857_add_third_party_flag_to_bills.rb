class AddThirdPartyFlagToBills < ActiveRecord::Migration
  def change
    add_column :bills, :third_party, :boolean, default: false
  end
end
