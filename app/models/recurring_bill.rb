# == Schema Information
#
# Table name: recurring_bills
#
#  id          :integer         not null, primary key
#  uid         :string(255)
#  period      :string(255)
#  frequency   :integer
#  cycles      :integer
#  start_date  :datetime
#  description :string(255)
#  status      :string(255)
#  price_cents :integer
#  currency    :string(255)
#  group_id    :integer(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class RecurringBill < ActiveRecord::Base
  attr_accessible :currency, :cycles, :description, :frequency, :group_id, 
                  :period, :price_cents, :start_date
  
  #===================================
  # Constants
  #===================================
  ACCEPTED_CURRENCIES = Money::Currency.table.keys.map { |k| k.to_s.upcase }
  ACCEPTED_PERIODS = %w(month day week semimonth year)
  STATUSES = %w( pending active cancelled expired )
  
  #===================================
  # Validation rules
  #===================================
  validates :group_id, presence: true, numericality: { only_integer: true }
  validates :currency, presence: true, inclusion: { in: ACCEPTED_CURRENCIES }
  validates :price_cents, :presence => true, :numericality => { only_integer: true, greater_than: 0 }
  validates :description, presence: true
  validates :period, presence: true, inclusion: { in: ACCEPTED_PERIODS }
  validate  :validate_start_date
  
  #============================================
  # Callbacks
  #============================================
  before_validation :set_default_values
  after_create :generate_uid
  
  #============================================
  # Associations
  #============================================
  belongs_to :group
  
  #===================================
  # Status methods
  #===================================
  def active?
    (self.status == 'active' || !self.status)
  end
  
  def cancelled?
    self.status == 'cancelled'
  end
  
  # This methods sets the status of a submitted bill
  # to 'cancelled'
  # If the status of the bill is 'invoiced' then it
  # does nothing and adds an error on status
  def cancel!
    return true if self.cancelled?
    
    self.status = 'cancelled'
    self.save
  end
  
  private
    def validate_start_date
      unless self.start_date > 1.hour.ago
        errors.add(:start_date, "cannot be in the past")
      end
    end
    
    def set_default_values
      self.period ||= ACCEPTED_PERIODS.first
      self.period.downcase!
      self.status = STATUSES.first unless STATUSES.include?(self.status)
      self.start_date ||= Time.now
      self.frequency ||= 1
      self.currency = 'AUD' if self.currency.blank?
    end
    
    # Intialize the UID and save the record
    def generate_uid
      if self.id && !self.uid
        self.uid = "rbill-#{self.id}"
        RecurringBill.update_all({uid:self.uid}, {id: self.id})
      end
      return true
    end
end
