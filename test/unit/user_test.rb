# == Schema Information
#
# Table name: users
#
#  id                :integer         not null, primary key
#  email             :string(255)
#  name              :string(255)
#  surname           :string(255)
#  free_trial_end_at :datetime
#  geo_country_code  :string(255)
#  uid               :string(255)
#  sso_session       :string(255)
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
