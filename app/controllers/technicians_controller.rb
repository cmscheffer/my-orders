class TechniciansController < ApplicationController
  before_action :authenticate_user!
  before_action :set_technician, only: [:show, :edit, :update, :destroy, :toggle_active]

  def index
    @technicians = Technician.all

    # Filtro por nome/email
    if params[:search].present?
      @technicians = @technicians.where(
        "name LIKE ? OR email LIKE ?", 
        "%#{params[:search]}%", 
        "%#{params[:search]}%"
      )
    end

    # Filtro por especialidade
    @technicians = @technicians.by_specialty(params[:specialty]) if params[:specialty].present?

    # Filtro por status
    case params[:status]
    when 'active'
      @technicians = @technicians.active
    when 'inactive'
      @technicians = @technicians.inactive
    end

    @technicians = @technicians.order(created_at: :desc)
  end

  def show
    @service_orders = @technician.service_orders.recent.limit(10)
  end

  def new
    @technician = Technician.new
  end

  def create
    @technician = Technician.new(technician_params)

    if @technician.save
      redirect_to @technician, notice: 'Técnico cadastrado com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @technician.update(technician_params)
      redirect_to @technician, notice: 'Técnico atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @technician.service_orders.any?
      redirect_to @technician, alert: 'Não é possível excluir um técnico que possui ordens de serviço. Considere desativá-lo.'
    else
      @technician.destroy
      redirect_to technicians_path, notice: 'Técnico excluído com sucesso.'
    end
  end

  def toggle_active
    @technician.update(active: !@technician.active)
    redirect_to @technician, notice: "Técnico #{@technician.active? ? 'ativado' : 'desativado'} com sucesso."
  end

  private

  def set_technician
    @technician = Technician.find(params[:id])
  end

  def technician_params
    params.require(:technician).permit(:name, :email, :phone, :specialty, :notes, :active, :user_id)
  end
end
