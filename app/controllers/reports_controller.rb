class ReportsController < ApplicationController
  before_action :authenticate_user!

  def index
    # Página principal de relatórios
  end

  def completed_orders
    # Buscar ordens concluídas
    @service_orders = ServiceOrder.completed.includes(:user, :technician, :service_order_parts, :parts)

    # Filtro por técnico
    if params[:technician_id].present?
      @service_orders = @service_orders.where(technician_id: params[:technician_id])
      @selected_technician = Technician.find_by(id: params[:technician_id])
    end

    # Filtro por período de conclusão
    if params[:start_date].present?
      start_date = Date.parse(params[:start_date]) rescue nil
      @service_orders = @service_orders.where("completed_at >= ?", start_date.beginning_of_day) if start_date
      @start_date = params[:start_date]
    end

    if params[:end_date].present?
      end_date = Date.parse(params[:end_date]) rescue nil
      @service_orders = @service_orders.where("completed_at <= ?", end_date.end_of_day) if end_date
      @end_date = params[:end_date]
    end

    # Ordenar por data de conclusão (mais recentes primeiro)
    @service_orders = @service_orders.order(completed_at: :desc)

    # Calcular estatísticas
    calculate_statistics

    # Preparar dados para o gráfico
    prepare_chart_data

    respond_to do |format|
      format.html
      format.pdf do
        pdf = CompletedOrdersReportPdf.new(@service_orders, @statistics, @selected_technician, @start_date, @end_date)
        send_data pdf.generate,
                  filename: "relatorio_ordens_concluidas_#{Date.current.strftime('%Y%m%d')}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline'
      end
    end
  end

  private

  def calculate_statistics
    @statistics = {
      total_orders: @service_orders.count,
      total_revenue: @service_orders.sum(:total_value) || 0,
      total_service_value: @service_orders.sum(:service_value) || 0,
      total_parts_value: @service_orders.sum(:parts_value) || 0,
      average_order_value: @service_orders.count > 0 ? (@service_orders.sum(:total_value) || 0) / @service_orders.count : 0,
      paid_orders: @service_orders.where(payment_status: :paid).count,
      pending_payment: @service_orders.where(payment_status: :pending_payment).count,
      total_paid: @service_orders.where(payment_status: :paid).sum(:total_value) || 0,
      total_pending: @service_orders.where(payment_status: :pending_payment).sum(:total_value) || 0
    }

    # Estatísticas por técnico (se não houver filtro de técnico)
    unless @selected_technician
      @technician_stats = @service_orders.group(:technician_id).count
                                        .map { |tech_id, count| 
                                          tech = Technician.find_by(id: tech_id)
                                          { technician: tech, count: count } if tech
                                        }.compact
                                        .sort_by { |stat| -stat[:count] }
    end

    # Top 5 peças mais utilizadas
    @top_parts = ServiceOrderPart.joins(:part, :service_order)
                                  .where(service_order_id: @service_orders.pluck(:id))
                                  .group(:part_id)
                                  .select('part_id, SUM(quantity) as total_quantity, SUM(total_price) as total_revenue')
                                  .order('total_quantity DESC')
                                  .limit(5)
                                  .map { |sop| 
                                    part = Part.find_by(id: sop.part_id)
                                    {
                                      part: part,
                                      quantity: sop.total_quantity,
                                      revenue: sop.total_revenue
                                    } if part
                                  }.compact
  end

  def prepare_chart_data
    # Dados para gráfico de ordens por dia
    @orders_by_day = @service_orders.group_by { |order| order.completed_at.to_date }
                                    .transform_values(&:count)
                                    .sort_by { |date, _| date }

    # Dados para gráfico de receita por dia
    @revenue_by_day = @service_orders.group_by { |order| order.completed_at.to_date }
                                     .transform_values { |orders| orders.sum(&:total_value) }
                                     .sort_by { |date, _| date }
  end
end
