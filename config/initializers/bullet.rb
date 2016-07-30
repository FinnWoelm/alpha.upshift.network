if defined? Bullet

  if Rails.env.development?
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.alert = true
    Bullet.console = true
    Bullet.rails_logger = true
    Bullet.add_footer = true
  elsif Rails.env.test?
    Bullet.raise = true
  end
end
