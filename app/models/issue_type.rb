class IssueType < ActiveRecord::Base

  ALLOW_TYPES = ["ISSUE", "MILESTONE", "STAGE"]

  def allow_types
    return ALLOW_TYPES
  end
end
