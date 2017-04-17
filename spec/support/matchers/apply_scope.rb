# tests whether an ActiveRecord::Relation is applying a particular scope
RSpec::Matchers.define :apply_scope do |scope|
  match do |relation|

    # break down the scope into its query components (WHERE, ORDER BY, LIMIT)
    query_components =
      scope.to_sql.
      match(/(?:WHERE\s(.*?))?(?:ORDER\sBY\s(.*?))?(?:LIMIT\s(.*?))?$/) {|m| m.captures}

    # if all our query components are nil, then we must have done something
    # wrong in breaking the scope down into its components
    if query_components.all?(&:nil?)
      raise "Could not find WHERE, ORDER BY, or LIMIT in\n#{scope.to_sql}"
    end

    # check whether all components are included in the relation
    query_components.all? do |component|
      relation.to_sql.include?(component.to_s)
    end
  end

  failure_message do |relation|
    "expected that\n#{relation.to_sql}\n\nwould include\n#{scope.to_sql}"
  end
  failure_message_when_negated do |relation|
    "expected that...
    #{relation.to_sql}
    would not include...
    #{scope_to_test.to_sql}"
  end
end
