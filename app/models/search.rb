class Search

  # search for users by name and weight results
  def self.find_users_by_name query, user = nil
    query = Search.escape_query(query)
    User.
    select("*, CASE #{Search.search_weights_for_user(query, :name)} END as rank").
    where("name ILIKE ?", "%#{query.gsub(' ', '% ')}%").
    merge(User.viewable_by_user(user)).
    order("rank, id")
  end

  # search for users by username and weight results
  def self.find_users_by_username query, user = nil
    query = Search.escape_query(query)
    User.
    select("*, CASE #{Search.search_weights_for_user(query, :username)} END as rank").
    merge(User.viewable_by_user(user)).
    where("username ILIKE ?", "%#{query}%").
    order("rank, id")
  end

  # search for users by username and name and weight results
  def self.find_users_by_username_and_name query, user = nil
    query = Search.escape_query(query)
    User.
    select("*, CASE #{Search.search_weights_for_user(query)} END as rank").
    merge(User.viewable_by_user(user)).
    where("username ILIKE ?", "%#{query}%").
    or(
      User.
      select("*, CASE #{Search.search_weights_for_user(query)} END as rank").
      merge(User.viewable_by_user(user)).
      where("name ILIKE ?", "%#{query.gsub(' ', '% ')}%")
    ).
    order("rank, id")
  end



  private

    # escape ampersands and underscores
    # This is necessary because'% 'and _ have special roles in Postgres' ILIKE
    # syntax. % matches any number of characters and _ matches any single
    # character. By escaping them, we can search for actual % and _ in names.
    def self.escape_query query
      query.gsub("%", "\\%").gsub("_", "\\_")
    end

    # create the CASE WHEN statements used for weighting find_users_by_
    def self.search_weights_for_user query, column = nil
      match_order = {
        :exact_match => "#{query}", # exact match
        :word_match_start => "#{query}:word_separator%", # word match start
        :word_match_end => "%:word_separator#{query}", # word match end
        :word_match_middle => "%:word_separator#{query}:word_separator%", # word match middle
        :partial_match_start => "#{query}%", # partial match start
        :partial_match_end => "%#{query}", # partial match end
        :partial_match_middle => "%#{query}%" # partial match middle
      }

      # create a more complex hash
      match_order = Hash[*match_order.map do |key, value|
        [
          # match strategy for username
          "username_#{key}".to_sym,
          value.
          gsub(":word_separator", "\\_"),

          # match strategy for name
          "name_#{key}".to_sym,
          value.
          gsub(' ', '% '). # allow matches with words in between
          gsub(":word_separator", " ")
        ]
      end.flatten]

      # select only key-value pairs starting with the desired column
      match_order.select! {|key, value| key.to_s.index("#{column.to_s}") == 0} if column.present?

      # construct the WHEN cases, eg:
      # WHEN username ILIKE :exact_match then 1 - 1.0/char_length(username)
      ActiveRecord::Base.send(:sanitize_sql_array,
      [
        match_order.keys.map.with_index(1) { |strategy, index|
          # get the name of the column
          column = strategy[0..strategy.to_s.index("_")-1]
          "
          WHEN #{column} ILIKE :#{strategy} then #{index} - 1.0/char_length(#{column})"
        }.join(""),
        match_order
      ])
    end

end
