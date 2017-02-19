# Helper::Dictionary checks a given word against words in the English
# dictionary. The list of words comes from https://github.com/atebits/Words.
#
# To use this inside your app, call:
# `Helper::Dictionary.exists? "house"`
# This returns true or false

class Helper::Dictionary

  def self.exists? word

    # return false if word is not just alphabetical characters (dictionary
    # consists only of alphabetical characters)
    return false unless /^[A-Za-z]+$/.match(word)

    File.open(Rails.root.join("app/resources/dictionary-en.txt")) do |file|
      file.each_line.detect do |line|
        return true if line.strip == word
      end
    end

    return false
  end

end
