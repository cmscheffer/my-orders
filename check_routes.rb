# Script para verificar rotas
puts "=" * 80
puts "🔍 VERIFICANDO ROTAS DE USERS"
puts "=" * 80

routes = Rails.application.routes.routes
users_routes = routes.select { |r| r.path.spec.to_s.include?('/users') }

users_routes.each do |route|
  puts "\nVerbo: #{route.verb}"
  puts "Path: #{route.path.spec}"
  puts "Controller#Action: #{route.defaults[:controller]}##{route.defaults[:action]}"
  puts "Name: #{route.name}" if route.name
  puts "-" * 40
end

puts "\n" + "=" * 80
puts "Total de rotas /users: #{users_routes.count}"
puts "=" * 80
