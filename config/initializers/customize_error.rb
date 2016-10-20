# Modified from https://gist.github.com/t2/1464315
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|

  html = %(#{html_tag}).html_safe

  elements = Nokogiri::HTML::DocumentFragment.parse(html_tag).css "label, input, textarea"
  elements.each do |e|
    e['class'] ||= ""
    e['class'] += " invalid"
    html = %(#{e}).html_safe
  end

  # return output
  html
end
