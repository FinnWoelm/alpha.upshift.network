# Extend core Ruby & Rails classes
Dir[File.join(Rails.root, "lib", "core_ext", "*.rb")].each do |extension|
  require extension
end
