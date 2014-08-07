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
  attr_accessible :group_id, :role, :user_id, :user, :group
  
  #============================================
  # Constants
  #============================================
  ALLOWED_ROLES = ['Member', 'Power User', 'Admin', 'Super Admin']
  
  #============================================
  # Validation rules
  #============================================
  validates :group_id, :presence => true
  validates :user_id, :presence => true
  validates :role, :presence => true, inclusion: { :in => ALLOWED_ROLES }
  
  #============================================
  # Associations
  #============================================
  belongs_to :user
  belongs_to :group
  
end
