class ActiveSupport::TimeWithZone

  # Prints exact timestamp including milli- & microseconds
  def exact
    self.strftime("%Y-%m-%d %H:%M:%S.%6N %z")
  end

end
