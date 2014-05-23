# == Schema Information
#
# Table name: bills
#
#  id           :integer         not null, primary key
#  uid          :string(255)
#  description  :string(255)
#  group_id     :integer
#  price_cents  :integer
#  currency     :string(255)
#  units        :decimal(10, 2)
#  period_start :datetime
#  period_end   :datetime
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  status       :string(255)
#

class Bill < ActiveRecord::Base
  attr_accessible :currency, :description, :group_id, :period_end, :period_start, :price_cents, :units
  
  #===================================
  # Constants
  #===================================
  ACCEPTED_CURRENCIES = Money::Currency.table.keys.map { |k| k.to_s.upcase }
  
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
    # Intialize the UID and save the record
    def generate_uid
      if self.id && !self.uid
        self.uid = "bill-#{self.id}"
        Bill.update_all({uid:self.uid}, {id: self.id})
      end
      return true
    end
    
    # Default status to 'submitted' if nil or invalid
    def set_default_values
      self.status = 'submitted' unless STATUSES.include?(self.status)
    end
end
