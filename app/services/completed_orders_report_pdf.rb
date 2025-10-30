class CompletedOrdersReportPdf
  include ActionView::Helpers::NumberHelper
  
  def initialize(service_orders, statistics, technician = nil, customer = nil, start_date = nil, end_date = nil)
    @service_orders = service_orders
    @statistics = statistics
    @technician = technician
    @customer = customer
    @start_date = start_date
    @end_date = end_date
    @pdf = Prawn::Document.new(page_size: 'A4', margin: 40, page_layout: :landscape)
  end

  def generate
    add_header
    add_filters_info
    add_statistics
    add_orders_table
    add_footer
    
    @pdf.render
  end

  private

  def add_header
    @pdf.text "RELATÓRIO DE ORDENS CONCLUÍDAS", size: 20, style: :bold, align: :center
    @pdf.move_down 5
    @pdf.text "Gerado em #{I18n.l(Time.current, format: :long)}", size: 10, align: :center, style: :italic
    @pdf.stroke_horizontal_rule
    @pdf.move_down 20
  end

  def add_filters_info
    if @technician || @customer || @start_date || @end_date
      @pdf.text "FILTROS APLICADOS:", size: 12, style: :bold
      @pdf.move_down 5

      filters = []
      filters << "Técnico: #{@technician.name}" if @technician
      filters << "Cliente: #{@customer}" if @customer
      filters << "Período: #{format_date(@start_date)} até #{format_date(@end_date)}" if @start_date && @end_date
      filters << "A partir de: #{format_date(@start_date)}" if @start_date && !@end_date
      filters << "Até: #{format_date(@end_date)}" if @end_date && !@start_date

      filters.each do |filter|
        @pdf.text "• #{filter}", size: 10
      end

      @pdf.move_down 15
    end
  end

  def add_statistics
    @pdf.text "RESUMO ESTATÍSTICO", size: 14, style: :bold
    @pdf.move_down 10

    # Tabela de estatísticas principais
    stats_data = [
      ["Total de Ordens", @statistics[:total_orders].to_s],
      ["Receita Total", format_currency(@statistics[:total_revenue])],
      ["Ticket Médio", format_currency(@statistics[:average_order_value])],
      ["Ordens Pagas", "#{@statistics[:paid_orders]} (#{percentage(@statistics[:paid_orders], @statistics[:total_orders])})"],
      ["Ordens Pendentes", "#{@statistics[:pending_payment]} (#{percentage(@statistics[:pending_payment], @statistics[:total_orders])})"]
    ]

    @pdf.table(stats_data,
      width: @pdf.bounds.width / 2,
      cell_style: {
        borders: [:bottom],
        border_width: 0.5,
        border_color: 'CCCCCC',
        padding: [5, 10]
      },
      column_widths: [200, 150]
    ) do
      column(0).font_style = :bold
    end

    @pdf.move_down 20

    # Análise Financeira
    @pdf.text "ANÁLISE FINANCEIRA", size: 12, style: :bold
    @pdf.move_down 5

    financial_data = [
      ["Valor Total em Serviços", format_currency(@statistics[:total_service_value])],
      ["Valor Total em Peças", format_currency(@statistics[:total_parts_value])],
      ["Receita Total", format_currency(@statistics[:total_revenue])],
      ["Total Recebido", format_currency(@statistics[:total_paid])],
      ["Pendente de Pagamento", format_currency(@statistics[:total_pending])]
    ]

    @pdf.table(financial_data,
      width: @pdf.bounds.width / 2,
      cell_style: {
        borders: [:bottom],
        border_width: 0.5,
        border_color: 'CCCCCC',
        padding: [5, 10]
      },
      column_widths: [200, 150]
    ) do
      column(0).font_style = :bold
      row(2).background_color = 'E8F5E9'
      row(3).background_color = 'F1F8E9'
      row(4).background_color = 'FFF9C4'
    end

    @pdf.move_down 25
  end

  def add_orders_table
    @pdf.text "LISTAGEM DE ORDENS (#{@service_orders.count})", size: 14, style: :bold
    @pdf.move_down 10

    if @service_orders.empty?
      @pdf.text "Nenhuma ordem encontrada com os filtros selecionados.", style: :italic
      return
    end

    # Cabeçalho da tabela
    table_data = [["#", "Título", "Cliente", "Técnico", "Concluída", "Valor", "Pagamento"]]

    # Dados das ordens
    @service_orders.each do |order|
      table_data << [
        order.id.to_s,
        truncate_text(order.title, 25),
        truncate_text(order.customer_name || "-", 20),
        truncate_text(order.technician&.name || "-", 15),
        order.completed_at ? I18n.l(order.completed_at.to_date, format: :short) : "-",
        format_currency(order.total_value || 0),
        payment_status_text(order.payment_status)
      ]
    end

    # Linha de total
    table_data << [
      { content: "TOTAL:", colspan: 5, font_style: :bold, align: :right },
      { content: format_currency(@statistics[:total_revenue]), font_style: :bold },
      ""
    ]

    @pdf.table(table_data,
      width: @pdf.bounds.width,
      header: true,
      cell_style: {
        padding: [4, 6],
        borders: [:bottom],
        border_width: 0.5,
        border_color: 'CCCCCC',
        size: 9
      },
      column_widths: [40, 150, 120, 100, 80, 80, 80]
    ) do
      row(0).font_style = :bold
      row(0).background_color = 'E0E0E0'
      row(0).size = 10
      row(-1).background_color = 'F5F5F5'
    end
  end

  def add_footer
    @pdf.move_cursor_to 30
    @pdf.stroke_horizontal_rule
    @pdf.move_down 5
    @pdf.text "Sistema de Ordens de Serviço - Relatório Confidencial", size: 8, align: :center, style: :italic
  end

  def format_currency(value)
    return "R$ 0,00" unless value
    number_to_currency(value, unit: "R$ ", separator: ",", delimiter: ".")
  end

  def format_date(date_string)
    return "" unless date_string
    Date.parse(date_string).strftime('%d/%m/%Y') rescue date_string
  end

  def percentage(part, total)
    return "0%" if total.zero?
    "#{((part.to_f / total) * 100).round(1)}%"
  end

  def truncate_text(text, length)
    return "" unless text
    text.length > length ? "#{text[0...length-3]}..." : text
  end

  def payment_status_text(status)
    case status
    when "pending_payment" then "Pendente"
    when "paid" then "Pago"
    when "partially_paid" then "Parcial"
    when "cancelled_payment" then "Cancelado"
    else "-"
    end
  end
end
