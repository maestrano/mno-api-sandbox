class User < ActiveRecord::Base
  attr_accessible :email, :free_trial_end_at, :geo_country_code, :name, :sso_session, :surname, :uid
end
