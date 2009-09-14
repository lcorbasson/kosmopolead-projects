class Partner < ActiveRecord::Base

  # -- paperclip

  has_attached_file :logo,
    :styles => {:thumb => "50x50>",:original=>"800x600>",:carousel => "250*180"},
    :default_style => :thumb
  
  # -- validation

 
  validates_presence_of :name


  has_many :partnerships, :dependent => :destroy
  has_many :members, :through => :partnerships, :source => :user
  


 

end
