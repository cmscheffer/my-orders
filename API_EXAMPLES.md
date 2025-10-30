# 🔌 Exemplos de API - Sistema de Ordens de Serviço

Este documento contém exemplos de como expandir o sistema para incluir uma API REST.

> **Nota:** Atualmente o sistema não possui API REST implementada. Este documento serve como guia para implementação futura.

## 📋 Índice

- [Autenticação](#autenticação)
- [Endpoints de Ordens de Serviço](#endpoints-de-ordens-de-serviço)
- [Implementação](#implementação)

---

## 🔐 Autenticação

### Adicionar Token-based Authentication

**1. Adicionar gem ao Gemfile:**

```ruby
gem 'devise-api', '~> 0.1'
# ou
gem 'jwt', '~> 2.7'
```

**2. Gerar token para usuário:**

```ruby
# app/models/user.rb
def generate_jwt
  JWT.encode(
    { id: id, exp: 24.hours.from_now.to_i },
    Rails.application.credentials.secret_key_base
  )
end
```

**3. Endpoint de Login:**

```ruby
# POST /api/v1/auth/login
{
  "email": "admin@example.com",
  "password": "123456"
}

# Response:
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "name": "Administrador",
    "email": "admin@example.com",
    "role": "admin"
  }
}
```

---

## 📦 Endpoints de Ordens de Serviço

### GET /api/v1/service_orders

**Listar todas as ordens de serviço**

```bash
curl -X GET http://localhost:3000/api/v1/service_orders \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

**Response:**

```json
{
  "service_orders": [
    {
      "id": 1,
      "title": "Manutenção de Servidor",
      "description": "Realizar manutenção preventiva...",
      "status": "in_progress",
      "priority": "high",
      "due_date": "2024-01-15",
      "customer_name": "Empresa Tech Solutions",
      "customer_email": "contato@techsolutions.com",
      "customer_phone": "(11) 98765-4321",
      "user": {
        "id": 1,
        "name": "Administrador"
      },
      "created_at": "2024-01-01T10:00:00.000Z",
      "updated_at": "2024-01-10T15:30:00.000Z"
    }
  ],
  "meta": {
    "total": 10,
    "page": 1,
    "per_page": 20
  }
}
```

### GET /api/v1/service_orders/:id

**Obter detalhes de uma ordem específica**

```bash
curl -X GET http://localhost:3000/api/v1/service_orders/1 \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

**Response:**

```json
{
  "service_order": {
    "id": 1,
    "title": "Manutenção de Servidor",
    "description": "Realizar manutenção preventiva nos servidores...",
    "status": "in_progress",
    "priority": "high",
    "due_date": "2024-01-15",
    "completed_at": null,
    "customer_name": "Empresa Tech Solutions",
    "customer_email": "contato@techsolutions.com",
    "customer_phone": "(11) 98765-4321",
    "user": {
      "id": 1,
      "name": "Administrador",
      "email": "admin@example.com"
    },
    "created_at": "2024-01-01T10:00:00.000Z",
    "updated_at": "2024-01-10T15:30:00.000Z"
  }
}
```

### POST /api/v1/service_orders

**Criar nova ordem de serviço**

```bash
curl -X POST http://localhost:3000/api/v1/service_orders \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "service_order": {
      "title": "Nova Ordem de Serviço",
      "description": "Descrição detalhada da ordem",
      "status": "pending",
      "priority": "medium",
      "due_date": "2024-02-01",
      "customer_name": "Cliente Exemplo",
      "customer_email": "cliente@exemplo.com",
      "customer_phone": "(11) 99999-9999"
    }
  }'
```

**Response:**

```json
{
  "service_order": {
    "id": 11,
    "title": "Nova Ordem de Serviço",
    "description": "Descrição detalhada da ordem",
    "status": "pending",
    "priority": "medium",
    "due_date": "2024-02-01",
    "customer_name": "Cliente Exemplo",
    "customer_email": "cliente@exemplo.com",
    "customer_phone": "(11) 99999-9999",
    "user_id": 1,
    "created_at": "2024-01-15T10:00:00.000Z",
    "updated_at": "2024-01-15T10:00:00.000Z"
  },
  "message": "Ordem de serviço criada com sucesso"
}
```

### PUT /api/v1/service_orders/:id

**Atualizar ordem de serviço existente**

```bash
curl -X PUT http://localhost:3000/api/v1/service_orders/1 \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "service_order": {
      "status": "completed",
      "completed_at": "2024-01-15T16:00:00Z"
    }
  }'
```

**Response:**

```json
{
  "service_order": {
    "id": 1,
    "title": "Manutenção de Servidor",
    "status": "completed",
    "completed_at": "2024-01-15T16:00:00.000Z",
    ...
  },
  "message": "Ordem de serviço atualizada com sucesso"
}
```

### DELETE /api/v1/service_orders/:id

**Excluir ordem de serviço**

```bash
curl -X DELETE http://localhost:3000/api/v1/service_orders/1 \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

**Response:**

```json
{
  "message": "Ordem de serviço excluída com sucesso"
}
```

### PATCH /api/v1/service_orders/:id/complete

**Marcar ordem como concluída**

```bash
curl -X PATCH http://localhost:3000/api/v1/service_orders/1/complete \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

**Response:**

```json
{
  "service_order": {
    "id": 1,
    "status": "completed",
    "completed_at": "2024-01-15T16:00:00.000Z"
  },
  "message": "Ordem marcada como concluída"
}
```

### PATCH /api/v1/service_orders/:id/cancel

**Cancelar ordem**

```bash
curl -X PATCH http://localhost:3000/api/v1/service_orders/1/cancel \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

---

## 🛠️ Implementação

### 1. Criar namespace API

```bash
rails generate controller Api::V1::ServiceOrders
rails generate controller Api::V1::Auth
```

### 2. Configurar rotas

```ruby
# config/routes.rb
Rails.application.routes.draw do
  devise_for :users
  
  # API namespace
  namespace :api do
    namespace :v1 do
      # Auth
      post 'auth/login', to: 'auth#login'
      post 'auth/signup', to: 'auth#signup'
      delete 'auth/logout', to: 'auth#logout'
      
      # Service Orders
      resources :service_orders do
        member do
          patch :complete
          patch :cancel
        end
      end
      
      # Dashboard
      get 'dashboard', to: 'dashboard#index'
    end
  end
  
  # Web routes
  root "service_orders#index"
  resources :service_orders
end
```

### 3. Controller API Base

```ruby
# app/controllers/api/v1/base_controller.rb
module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_request
      
      private
      
      def authenticate_request
        header = request.headers['Authorization']
        token = header.split(' ').last if header
        
        begin
          decoded = JWT.decode(
            token,
            Rails.application.credentials.secret_key_base,
            true,
            { algorithm: 'HS256' }
          )
          @current_user = User.find(decoded[0]['id'])
        rescue JWT::DecodeError, ActiveRecord::RecordNotFound
          render json: { error: 'Não autorizado' }, status: :unauthorized
        end
      end
      
      def current_user
        @current_user
      end
    end
  end
end
```

### 4. Controller de Autenticação

```ruby
# app/controllers/api/v1/auth_controller.rb
module Api
  module V1
    class AuthController < BaseController
      skip_before_action :authenticate_request, only: [:login, :signup]
      
      def login
        user = User.find_by(email: params[:email])
        
        if user&.valid_password?(params[:password])
          token = user.generate_jwt
          render json: {
            token: token,
            user: user.as_json(only: [:id, :name, :email, :role])
          }, status: :ok
        else
          render json: { error: 'Email ou senha inválidos' }, status: :unauthorized
        end
      end
      
      def signup
        user = User.new(user_params)
        
        if user.save
          token = user.generate_jwt
          render json: {
            token: token,
            user: user.as_json(only: [:id, :name, :email, :role])
          }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      private
      
      def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end
    end
  end
end
```

### 5. Controller de Service Orders API

```ruby
# app/controllers/api/v1/service_orders_controller.rb
module Api
  module V1
    class ServiceOrdersController < BaseController
      before_action :set_service_order, only: [:show, :update, :destroy, :complete, :cancel]
      
      def index
        @service_orders = current_user.admin? ? ServiceOrder.all : current_user.service_orders
        @service_orders = @service_orders.recent
        
        render json: {
          service_orders: @service_orders.as_json(include: { user: { only: [:id, :name] } }),
          meta: {
            total: @service_orders.count,
            page: 1,
            per_page: 20
          }
        }
      end
      
      def show
        render json: {
          service_order: @service_order.as_json(include: { user: { only: [:id, :name, :email] } })
        }
      end
      
      def create
        @service_order = current_user.service_orders.build(service_order_params)
        
        if @service_order.save
          render json: {
            service_order: @service_order,
            message: 'Ordem de serviço criada com sucesso'
          }, status: :created
        else
          render json: { errors: @service_order.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def update
        if @service_order.update(service_order_params)
          render json: {
            service_order: @service_order,
            message: 'Ordem de serviço atualizada com sucesso'
          }
        else
          render json: { errors: @service_order.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def destroy
        @service_order.destroy
        render json: { message: 'Ordem de serviço excluída com sucesso' }
      end
      
      def complete
        if @service_order.mark_as_completed!
          render json: {
            service_order: @service_order,
            message: 'Ordem marcada como concluída'
          }
        else
          render json: { error: 'Não foi possível concluir a ordem' }, status: :unprocessable_entity
        end
      end
      
      def cancel
        if @service_order.mark_as_cancelled!
          render json: {
            service_order: @service_order,
            message: 'Ordem cancelada'
          }
        else
          render json: { error: 'Não foi possível cancelar a ordem' }, status: :unprocessable_entity
        end
      end
      
      private
      
      def set_service_order
        @service_order = ServiceOrder.find(params[:id])
      end
      
      def service_order_params
        params.require(:service_order).permit(
          :title, :description, :status, :priority, :due_date,
          :customer_name, :customer_email, :customer_phone
        )
      end
    end
  end
end
```

### 6. Adicionar JWT ao User Model

```ruby
# app/models/user.rb
class User < ApplicationRecord
  # ... código existente ...
  
  def generate_jwt
    payload = {
      id: id,
      email: email,
      role: role,
      exp: 24.hours.from_now.to_i
    }
    JWT.encode(payload, Rails.application.credentials.secret_key_base, 'HS256')
  end
end
```

---

## 🧪 Testando a API

### Com cURL

```bash
# Login
TOKEN=$(curl -s -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"123456"}' \
  | jq -r '.token')

# Usar token
curl -X GET http://localhost:3000/api/v1/service_orders \
  -H "Authorization: Bearer $TOKEN"
```

### Com Postman

1. Criar collection "Service Orders API"
2. Adicionar variável `{{base_url}}` = `http://localhost:3000/api/v1`
3. Adicionar variável `{{token}}` (será preenchida após login)
4. Criar requests para cada endpoint

---

## 📚 Documentação Adicional

Para documentar sua API, considere usar:

- **Swagger/OpenAPI:** gem 'rswag'
- **API Blueprint:** gem 'apipie-rails'
- **Postman Collection:** Exportar e compartilhar

---

**Nota:** Este é um guia básico. Para produção, considere adicionar:
- Rate limiting
- Versionamento de API
- Paginação
- Filtros avançados
- Webhooks
- CORS configurado adequadamente
