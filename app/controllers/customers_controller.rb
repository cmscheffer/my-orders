# frozen_string_literal: true

class CustomersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_customer, only: [:show, :edit, :update, :destroy, :toggle_active]

  def index
    @customers = Customer.all
    
    # Filtros
    @customers = @customers.where(active: true) if params[:active] == 'true'
    @customers = @customers.where(active: false) if params[:active] == 'false'
    
    # Busca
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @customers = @customers.where("name LIKE ? OR email LIKE ? OR phone LIKE ?", 
                                     search_term, search_term, search_term)
    end
    
    # Ordenação
    @customers = case params[:sort]
                 when 'name'
                   @customers.alphabetical
                 when 'recent'
                   @customers.recent
                 else
                   @customers.alphabetical
                 end
    
    # Paginação
    @customers = @customers.page(params[:page]).per(15)
  end

  def show
    @orders = ServiceOrder.where(customer_name: @customer.name)
                         .order(created_at: :desc)
                         .page(params[:page]).per(10)
  end

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.new(customer_params)
    
    if @customer.save
      redirect_to @customer, notice: 'Cliente cadastrado com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @customer.update(customer_params)
      redirect_to @customer, notice: 'Cliente atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @customer.total_orders.zero?
      @customer.destroy
      redirect_to customers_path, notice: 'Cliente excluído com sucesso.'
    else
      redirect_to customers_path, alert: "Não é possível excluir cliente com ordens de serviço. Use 'Inativar' ao invés disso."
    end
  end

  def toggle_active
    @customer.toggle_active!
    status_text = @customer.active? ? 'ativado' : 'inativado'
    redirect_to customers_path, notice: "Cliente #{status_text} com sucesso."
  end

  private

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(
      :name,
      :email,
      :phone,
      :address,
      :city,
      :state,
      :zip_code,
      :notes,
      :active
    )
  end
end
