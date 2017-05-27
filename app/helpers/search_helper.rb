module SearchHelper

  def highlight_query_in string, query
    formatted_string = CGI::escapeHTML(string)
    query = CGI::escapeHTML(ActiveSupport::Inflector.transliterate(query).downcase)

    # split query into separate words
    query.split(" ").each_with_index do |query_fragment, index|

      # prepend query with space unless on first iteration
      separator = index == 0 ? '' : ' '

      # unaccented, case insensitive, and HTML-safe
      clean_string = ActiveSupport::Inflector.transliterate(formatted_string).downcase

      # wrap occurence in tags
      if clean_string.index(separator+query_fragment)
        formatted_string.insert(clean_string.index(separator+query_fragment) + separator.length + query_fragment.length, "</u>")
        formatted_string.insert(clean_string.index(separator+query_fragment) + separator.length, "<u>")
      else
        # if a single occurence is not found, do not highlight anything
        return string
      end
    end

    formatted_string.html_safe
  end
end
