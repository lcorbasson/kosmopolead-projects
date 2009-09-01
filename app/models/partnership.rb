class Partnership < ActiveRecord::Base

  # Relations
  belongs_to :user
  belongs_to :partner

end
