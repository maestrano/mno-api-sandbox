class FixUidGeneration < ActiveRecord::Migration
  def up
    App.all.each do |app|
      app.uid = "app-#{app.id}"
      app.save
    end
  end

  def down
  end
end
