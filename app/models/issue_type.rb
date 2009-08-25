class IssueType < ActiveRecord::Base

  ALLOW_TYPES = ["ISSUE", "MILESTONE", "STAGE"]

  has_many :issues

  def allow_types
    return ALLOW_TYPES
  end
end
