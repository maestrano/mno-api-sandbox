class Bill < ActiveRecord::Base
  attr_accessible :currency, :description, :group_id, :period_end, :period_start, :price_cents, :uid, :units
end
