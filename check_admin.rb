# Script para verificar usuário admin
puts "=" * 80
puts "🔍 VERIFICANDO USUÁRIOS ADMIN"
puts "=" * 80

User.all.each do |user|
  puts "\nUsuário: #{user.name}"
  puts "  Email: #{user.email}"
  puts "  Role: #{user.role}"
  puts "  Admin? #{user.admin?}"
  puts "  ID: #{user.id}"
end

puts "\n" + "=" * 80
puts "Total de usuários: #{User.count}"
puts "Total de admins: #{User.where(role: 'admin').count}"
puts "=" * 80
