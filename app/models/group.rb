# == Schema Information
#
# Table name: groups
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  uid        :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Group < ActiveRecord::Base
  attr_accessible :name
  
  #============================================
  # Callbacks
  #============================================
  after_create :generate_uid
  
  private
    # Intialize the UID and save the record
    def generate_uid
      if self.id && !self.uid
        self.uid = "cld-#{self.id}"
        Group.update_all({uid:self.uid}, {id: self.id})
      end
      return true
    end
end
