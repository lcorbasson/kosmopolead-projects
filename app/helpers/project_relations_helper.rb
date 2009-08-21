module ProjectRelationsHelper

  def collection_for_relation_type_select
    values = ProjectRelation::TYPES
    values.keys.sort{|x,y| values[x][:order] <=> values[y][:order]}.collect{|k| [l(values[k][:name]), k]}
  end

end