class InitBillStatus < ActiveRecord::Migration
  def up
    Bill.update_all(status:'submitted')
  end

  def down
  end
end
