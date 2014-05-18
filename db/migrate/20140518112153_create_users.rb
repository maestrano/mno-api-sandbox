class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.string :surname
      t.datetime :free_trial_end_at
      t.string :geo_country_code
      t.string :uid
      t.string :sso_session

      t.timestamps
    end
  end
end
