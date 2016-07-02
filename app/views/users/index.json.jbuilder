json.array!(@users) do |user|
  json.extract! user, :id, :email, :username, :name, :last_seen_at
  json.url user_url(user, format: :json)
end
