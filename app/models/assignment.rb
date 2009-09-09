class Assignment < ActiveRecord::Base

  # -- relations
  
  belongs_to :issue
  belongs_to :user,:class_name => 'User', :foreign_key => 'user_id'
 

  # appelé lors de la création ou l'édition d'une tache
  def self.exist?(issue_id, user_id)
     Assignment.find(:first, :conditions=>["issue_id = ? AND user_id = ?", issue_id, user_id])
  end

  # appelé lors de la création ou l'édition d'une tache
  def self.delete(issue)
    issue.assignments.each do |assignment|
      assignment.destroy
    end
    issue.save
  end
  
end
