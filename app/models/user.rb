# == Schema Information
#
# Table name: users
#
#  id               :integer          not null, primary key
#  email            :string(255)
#  name             :string(255)
#  surname          :string(255)
#  geo_country_code :string(255)
#  uid              :string(255)
#  sso_session      :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  company          :string(255)
#

class User < ActiveRecord::Base
  attr_accessible :email, :free_trial_end_at, :geo_country_code, :name, :sso_session, :surname, :company

  #============================================
  # Constants
  #============================================
  VALID_COUNTRIES = Country.all.map { |a| a[1] }

  #============================================
  # Validation rules
  #============================================
  validates :email, :presence => true
  validates :name, :presence => true
  validates :surname, :presence => true
  validates :geo_country_code, :presence => true, inclusion: { :in => VALID_COUNTRIES }

  #============================================
  # Callbacks
  #============================================
  before_create :generate_sso_session
  after_create :generate_uid

  #============================================
  # Associations
  #============================================
  has_many :group_user_rels
  has_many :groups, through: :group_user_rels

  # Return a uid that is unique across users and
  # groups
  def virtual_uid(group)
    return "#{self.uid}.#{group.uid}"
  end

  # Return an email that is unique across users and
  # groups
  def virtual_email(group)
    return "#{self.virtual_uid(group)}@mno-api-sandbox-mail.maestrano.com"
  end

  # Return the role of a user for a given group
  def role(group)
    rel = self.group_user_rels.find_by_group_id(group.id)
    return rel ? rel.role : nil
  end

  def generate_sso_session
    self.sso_session = "#{(('a'..'z').to_a + (0..9).to_a).shuffle.join}"
  end

  def generate_sso_session!
    self.generate_sso_session
    self.save
  end

  private
    # Intialize the UID and save the record
    def generate_uid
      if self.id && !self.uid
        self.uid = "usr-#{self.id}"
        User.update_all({uid:self.uid}, {id: self.id})
      end
      return true
    end
end
