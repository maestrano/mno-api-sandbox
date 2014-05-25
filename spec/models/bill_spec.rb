# == Schema Information
#
# Table name: bills
#
#  id                :integer         not null, primary key
#  uid               :string(255)
#  description       :string(255)
#  group_id          :integer
#  price_cents       :integer
#  currency          :string(255)
#  units             :decimal(10, 2)
#  period_started_at :datetime
#  period_ended_at   :datetime
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  status            :string(255)
#

require 'spec_helper'

describe Bill do
  pending "add some examples to (or delete) #{__FILE__}"
end
