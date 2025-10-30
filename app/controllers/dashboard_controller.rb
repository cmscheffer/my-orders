class DashboardController < ApplicationController
  def index
    @service_orders = current_user.admin? ? ServiceOrder.all : current_user.service_orders
    
    @total_orders = @service_orders.count
    @pending_orders = @service_orders.pending.count
    @in_progress_orders = @service_orders.in_progress.count
    @completed_orders = @service_orders.completed.count
    @cancelled_orders = @service_orders.cancelled.count
    
    @recent_orders = @service_orders.recent.limit(5)
    @overdue_orders = @service_orders.select(&:overdue?)
  end
end
