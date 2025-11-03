#!/usr/bin/env ruby
# Script de teste para criação de usuário
# Execute com: rails runner test_user_creation.rb

puts "=" * 80
puts "🧪 TESTE DE CRIAÇÃO DE USUÁRIO"
puts "=" * 80

# Teste 1: Senha fraca
puts "\n📝 Teste 1: Tentando criar usuário com senha FRACA (123456)"
user1 = User.new(
  name: "Teste Usuario",
  email: "teste#{Time.now.to_i}@example.com",
  password: "123456",
  password_confirmation: "123456",
  role: "user"
)

puts "Validando..."
if user1.valid?
  puts "✅ Validação passou (não deveria!)"
else
  puts "❌ Validação falhou (esperado):"
  user1.errors.each do |error|
    puts "  - #{error.attribute}: #{error.message}"
  end
end

# Teste 2: Senha forte
puts "\n📝 Teste 2: Tentando criar usuário com senha FORTE (Senha@123)"
user2 = User.new(
  name: "Teste Usuario Forte",
  email: "teste_forte_#{Time.now.to_i}@example.com",
  password: "Senha@123",
  password_confirmation: "Senha@123",
  role: "user"
)

puts "Validando..."
if user2.valid?
  puts "✅ Validação passou!"
  puts "Tentando salvar no banco..."
  if user2.save
    puts "✅✅ Usuário salvo com sucesso! ID: #{user2.id}"
    puts "Deletando usuário de teste..."
    user2.destroy
    puts "✅ Usuário de teste removido"
  else
    puts "❌ Falha ao salvar:"
    user2.errors.each do |error|
      puts "  - #{error.attribute}: #{error.message}"
    end
  end
else
  puts "❌ Validação falhou:"
  user2.errors.each do |error|
    puts "  - #{error.attribute}: #{error.message}"
  end
end

# Teste 3: Verificar validador de senha
puts "\n📝 Teste 3: Verificando validador de senha"
puts "Requisitos de senha:"
PasswordStrengthValidator.requirements.each_with_index do |req, index|
  puts "  #{index + 1}. #{req}"
end

puts "\n✅ Testes concluídos!"
puts "=" * 80
