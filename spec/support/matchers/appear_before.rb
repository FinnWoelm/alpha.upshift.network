# tests whether earlier_content appears before later_content
# from http://launchware.com/articles/acceptance-testing-asserting-sort-order
RSpec::Matchers.define :appear_before do |later_content|
  match do |earlier_content|
    rendered.index(earlier_content) < rendered.index(later_content)
  end
end
