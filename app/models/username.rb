class Username

  # returns the format for username as a regex
  def self.regex options = {}

    options.reverse_update(
      :anchors => true # anchors default to true
    )

    return Regexp.new "\\A#{self.regex_as_string}\\z" if options[:anchors]
    return Regexp.new self.regex_as_string            if not options[:anchors]
  end

  private

    def self.regex_as_string
      "[a-zA-Z0-9]{1}[a-zA-Z0-9_]{1,24}[a-zA-Z0-9]{1}"
    end

end
