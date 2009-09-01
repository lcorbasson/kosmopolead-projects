class Partner < ActiveRecord::Base

  # -- paperclip

  has_attached_file :logo,
    :styles => {:thumb => "70x70>",:original=>"800x600>",:carousel => "250*180"},
    :default_style => :thumb
  
  # -- validation

  validates_attachment_presence :logo
  validates_presence_of :name


  has_many :partnerships, :dependent => :destroy
  has_many :members, :through => :partnerships, :source => :user
  


 

end
