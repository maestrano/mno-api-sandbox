# == Schema Information
#
# Table name: recurring_bills
#
#  id          :integer         not null, primary key
#  uid         :string(255)
#  period      :string(255)
#  frequency   :integer
#  cycles      :integer
#  start_date  :datetime
#  description :string(255)
#  status      :string(255)
#  price_cents :integer
#  currency    :string(255)
#  group_id    :string(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

require 'spec_helper'

describe RecurringBill do
  pending "add some examples to (or delete) #{__FILE__}"
end
