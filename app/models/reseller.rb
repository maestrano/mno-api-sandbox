# Static PORO simulating a reseller
class Reseller
  attr_accessor :uid, :created_at, :updated_at, :name, :code, :country

  def initialize
    @uid = 'rsl-449s8fsd'
    @created_at = 4.months.ago
    @updated_at = 10.days.ago
    @name = 'Blue Consulting'
    @code = 'US-204512-BCL'
    @country = 'AU'
  end
end
