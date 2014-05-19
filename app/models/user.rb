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

class User < ActiveRecord::Base
  attr_accessible :email, :free_trial_end_at, :geo_country_code, :name, :sso_session, :surname
  
  #============================================
  # Validation rules
  #============================================
  validates :email, :presence => true
  validates :name, :presence => true
  validates :surname, :presence => true
  validates :geo_country_code, :presence => true
  
  #============================================
  # Callbacks
  #============================================
  before_create :setup_free_trial
  after_create :generate_uid
  
  #============================================
  # Associations
  #============================================
  has_many :group_user_rels
  has_many :groups, through: :group_user_rels
  
  private
    # Intialize the UID and save the record
    def generate_uid
      if self.id && !self.uid
        self.uid = "usr-#{self.id}"
        User.update_all({uid:self.uid}, {id: self.id})
      end
      return true
    end
  
    # Set the end of the free trial based
    def setup_free_trial
      self.free_trial_end_at = Time.now + 1.month
    end
end
