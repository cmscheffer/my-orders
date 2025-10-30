class PartsController < ApplicationController
  before_action :set_part, only: [:show, :edit, :update, :destroy, :toggle_active]

  def index
    @parts = Part.order(name: :asc)
    
    # Filtros
    @parts = @parts.where(category: params[:category]) if params[:category].present?
    @parts = @parts.where(active: params[:active]) if params[:active].present?
    @parts = @parts.search(params[:search]) if params[:search].present?
    
    # Alerta de estoque baixo
    @low_stock_parts = Part.active.low_stock.count
  end

  def show
    @service_orders = @part.service_orders.recent.limit(10)
  end

  def new
    @part = Part.new
  end

  def edit
  end

  def create
    @part = Part.new(part_params)

    if @part.save
      redirect_to @part, notice: "Peça cadastrada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @part.update(part_params)
      redirect_to @part, notice: "Peça atualizada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @part.service_order_parts.any?
      redirect_to @part, alert: "Não é possível excluir uma peça que já foi utilizada em ordens de serviço."
    else
      @part.destroy
      redirect_to parts_url, notice: "Peça excluída com sucesso."
    end
  end

  def toggle_active
    @part.update(active: !@part.active)
    redirect_to @part, notice: "Status da peça atualizado."
  end

  private

  def set_part
    @part = Part.find(params[:id])
  end

  def part_params
    params.require(:part).permit(
      :name,
      :code,
      :description,
      :brand,
      :category,
      :unit_price,
      :stock_quantity,
      :minimum_stock,
      :unit,
      :active
    )
  end
end
