class AddEntityNameToConnecEntities < ActiveRecord::Migration
  def change
    add_column :connec_entities, :entity_name, :string
  end
end
