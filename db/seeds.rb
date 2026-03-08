superadmin_username = "superadmin"
superadmin_email    = "superadmin@gmail.com"
admin_username     = "admin"
admin_email        = "admin@gmail.com"
password           = "password"

User.find_or_create_by!(username: superadmin_username) do |user|
  user.email_address = superadmin_email
  user.password = password
  user.password_confirmation = password
  user.role = "superadmin"
end
User.where(username: superadmin_username).update_all(role: "superadmin")

User.find_or_create_by!(username: admin_username) do |user|
  user.email_address = admin_email
  user.password = password
  user.password_confirmation = password
  user.role = "admin"
end
User.where(username: admin_username).update_all(role: "admin")

puts "Seeded users:"
puts "  Superadmin: #{superadmin_username} / #{password}"
puts "  Admin:      #{admin_username} / #{password}"
