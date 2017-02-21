# Modified from https://gist.github.com/t2/1464315
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|

  html = %(#{html_tag}).html_safe

  form_fields = [
    'textarea',
    'input',
    'select'
  ]

  elements = Nokogiri::HTML::DocumentFragment.parse(html_tag).css "label, " + form_fields.join(', ')
  elements.each do |e|

    # add list of errors
    if e.node_name.eql? 'label'
      html += "<ul class='errors browser-default'>".html_safe

      instance.error_message.each do |error|
        html += "<li>#{error}</li>".html_safe
      end

      html += "</ul>".html_safe

    # add class 'invalid'
    elsif form_fields.include? e.node_name
      e['class'] ||= ""
      e['class'] += " invalid"

      html = %(#{e}).html_safe
    end

  end

  # return output
  html
end
