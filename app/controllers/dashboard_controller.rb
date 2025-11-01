# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    # Determinar escopo baseado no papel do usuário
    @scope = current_user.admin? ? ServiceOrder.all : current_user.service_orders

    # Estatísticas gerais
    @stats = calculate_general_stats

    # Estatísticas por status
    @status_stats = calculate_status_stats

    # Estatísticas financeiras
    @financial_stats = calculate_financial_stats

    # Ordens recentes
    @recent_orders = @scope.recent.limit(5)

    # Ordens urgentes e atrasadas
    @urgent_orders = @scope.urgent.where.not(status: [:completed, :cancelled]).limit(5)
    @overdue_orders = @scope.where("due_date < ? AND status NOT IN (?)", 
                                    Date.current, 
                                    ['completed', 'cancelled']).limit(5)

    # Dados para gráficos
    @chart_data = prepare_chart_data
  end

  private

  def calculate_general_stats
    {
      total_orders: @scope.count,
      pending_orders: @scope.pending.count,
      in_progress_orders: @scope.in_progress.count,
      completed_orders: @scope.completed.count,
      cancelled_orders: @scope.cancelled.count,
      overdue_orders: @scope.where("due_date < ? AND status NOT IN (?)", 
                                    Date.current, 
                                    ['completed', 'cancelled']).count,
      urgent_orders: @scope.urgent.where.not(status: [:completed, :cancelled]).count,
      completion_rate: calculate_completion_rate
    }
  end

  def calculate_status_stats
    ServiceOrder.statuses.keys.map do |status|
      {
        status: status,
        count: @scope.where(status: status).count,
        label: I18n.t("activerecord.attributes.service_order.statuses.#{status}", default: status.humanize)
      }
    end
  end

  def calculate_financial_stats
    completed = @scope.completed
    pending = @scope.where.not(status: [:completed, :cancelled])
    
    {
      total_revenue: completed.sum(:total_value),
      pending_revenue: pending.sum(:total_value),
      service_revenue: completed.sum(:service_value),
      parts_revenue: completed.sum(:parts_value),
      average_order_value: completed.average(:total_value).to_f.round(2),
      paid_orders: @scope.payment_status_paid.count,
      pending_payment: @scope.payment_status_pending_payment.count
    }
  end

  def calculate_completion_rate
    total = @scope.count
    return 0 if total.zero?
    
    completed = @scope.completed.count
    ((completed.to_f / total) * 100).round(1)
  end

  def prepare_chart_data
    {
      # Ordens por status (para gráfico de pizza)
      orders_by_status: {
        labels: ServiceOrder.statuses.keys.map { |s| s.humanize },
        data: ServiceOrder.statuses.keys.map { |s| @scope.where(status: s).count }
      },
      
      # Ordens por prioridade (para gráfico de barras)
      orders_by_priority: {
        labels: ServiceOrder.priorities.keys.map { |p| p.humanize },
        data: ServiceOrder.priorities.keys.map { |p| @scope.where(priority: p).count }
      },
      
      # Ordens criadas nos últimos 7 dias (para gráfico de linha)
      orders_last_7_days: {
        labels: (6.days.ago.to_date..Date.current).map { |d| d.strftime('%d/%m') },
        data: (6.days.ago.to_date..Date.current).map do |date|
          @scope.where(created_at: date.beginning_of_day..date.end_of_day).count
        end
      },
      
      # Receita por mês (últimos 6 meses)
      revenue_last_6_months: {
        labels: (5.months.ago.to_date..Date.current).map { |d| d.beginning_of_month }.uniq.map { |d| d.strftime('%b/%y') },
        data: (5.months.ago.to_date..Date.current).map { |d| d.beginning_of_month }.uniq.map do |month_start|
          @scope.completed
                .where(completed_at: month_start..month_start.end_of_month)
                .sum(:total_value)
        end
      }
    }
  end
end
