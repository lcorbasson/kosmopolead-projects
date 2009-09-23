# introduit pour gérer les communautés
class CommunityUser < User
  acts_as_tree :order => "lastname"
  
  has_many :user_memberships, :class_name => 'CommunityMembership'
  has_many :users, :through => :user_memberships

  def name
    "Communauté #{lastname}"
  end

  # Overrides a few properties
  def logged?; false end
  def admin; false end
  def rss_key; nil end
end