class Bill < ActiveRecord::Base
  attr_accessible :currency, :description, :group_id, :period_end, :period_start, :price_cents, :units
  
  #===================================
  # Validation rules
  #===================================
  validates :group_id, :presence => true, :numericality => { :only_integer => true }
  validates :currency, :presence => true, :inclusion => { :in => ACCEPTED_CURRENCIES }
  validates :units, numericality: { greater_than: 0 }, unless: '!self.units'
  validates :price_cents, :presence => true, :numericality => { only_integer: true, greater_than: 0 }
  validates :description, presence: true
  
  #============================================
  # Callbacks
  #============================================
  after_create :generate_uid
  
  #============================================
  # Associations
  #============================================
  belongs_to :group
  
  private
    # Intialize the UID and save the record
    def generate_uid
      if self.id && !self.uid
        self.uid = "bill-#{self.id}"
        Bill.update_all({uid:self.uid}, {id: self.id})
      end
      return true
    end
  
end
