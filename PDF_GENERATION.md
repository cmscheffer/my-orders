# 📄 Geração de PDF - Ordem de Serviço

## 🎯 Funcionalidade

Sistema completo de geração de PDFs profissionais para ordens de serviço com formatação elegante e todas as informações necessárias.

## ✨ Recursos Incluídos no PDF

### 1. Cabeçalho
- ✅ Título "ORDEM DE SERVIÇO #[ID]"
- ✅ Linha separadora visual

### 2. Informações da Ordem
- ✅ Título da ordem
- ✅ Status (Pendente, Em Andamento, Concluída, Cancelada)
- ✅ Prioridade (Baixa, Média, Alta, Urgente)
- ✅ Data de criação
- ✅ Criado por (nome do usuário)
- ✅ Data de vencimento (se houver)
- ✅ Data de conclusão (se concluída)

### 3. Informações do Cliente
- ✅ Nome do cliente
- ✅ Email do cliente
- ✅ Telefone do cliente

### 4. Informações do Equipamento
- ✅ Nome/Tipo do equipamento
- ✅ Marca
- ✅ Modelo
- ✅ Número de série

### 5. Técnico Responsável
- ✅ Nome do técnico
- ✅ Email do técnico
- ✅ Telefone (formatado)
- ✅ Especialidade

### 6. Tabela de Peças Utilizadas
- ✅ Código da peça
- ✅ Nome da peça
- ✅ Quantidade
- ✅ Preço unitário
- ✅ Total por peça
- ✅ **Total geral de peças** (destacado)

### 7. Resumo Financeiro
- ✅ Valor do serviço
- ✅ Valor das peças
- ✅ Desconto (se houver)
- ✅ **VALOR TOTAL** (destacado em negrito)
- ✅ Status do pagamento
- ✅ Forma de pagamento
- ✅ Data do pagamento

### 8. Descrição Detalhada
- ✅ Descrição completa do serviço
- ✅ Observações adicionais

### 9. Rodapé
- ✅ Linha para assinatura do cliente
- ✅ Data e hora de geração do PDF

## 🛠️ Como Usar

### 1. Visualizar/Baixar PDF de uma Ordem

**Na página de detalhes da ordem:**
```
1. Abra qualquer ordem de serviço
2. Clique no botão "Gerar PDF" (ícone PDF azul)
3. O PDF será aberto em uma nova aba do navegador
4. Você pode visualizar, imprimir ou salvar o arquivo
```

**Na listagem de ordens:**
```
1. Acesse a lista de ordens de serviço
2. Localize a ordem desejada
3. Clique no ícone PDF (azul) na coluna de ações
4. O PDF será aberto em uma nova aba
```

### 2. Imprimir o PDF
```
1. Abra o PDF pelo botão "Gerar PDF"
2. Use Ctrl+P (Windows/Linux) ou Cmd+P (Mac)
3. Configure a impressora e imprima
```

### 3. Enviar PDF por Email
```
1. Gere o PDF
2. Salve o arquivo no computador
3. Anexe em um email para o cliente
```

## 🎨 Características do Design

### Layout Profissional
- 📄 Formato A4 padrão
- 📏 Margens de 40pt em todos os lados
- 📋 Seções bem organizadas e espaçadas
- 🎨 Tabelas com bordas sutis e cabeçalhos destacados

### Formatação de Valores
- 💰 Valores em Real brasileiro (R$)
- 🔢 Formatação com separador de milhar (.)
- 🔢 Duas casas decimais (,)
- 📊 Totais destacados em negrito

### Tradução Completa
- 🇧🇷 Todo texto em português brasileiro
- 📅 Datas no formato brasileiro (DD/MM/AAAA)
- ⏰ Horários no formato 24h

### Espaçamento Inteligente
- ↕️ Seções condicionais (só aparecem se tiverem dados)
- 📐 Espaçamento consistente entre blocos
- 📄 Paginação automática para conteúdo longo

## 🔧 Tecnologias Utilizadas

### Gems
- **prawn** (~> 2.4) - Biblioteca principal para geração de PDF
- **prawn-table** (~> 0.2) - Extensão para criar tabelas

### Service Object
- `ServiceOrderPdfGenerator` - Classe dedicada para gerar PDFs
- Localizada em: `app/services/service_order_pdf_generator.rb`

### Helpers
- `ActionView::Helpers::NumberHelper` - Formatação de valores monetários
- `I18n` - Localização de datas e textos

## 📋 Exemplo de Uso Programático

Se você quiser gerar PDF via console ou em outros contextos:

```ruby
# No Rails console
order = ServiceOrder.find(1)
pdf_content = ServiceOrderPdfGenerator.new(order).generate

# Salvar em arquivo
File.open("ordem_#{order.id}.pdf", "wb") { |f| f.write(pdf_content) }
```

## 🚀 Melhorias Futuras (Sugestões)

Se você quiser expandir a funcionalidade:

1. **Logo da Empresa**
   - Adicionar logo no cabeçalho
   - Configurável via settings

2. **Assinatura Digital**
   - Capturar assinatura do cliente digitalmente
   - Incluir no PDF

3. **QR Code**
   - Adicionar QR code com link para a ordem
   - Facilita acesso rápido

4. **Envio Automático por Email**
   - Botão "Enviar PDF por Email"
   - Email automático para o cliente

5. **Templates Customizáveis**
   - Diferentes layouts de PDF
   - Cliente escolhe o template

6. **Múltiplas Vias**
   - Via cliente, via técnico, via arquivo
   - Marca d'água diferente em cada via

7. **Anexar Fotos**
   - Upload de fotos do equipamento
   - Incluir no PDF

8. **Histórico de Versões**
   - Salvar cada versão do PDF gerada
   - Rastreabilidade de mudanças

## ⚙️ Configurações

### Instalação das Gems

Já adicionadas ao Gemfile:
```ruby
gem "prawn", "~> 2.4"
gem "prawn-table", "~> 0.2"
```

Execute:
```bash
bundle install
```

### Estrutura de Arquivos

```
app/
├── services/
│   └── service_order_pdf_generator.rb  # Gerador de PDF
├── controllers/
│   └── service_orders_controller.rb    # Ação pdf adicionada
└── views/
    └── service_orders/
        ├── show.html.erb               # Botão "Gerar PDF"
        └── index.html.erb              # Ícone PDF na listagem
```

### Rota Adicionada

```ruby
resources :service_orders do
  member do
    get :pdf  # GET /service_orders/:id/pdf
  end
end
```

## 🎯 Casos de Uso

1. **Entrega ao Cliente**
   - Gerar PDF ao concluir o serviço
   - Entregar impresso ou por email

2. **Orçamento**
   - Gerar PDF com valores
   - Enviar para aprovação do cliente

3. **Arquivo/Auditoria**
   - Salvar PDF de todas as ordens
   - Manter histórico físico ou digital

4. **Notas Fiscais**
   - Base para emissão de nota fiscal
   - Documentação do serviço prestado

## 📱 Compatibilidade

✅ Desktop (Windows, Mac, Linux)
✅ Tablets
✅ Smartphones
✅ Impressoras (A4 padrão)

## 🔒 Segurança

- ✅ Requer autenticação (Devise)
- ✅ Apenas usuários logados podem gerar PDFs
- ✅ Validação de permissões do controller
- ✅ Arquivo gerado em tempo real (não armazenado)

## 💡 Dicas

1. **Performance**: PDFs são gerados sob demanda, não armazenados
2. **Customização**: Edite `ServiceOrderPdfGenerator` para mudar layout
3. **Cores**: Modifique códigos hexadecimais para personalizar cores
4. **Fontes**: Prawn usa fontes padrão que suportam português
5. **Testes**: Sempre teste com diferentes tipos de ordens (com/sem peças, técnico, etc.)

## 📞 Suporte

Se encontrar problemas:

1. Verifique se as gems estão instaladas: `bundle list | grep prawn`
2. Teste no console Rails primeiro
3. Verifique logs: `tail -f log/development.log`
4. Valide dados da ordem (todos os campos preenchidos)

---

**Desenvolvido para o Sistema de Ordens de Serviço** 🛠️
