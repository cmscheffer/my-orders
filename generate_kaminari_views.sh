#!/bin/bash

echo "🎨 Gerando views do Kaminari para Bootstrap 5..."
echo "================================================"

# Gera as views padrão do Kaminari
bundle exec rails generate kaminari:views bootstrap5

echo ""
echo "✅ Views do Kaminari geradas com sucesso!"
echo ""
echo "As views foram criadas em: app/views/kaminari/"
echo ""
