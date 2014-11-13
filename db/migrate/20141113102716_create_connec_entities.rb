class CreateConnecEntities < ActiveRecord::Migration
  def change
    create_table :connec_entities do |t|
      t.string :uid
      t.text :document

      t.timestamps
    end
  end
end
