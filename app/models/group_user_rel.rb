class GroupUserRel < ActiveRecord::Base
  attr_accessible :group_id, :role, :user_id
end