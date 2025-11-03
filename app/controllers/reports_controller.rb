# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_date_range, only: [:index, :orders_by_period, :revenue, :technicians, :customers]

  def index
    # Página inicial de relatórios com links para relatórios específicos
  end

  # Relatório de ordens por período
  def orders_by_period
    @scope = current_user.admin? ? ServiceOrder.all : current_user.service_orders
    @orders = @scope.where(created_at: @start_date..@end_date).order(created_at: :desc)
    
    @stats = {
      total: @orders.count,
      by_status: calculate_by_status(@orders),
      by_priority: calculate_by_priority(@orders),
      completed: @orders.completed.count,
      cancelled: @orders.cancelled.count,
      average_completion_time: calculate_average_completion_time(@orders)
    }

    respond_to do |format|
      format.html
      format.xlsx { render_orders_xlsx(@orders) }
      format.pdf { render_orders_pdf(@orders) }
    end
  end

  # Relatório de receita
  def revenue
    @scope = current_user.admin? ? ServiceOrder.all : current_user.service_orders
    @orders = @scope.completed.where(completed_at: @start_date..@end_date).order(completed_at: :desc)
    
    @stats = {
      total_revenue: @orders.sum(:total_value),
      service_revenue: @orders.sum(:service_value),
      parts_revenue: @orders.sum(:parts_value),
      average_order_value: @orders.average(:total_value).to_f.round(2),
      orders_count: @orders.count,
      by_payment_status: calculate_by_payment_status(@orders),
      by_month: calculate_revenue_by_month(@orders)
    }

    respond_to do |format|
      format.html
      format.xlsx { render_revenue_xlsx(@orders, @stats) }
    end
  end

  # Relatório de técnicos
  def technicians
    return redirect_to reports_path, alert: 'Apenas administradores podem acessar este relatório.' unless current_user.admin?
    
    @technicians_data = Technician.all.map do |technician|
      orders = ServiceOrder.where(technician: technician, created_at: @start_date..@end_date)
      
      {
        technician: technician,
        total_orders: orders.count,
        completed: orders.completed.count,
        in_progress: orders.in_progress.count,
        pending: orders.pending.count,
        completion_rate: calculate_completion_rate(orders),
        total_revenue: orders.completed.sum(:total_value),
        average_completion_time: calculate_average_completion_time(orders)
      }
    end

    respond_to do |format|
      format.html
      format.xlsx { render_technicians_xlsx(@technicians_data) }
    end
  end

  # Relatório de clientes
  def customers
    @scope = current_user.admin? ? ServiceOrder.all : current_user.service_orders
    @customers_data = @scope
      .where(created_at: @start_date..@end_date)
      .group(:customer_name, :customer_email, :customer_phone)
      .select('customer_name, customer_email, customer_phone, 
               COUNT(*) as orders_count, 
               SUM(total_value) as total_spent')
      .order('orders_count DESC')

    respond_to do |format|
      format.html
      format.xlsx { render_customers_xlsx(@customers_data) }
    end
  end

  private

  def set_date_range
    @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : 30.days.ago.to_date
    @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.current
  rescue ArgumentError
    @start_date = 30.days.ago.to_date
    @end_date = Date.current
  end

  def calculate_by_status(orders)
    ServiceOrder.statuses.keys.map do |status|
      { status: status, count: orders.where(status: status).count }
    end
  end

  def calculate_by_priority(orders)
    ServiceOrder.priorities.keys.map do |priority|
      { priority: priority, count: orders.where(priority: priority).count }
    end
  end

  def calculate_by_payment_status(orders)
    ServiceOrder.payment_statuses.keys.map do |payment_status|
      { 
        payment_status: payment_status, 
        count: orders.where(payment_status: payment_status).count,
        value: orders.where(payment_status: payment_status).sum(:total_value)
      }
    end
  end

  def calculate_revenue_by_month(orders)
    orders.group_by { |o| o.completed_at.beginning_of_month }.map do |month, month_orders|
      {
        month: month.strftime('%B/%Y'),
        revenue: month_orders.sum(&:total_value),
        orders: month_orders.count
      }
    end
  end

  def calculate_average_completion_time(orders)
    completed_orders = orders.completed.where.not(completed_at: nil)
    return 0 if completed_orders.empty?
    
    total_days = completed_orders.sum do |order|
      (order.completed_at.to_date - order.created_at.to_date).to_i
    end
    
    (total_days.to_f / completed_orders.count).round(1)
  end

  def calculate_completion_rate(orders)
    total = orders.count
    return 0 if total.zero?
    
    completed = orders.completed.count
    ((completed.to_f / total) * 100).round(1)
  end

  # Renderizadores XLSX
  def render_orders_xlsx(orders)
    filename = "relatorio_ordens_#{@start_date.strftime('%Y%m%d')}_#{@end_date.strftime('%Y%m%d')}.xlsx"
    response.headers['Content-Disposition'] = "attachment; filename=#{filename}"
  end

  def render_revenue_xlsx(orders, stats)
    filename = "relatorio_receita_#{@start_date.strftime('%Y%m%d')}_#{@end_date.strftime('%Y%m%d')}.xlsx"
    response.headers['Content-Disposition'] = "attachment; filename=#{filename}"
  end

  def render_technicians_xlsx(technicians_data)
    filename = "relatorio_tecnicos_#{@start_date.strftime('%Y%m%d')}_#{@end_date.strftime('%Y%m%d')}.xlsx"
    response.headers['Content-Disposition'] = "attachment; filename=#{filename}"
  end

  def render_customers_xlsx(customers_data)
    filename = "relatorio_clientes_#{@start_date.strftime('%Y%m%d')}_#{@end_date.strftime('%Y%m%d')}.xlsx"
    response.headers['Content-Disposition'] = "attachment; filename=#{filename}"
  end

  def render_orders_pdf(orders)
    # Implementar geração de PDF se necessário
    # Similar ao ServiceOrderPdfGenerator
  end
end
