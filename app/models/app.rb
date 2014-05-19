# == Schema Information
#
# Table name: apps
#
#  id         :integer         not null, primary key
#  api_token  :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class App < ActiveRecord::Base
  attr_accessible :api_token
end
