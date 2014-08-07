# == Schema Information
#
# Table name: groups
#
#  id                :integer         not null, primary key
#  name              :string(255)
#  uid               :string(255)
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  app_id            :integer
#  free_trial_end_at :datetime
#

class Group < ActiveRecord::Base
  attr_accessible :name, :app, :app_id
  
  #============================================
  # Callbacks
  #============================================
  before_create :setup_free_trial
  after_create :generate_uid
  
  #============================================
  # Associations
  #============================================
  belongs_to :app
  has_many :group_user_rels
  has_many :users, through: :group_user_rels
  has_many :bills
  has_many :recurring_bills
  
  private
    # Intialize the UID and save the record
    def generate_uid
      if self.id && !self.uid
        self.uid = "cld-#{self.id}"
        Group.update_all({uid:self.uid}, {id: self.id})
      end
      return true
    end
    
    # Set the end of the free trial based
    def setup_free_trial
      self.free_trial_end_at = Time.now + 1.month
    end
end
