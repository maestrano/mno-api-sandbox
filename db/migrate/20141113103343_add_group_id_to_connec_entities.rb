class AddGroupIdToConnecEntities < ActiveRecord::Migration
  def change
    add_column :connec_entities, :group_id, :string
  end
end
