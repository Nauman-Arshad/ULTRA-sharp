admin_username = "admin"
admin_email    = "admin@example.com"
admin_password = "password"

User.find_or_create_by!(username: admin_username) do |user|
  user.email_address = admin_email
  user.password = admin_password
  user.password_confirmation = admin_password
end

puts "Seeded admin user:"
puts "  username: #{admin_username}"
puts "  password: #{admin_password}"
