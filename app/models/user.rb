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
