#!/bin/bash

echo "🚀 Instalação do Sistema de Ordens de Serviço"
echo "=============================================="
echo ""

# Verificar se Ruby está instalado
if ! command -v ruby &> /dev/null
then
    echo "❌ Ruby não está instalado. Por favor, instale Ruby 3.2 ou superior."
    exit 1
fi

echo "✓ Ruby $(ruby -v) encontrado"
echo ""

# Verificar se Bundler está instalado
if ! command -v bundle &> /dev/null
then
    echo "📦 Instalando Bundler..."
    gem install bundler
fi

echo "✓ Bundler instalado"
echo ""

# Instalar dependências
echo "📦 Instalando dependências (isso pode demorar alguns minutos)..."
bundle install

echo ""
echo "🗄️  Configurando banco de dados..."

# Criar banco de dados
bundle exec rake db:create

# Executar migrations
bundle exec rake db:migrate

# Popular banco de dados
echo ""
read -p "Deseja popular o banco com dados de exemplo? (s/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]
then
    bundle exec rake db:seed
fi

echo ""
echo "✅ Instalação concluída com sucesso!"
echo ""
echo "Para iniciar o servidor de desenvolvimento, execute:"
echo "  bundle exec rails server"
echo ""
echo "Em seguida, acesse: http://localhost:3000"
echo ""
echo "🔐 Credenciais padrão (se você populou o banco):"
echo "   Admin: admin@example.com / 123456"
echo "   Usuário: joao@example.com / 123456"
echo ""
