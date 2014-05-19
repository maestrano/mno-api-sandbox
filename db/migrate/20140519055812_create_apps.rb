class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string :api_token

      t.timestamps
    end
  end
end
