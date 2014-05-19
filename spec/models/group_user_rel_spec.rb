# == Schema Information
#
# Table name: group_user_rels
#
#  id         :integer         not null, primary key
#  group_id   :integer
#  user_id    :integer
#  role       :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

require 'spec_helper'

describe GroupUserRel do
  pending "add some examples to (or delete) #{__FILE__}"
end
