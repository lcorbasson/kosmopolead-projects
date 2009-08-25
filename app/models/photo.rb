class Photo < ActiveRecord::Base

  # -- relations

  belongs_to :gallery

  # -- named_scope

  named_scope :ordered, :order => ["created_at ASC"]
  named_scope :not_ordered, :order => ["created_at DESC"]

  # -- paperclip

  has_attached_file :photo,    
    :styles => {:thumb => "70x70>",:original=>"800x600>",:carousel => "250*180"},
    :default_style => :thumb

  # -- validation
  
  validates_attachment_presence :photo
  
end
