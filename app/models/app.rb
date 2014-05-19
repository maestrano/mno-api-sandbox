# == Schema Information
#
# Table name: apps
#
#  id         :integer         not null, primary key
#  api_token  :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class App < ActiveRecord::Base
  
  #============================================
  # Callbacks
  #============================================
  after_create :generate_api_token
  
  private
    # Intialize the api_token
    def generate_api_token
      if self.id && !self.api_token
        self.api_token = "#{(('a'..'z').to_a + (0..9).to_a).shuffle.join}#{self.id}"
        App.update_all({api_token:self.uid}, {id: self.id})
      end
      return true
    end
end
