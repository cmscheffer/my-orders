# frozen_string_literal: true

puts "🌱 Iniciando seed do banco de dados..."

# Criar usuários
puts "\n👤 Criando usuários..."

admin = User.find_or_create_by!(email: "admin@example.com") do |user|
  user.name = "Administrador"
  user.password = "123456"
  user.password_confirmation = "123456"
  user.role = :admin
end
puts "✓ Admin criado: #{admin.email}"

user1 = User.find_or_create_by!(email: "joao@example.com") do |user|
  user.name = "João Silva"
  user.password = "123456"
  user.password_confirmation = "123456"
end
puts "✓ Usuário criado: #{user1.email}"

user2 = User.find_or_create_by!(email: "maria@example.com") do |user|
  user.name = "Maria Santos"
  user.password = "123456"
  user.password_confirmation = "123456"
end
puts "✓ Usuário criado: #{user2.email}"

# Criar ordens de serviço
puts "\n📋 Criando ordens de serviço..."

# OS do admin
ServiceOrder.find_or_create_by!(
  title: "Manutenção de Servidor",
  user: admin
) do |os|
  os.description = "Realizar manutenção preventiva nos servidores de produção. Incluir verificação de logs, atualização de segurança e backup completo."
  os.status = :in_progress
  os.priority = :high
  os.due_date = Date.today + 3.days
  os.customer_name = "Empresa Tech Solutions"
  os.customer_email = "contato@techsolutions.com"
  os.customer_phone = "(11) 98765-4321"
  os.equipment_name = "Servidor"
  os.equipment_brand = "Dell"
  os.equipment_model = "PowerEdge R740"
  os.equipment_serial = "SRV2023001"
  os.service_value = 800.00
  os.parts_value = 350.00
  os.payment_status = :pending_payment
  os.payment_method = "Transferência Bancária"
end
puts "✓ OS criada: Manutenção de Servidor"

ServiceOrder.find_or_create_by!(
  title: "Instalação de Software",
  user: admin
) do |os|
  os.description = "Instalar e configurar novo sistema de gestão nas estações de trabalho do cliente."
  os.status = :pending
  os.priority = :medium
  os.due_date = Date.today + 7.days
  os.customer_name = "Comercial ABC"
  os.customer_email = "ti@comercialabc.com"
  os.customer_phone = "(11) 93456-7890"
  os.equipment_name = "Desktop"
  os.equipment_brand = "Lenovo"
  os.equipment_model = "ThinkCentre M720"
  os.equipment_serial = "PC2023045"
  os.service_value = 250.00
  os.parts_value = 0.00
  os.payment_status = :pending_payment
  os.payment_method = "PIX"
end
puts "✓ OS criada: Instalação de Software"

# OS do user1
ServiceOrder.find_or_create_by!(
  title: "Reparo de Impressora",
  user: user1
) do |os|
  os.description = "Impressora HP Laserjet com problema de alimentação de papel. Cliente relatou atolamentos frequentes."
  os.status = :pending
  os.priority = :low
  os.due_date = Date.today + 5.days
  os.customer_name = "Escritório Advocacia Silva"
  os.customer_email = "admin@silvadvocacia.com"
  os.customer_phone = "(11) 94567-8901"
  os.equipment_name = "Impressora"
  os.equipment_brand = "HP"
  os.equipment_model = "LaserJet Pro M404dn"
  os.equipment_serial = "BRNB4C001234"
  os.service_value = 120.00
  os.parts_value = 85.00
  os.payment_status = :pending_payment
end
puts "✓ OS criada: Reparo de Impressora"

ServiceOrder.find_or_create_by!(
  title: "Configuração de Rede",
  user: user1
) do |os|
  os.description = "Configurar nova rede WiFi corporativa com segregação de VLANs para diferentes departamentos."
  os.status = :in_progress
  os.priority = :urgent
  os.due_date = Date.today + 1.day
  os.customer_name = "Indústria Metalúrgica XYZ"
  os.customer_email = "ti@metalurgicaxyz.com"
  os.customer_phone = "(11) 95678-9012"
  os.equipment_name = "Roteador"
  os.equipment_brand = "Cisco"
  os.equipment_model = "RV340"
  os.equipment_serial = "FCW2345G0T5"
  os.service_value = 650.00
  os.parts_value = 1200.00
  os.payment_status = :partially_paid
  os.payment_method = "Cartão de Crédito"
  os.payment_date = Date.today - 2.days
  os.notes = "Cliente pagou 50% adiantado no cartão."
end
puts "✓ OS criada: Configuração de Rede"

# OS do user2
ServiceOrder.find_or_create_by!(
  title: "Backup de Dados",
  user: user2
) do |os|
  os.description = "Realizar backup completo dos dados do servidor de arquivos. Total estimado: 2TB."
  os.status = :completed
  os.priority = :high
  os.due_date = Date.today - 2.days
  os.completed_at = Time.current
  os.customer_name = "Clínica Médica Saúde+"
  os.customer_email = "ti@saudemais.com"
  os.customer_phone = "(11) 96789-0123"
  os.equipment_name = "Servidor de Arquivos"
  os.equipment_brand = "HP"
  os.equipment_model = "ProLiant ML350 Gen10"
  os.equipment_serial = "BR45XY789012"
  os.service_value = 450.00
  os.parts_value = 0.00
  os.payment_status = :paid
  os.payment_method = "Dinheiro"
  os.payment_date = Date.today - 1.day
end
puts "✓ OS criada: Backup de Dados (Concluída)"

ServiceOrder.find_or_create_by!(
  title: "Suporte Técnico Remoto",
  user: user2
) do |os|
  os.description = "Prestar suporte remoto para resolução de problemas com Microsoft Office e VPN."
  os.status = :cancelled
  os.priority = :medium
  os.due_date = Date.today - 1.day
  os.customer_name = "Consultoria Empresarial ABC"
  os.customer_email = "suporte@consultoriaabc.com"
  os.customer_phone = "(11) 97890-1234"
  os.equipment_name = "Notebook"
  os.equipment_brand = "Dell"
  os.equipment_model = "Latitude 5420"
  os.equipment_serial = "5CD0123ABC"
  os.service_value = 150.00
  os.parts_value = 0.00
  os.payment_status = :cancelled_payment
  os.notes = "Ordem cancelada a pedido do cliente."
end
puts "✓ OS criada: Suporte Técnico Remoto (Cancelada)"

ServiceOrder.find_or_create_by!(
  title: "Formatação de Computador",
  user: user2
) do |os|
  os.description = "Formatação completa e reinstalação do Windows 11 com drivers e programas básicos."
  os.status = :pending
  os.priority = :low
  os.due_date = Date.today + 10.days
  os.customer_name = "José Carlos Oliveira"
  os.customer_email = "jc.oliveira@email.com"
  os.customer_phone = "(11) 98901-2345"
  os.equipment_name = "Computador Desktop"
  os.equipment_brand = "Positivo"
  os.equipment_model = "Master D640"
  os.equipment_serial = "POS2023789"
  os.service_value = 180.00
  os.parts_value = 0.00
  os.payment_status = :pending_payment
  os.payment_method = "Boleto"
end
puts "✓ OS criada: Formatação de Computador"

# Estatísticas
puts "\n📊 Estatísticas:"
puts "   Total de usuários: #{User.count}"
puts "   Total de ordens de serviço: #{ServiceOrder.count}"
puts "   OS Pendentes: #{ServiceOrder.pending.count}"
puts "   OS Em Andamento: #{ServiceOrder.in_progress.count}"
puts "   OS Concluídas: #{ServiceOrder.completed.count}"
puts "   OS Canceladas: #{ServiceOrder.cancelled.count}"

puts "\n✅ Seed concluído com sucesso!"
puts "\n🔐 Credenciais de acesso:"
puts "   Admin: admin@example.com / 123456"
puts "   Usuário 1: joao@example.com / 123456"
puts "   Usuário 2: maria@example.com / 123456"
