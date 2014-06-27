# == Schema Information
#
# Table name: bills
#
#  id                :integer         not null, primary key
#  uid               :string(255)
#  description       :string(255)
#  group_id          :integer
#  price_cents       :integer
#  currency          :string(255)
#  units             :decimal(10, 2)
#  period_started_at :datetime
#  period_ended_at   :datetime
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  status            :string(255)
#

class Bill < ActiveRecord::Base
  attr_accessible :currency, :description, :group_id, :period_ended_at, :period_started_at, :price_cents, :units
  
  #===================================
  # Constants
  #===================================
  ACCEPTED_CURRENCIES = Money::Currency.table.keys.map { |k| k.to_s.upcase }
  STATUSES = %w( submitted cancelled invoiced )
  
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
  before_validation :set_default_values
  after_create :generate_uid
  belongs_to :recurring_bill
  
  #============================================
  # Associations
  #============================================
  belongs_to :group
  
  #===================================
  # Status methods
  #===================================
  def submitted?
    (self.status == 'submitted' || !self.status)
  end
  
  def cancelled?
    self.status == 'cancelled'
  end
  
  def invoiced?
    self.status == 'invoiced'
  end
  
  # This methods sets the status of a submitted bill
  # to 'cancelled'
  # If the status of the bill is 'invoiced' then it
  # does nothing and adds an error on status
  def cancel!
    return true if self.cancelled?
    
    if self.invoiced?
      self.errors.add(:status,"has already been set to invoiced and cannot be changed")
      return false
    else
      self.status = 'cancelled'
      self.save
    end
  end
  
  private
    # Default status to 'submitted' if nil or invalid
    def set_default_values
      self.status = STATUSES.first unless STATUSES.include?(self.status)
      self.currency ||= 'AUD'
    end
    
    # Initialize the UID and save the record
    def generate_uid
      if self.id && !self.uid
        self.uid = "bill-#{self.id}"
        Bill.update_all({uid:self.uid}, {id: self.id})
      end
      return true
    end
    
end
