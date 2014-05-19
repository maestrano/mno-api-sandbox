# == Schema Information
#
# Table name: group_user_rels
#
#  id         :integer         not null, primary key
#  group_id   :integer
#  user_id    :integer
#  role       :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class GroupUserRel < ActiveRecord::Base
  attr_accessible :group_id, :role, :user_id
  
  #============================================
  # Associations
  #============================================
  belongs_to :user
  belongs_to :group
  
end
