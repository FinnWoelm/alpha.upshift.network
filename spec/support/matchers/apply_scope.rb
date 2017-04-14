# tests whether an ActiveRecord::Relation is applying a particular scope
RSpec::Matchers.define :apply_scope do |scope_to_test|
  match do |relation|

    where_query_to_test, order_by_query_to_test =
      scope_to_test.to_sql.match(/(?:WHERE\s(.*?))?(?:ORDER\sBY\s(.*?))?$/) {|m| m.captures}

    relation.to_sql.include?(where_query_to_test.to_s) and
    relation.to_sql.include?(order_by_query_to_test.to_s)
  end

  failure_message do |relation|
    "expected that\n#{relation.to_sql}\n\nwould include\n#{scope_to_test.to_sql}"
  end
  failure_message_when_negated do |relation|
    "expected that...
    #{relation.to_sql}
    would not include...
    #{scope_to_test.to_sql}"
  end
end
