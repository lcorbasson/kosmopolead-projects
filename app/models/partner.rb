class Partner < ActiveRecord::Base

  # -- paperclip

   has_attached_file :logo,
    :path => ":rails_root/public#{PaperclipUneek::PAPERCLIP_URL}",
    :url => PaperclipUneek::PAPERCLIP_URL,
#    :default_url => PaperclipUneek::DEFAULT_LOGO_ORGANIZATION,
    :styles => {:thumb => "50x50>",:original=>"800x600>",:carousel => "250*180"},
    :default_style => :thumb
  
  # -- validation

 
  validates_presence_of :name
  named_scope :like, lambda { |like| { :conditions => ["#{Partner.table_name}.name LIKE ?",like] } }


  has_many :partnerships, :dependent => :destroy
  has_many :members, :through => :partnerships, :source => :user

  belongs_to :community
  has_one :project

end
