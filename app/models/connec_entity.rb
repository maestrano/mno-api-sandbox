# == Schema Information
#
# Table name: connec_entities
#
#  id         :integer          not null, primary key
#  uid        :string(255)
#  document   :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ConnecEntity < ActiveRecord::Base
  attr_accessible :document, :uid
end
