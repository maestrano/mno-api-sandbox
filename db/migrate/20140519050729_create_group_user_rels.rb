class CreateGroupUserRels < ActiveRecord::Migration
  def change
    create_table :group_user_rels do |t|
      t.integer :group_id
      t.integer :user_id
      t.string :role

      t.timestamps
    end
  end
end
