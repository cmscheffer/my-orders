class ServiceOrdersController < ApplicationController
  before_action :set_service_order, only: [:show, :edit, :update, :destroy, :complete, :cancel]
  before_action :authorize_user!, only: [:edit, :update, :destroy]

  # GET /service_orders
  def index
    @service_orders = current_user.admin? ? ServiceOrder.all : current_user.service_orders
    @service_orders = @service_orders.recent

    # Filters
    @service_orders = @service_orders.by_status(params[:status]) if params[:status].present?
    @service_orders = @service_orders.by_priority(params[:priority]) if params[:priority].present?

    @service_orders = @service_orders.page(params[:page]).per(10) if defined?(Kaminari)
  end

  # GET /service_orders/1
  def show
  end

  # GET /service_orders/new
  def new
    @service_order = current_user.service_orders.build
  end

  # GET /service_orders/1/edit
  def edit
  end

  # POST /service_orders
  def create
    @service_order = current_user.service_orders.build(service_order_params)

    if @service_order.save
      redirect_to @service_order, notice: "Ordem de serviço criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /service_orders/1
  def update
    if @service_order.update(service_order_params)
      redirect_to @service_order, notice: "Ordem de serviço atualizada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /service_orders/1
  def destroy
    @service_order.destroy
    redirect_to service_orders_url, notice: "Ordem de serviço excluída com sucesso."
  end

  # PATCH /service_orders/1/complete
  def complete
    if @service_order.mark_as_completed!
      redirect_to @service_order, notice: "Ordem de serviço marcada como concluída."
    else
      redirect_to @service_order, alert: "Não foi possível concluir a ordem de serviço."
    end
  end

  # PATCH /service_orders/1/cancel
  def cancel
    if @service_order.mark_as_cancelled!
      redirect_to @service_order, notice: "Ordem de serviço cancelada."
    else
      redirect_to @service_order, alert: "Não foi possível cancelar a ordem de serviço."
    end
  end

  private

  def set_service_order
    @service_order = ServiceOrder.find(params[:id])
  end

  def authorize_user!
    unless current_user.admin? || @service_order.user == current_user
      redirect_to service_orders_path, alert: "Você não tem permissão para realizar esta ação."
    end
  end

  def service_order_params
    params.require(:service_order).permit(
      :title,
      :description,
      :status,
      :priority,
      :due_date,
      :customer_name,
      :customer_email,
      :customer_phone,
      :equipment_name,
      :equipment_brand,
      :equipment_model,
      :equipment_serial,
      :service_value,
      :parts_value,
      :payment_status,
      :payment_method,
      :payment_date,
      :notes,
      :technician_id,
      service_order_parts_attributes: [:id, :part_id, :quantity, :unit_price, :_destroy]
    )
  end
end
