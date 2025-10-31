class ServiceOrderPdfGenerator
  include ActionView::Helpers::NumberHelper
  
  def initialize(service_order)
    @service_order = service_order
    @pdf = Prawn::Document.new(page_size: 'A4', margin: 40)
  end

  def generate
    setup_fonts
    add_header
    add_order_info
    add_customer_info
    add_equipment_info
    add_technician_info if @service_order.technician.present?
    add_parts_table if @service_order.service_order_parts.any?
    add_financial_summary
    add_description
    add_footer
    
    @pdf.render
  end

  private

  def setup_fonts
    # Prawn usa fontes padrão que suportam caracteres básicos
  end

  def add_header
    # Adicionar logo se existir
    company_setting = CompanySetting.instance
    if company_setting.has_logo?
      begin
        # Criar arquivo temporário com o logo
        temp_file = Tempfile.new(['logo', File.extname(company_setting.logo_filename)])
        temp_file.binmode
        temp_file.write(company_setting.logo_data)
        temp_file.rewind
        
        # Adicionar imagem no PDF
        @pdf.image temp_file.path, 
                   fit: [120, 60],
                   position: :center
        @pdf.move_down 10
        
        temp_file.close
        temp_file.unlink
      rescue => e
        # Se houver erro ao processar imagem, apenas ignora
        Rails.logger.error "Erro ao adicionar logo ao PDF: #{e.message}"
      end
    end
    
    # Adicionar nome da empresa se configurado
    if company_setting.company_name.present?
      @pdf.text company_setting.company_name, size: 12, align: :center, style: :bold
      @pdf.move_down 3
    end
    
    # Adicionar CNPJ se configurado
    if company_setting.formatted_cnpj.present?
      @pdf.text "CNPJ: #{company_setting.formatted_cnpj}", size: 10, align: :center
      @pdf.move_down 5
    elsif company_setting.company_name.present?
      @pdf.move_down 2
    end
    
    @pdf.text "ORDEM DE SERVIÇO ##{@service_order.id}", size: 24, style: :bold, align: :center
    @pdf.move_down 5
    
    # Linha horizontal
    @pdf.stroke_horizontal_rule
    @pdf.move_down 20
  end

  def add_order_info
    @pdf.text "INFORMAÇÕES DA ORDEM", size: 14, style: :bold
    @pdf.move_down 10

    data = [
      ["Título:", @service_order.title],
      ["Status:", status_text(@service_order.status)],
      ["Prioridade:", priority_text(@service_order.priority)],
      ["Criado em:", I18n.l(@service_order.created_at, format: :long)],
      ["Criado por:", @service_order.user.name]
    ]

    if @service_order.due_date.present?
      data << ["Vencimento:", I18n.l(@service_order.due_date, format: :long)]
    end

    if @service_order.completed_at.present?
      data << ["Concluído em:", I18n.l(@service_order.completed_at, format: :long)]
    end

    @pdf.table(data, 
      width: @pdf.bounds.width,
      cell_style: { 
        borders: [:bottom], 
        border_width: 0.5,
        border_color: 'CCCCCC',
        padding: [5, 10]
      },
      column_widths: [150, @pdf.bounds.width - 150]
    ) do
      column(0).font_style = :bold
    end

    @pdf.move_down 20
  end

  def add_customer_info
    return unless @service_order.customer_name.present?

    @pdf.text "INFORMAÇÕES DO CLIENTE", size: 14, style: :bold
    @pdf.move_down 10

    data = []
    data << ["Nome:", @service_order.customer_name] if @service_order.customer_name.present?
    data << ["Email:", @service_order.customer_email] if @service_order.customer_email.present?
    data << ["Telefone:", @service_order.customer_phone] if @service_order.customer_phone.present?

    if data.any?
      @pdf.table(data, 
        width: @pdf.bounds.width,
        cell_style: { 
          borders: [:bottom], 
          border_width: 0.5,
          border_color: 'CCCCCC',
          padding: [5, 10]
        },
        column_widths: [150, @pdf.bounds.width - 150]
      ) do
        column(0).font_style = :bold
      end
    end

    @pdf.move_down 20
  end

  def add_equipment_info
    return unless @service_order.equipment_name.present?

    @pdf.text "INFORMAÇÕES DO EQUIPAMENTO", size: 14, style: :bold
    @pdf.move_down 10

    data = []
    data << ["Equipamento:", @service_order.equipment_name] if @service_order.equipment_name.present?
    data << ["Marca:", @service_order.equipment_brand] if @service_order.equipment_brand.present?
    data << ["Modelo:", @service_order.equipment_model] if @service_order.equipment_model.present?
    data << ["Número de Série:", @service_order.equipment_serial] if @service_order.equipment_serial.present?

    if data.any?
      @pdf.table(data, 
        width: @pdf.bounds.width,
        cell_style: { 
          borders: [:bottom], 
          border_width: 0.5,
          border_color: 'CCCCCC',
          padding: [5, 10]
        },
        column_widths: [150, @pdf.bounds.width - 150]
      ) do
        column(0).font_style = :bold
      end
    end

    @pdf.move_down 20
  end

  def add_technician_info
    @pdf.text "TÉCNICO RESPONSÁVEL", size: 14, style: :bold
    @pdf.move_down 10

    data = [
      ["Nome:", @service_order.technician.name]
    ]

    if @service_order.technician.email.present?
      data << ["Email:", @service_order.technician.email]
    end

    if @service_order.technician.phone.present?
      data << ["Telefone:", @service_order.technician.formatted_phone]
    end

    if @service_order.technician.specialty.present?
      data << ["Especialidade:", @service_order.technician.specialty]
    end

    @pdf.table(data, 
      width: @pdf.bounds.width,
      cell_style: { 
        borders: [:bottom], 
        border_width: 0.5,
        border_color: 'CCCCCC',
        padding: [5, 10]
      },
      column_widths: [150, @pdf.bounds.width - 150]
    ) do
      column(0).font_style = :bold
    end

    @pdf.move_down 20
  end

  def add_parts_table
    @pdf.text "PEÇAS UTILIZADAS", size: 14, style: :bold
    @pdf.move_down 10

    table_data = [["Código", "Peça", "Qtd", "Preço Unit.", "Total"]]

    @service_order.service_order_parts.includes(:part).each do |sop|
      table_data << [
        sop.part.code || "-",
        sop.part.name,
        sop.quantity.to_s,
        format_currency(sop.unit_price),
        format_currency(sop.total_price)
      ]
    end

    # Linha de total
    table_data << [
      { content: "TOTAL DE PEÇAS", colspan: 4, font_style: :bold, align: :right },
      { content: format_currency(@service_order.parts_value), font_style: :bold }
    ]

    @pdf.table(table_data, 
      width: @pdf.bounds.width,
      header: true,
      cell_style: { 
        padding: [5, 10],
        borders: [:bottom],
        border_width: 0.5,
        border_color: 'CCCCCC'
      },
      column_widths: [80, @pdf.bounds.width - 320, 50, 95, 95]
    ) do
      row(0).font_style = :bold
      row(0).background_color = 'EEEEEE'
      row(-1).background_color = 'F5F5F5'
    end

    @pdf.move_down 20
  end

  def add_financial_summary
    @pdf.text "RESUMO FINANCEIRO", size: 14, style: :bold
    @pdf.move_down 10

    data = []
    
    if @service_order.service_value.present? && @service_order.service_value > 0
      data << ["Valor do Serviço:", format_currency(@service_order.service_value)]
    end

    if @service_order.parts_value.present? && @service_order.parts_value > 0
      data << ["Valor das Peças:", format_currency(@service_order.parts_value)]
    end

    # Linha de total destacada
    data << [
      { content: "VALOR TOTAL", font_style: :bold },
      { content: format_currency(@service_order.total_value || 0), font_style: :bold, size: 14 }
    ]

    if @service_order.payment_status.present?
      data << ["Status do Pagamento:", payment_status_text(@service_order.payment_status)]
    end

    if @service_order.payment_method.present?
      data << ["Forma de Pagamento:", @service_order.payment_method]
    end

    if @service_order.payment_date.present?
      data << ["Data do Pagamento:", I18n.l(@service_order.payment_date, format: :long)]
    end

    @pdf.table(data, 
      width: @pdf.bounds.width,
      cell_style: { 
        borders: [:bottom], 
        border_width: 0.5,
        border_color: 'CCCCCC',
        padding: [5, 10]
      },
      column_widths: [150, @pdf.bounds.width - 150]
    ) do
      column(0).font_style = :bold
      row(-data.length + data.index { |r| r[0].is_a?(Hash) && r[0][:content] == "VALOR TOTAL" }).background_color = 'F0F0F0'
    end

    @pdf.move_down 20
  end

  def add_description
    @pdf.text "DESCRIÇÃO DO SERVIÇO", size: 14, style: :bold
    @pdf.move_down 10

    @pdf.text @service_order.description, align: :justify, leading: 5

    if @service_order.notes.present?
      @pdf.move_down 15
      @pdf.text "OBSERVAÇÕES:", size: 12, style: :bold
      @pdf.move_down 5
      @pdf.text @service_order.notes, align: :justify, leading: 5
    end

    @pdf.move_down 20
  end

  def add_footer
    @pdf.move_down 40

    # Linha para assinatura do cliente
    signature_start = 50
    signature_end = 250
    signature_width = signature_end - signature_start
    
    @pdf.stroke_horizontal_line signature_start, signature_end, at: @pdf.cursor
    @pdf.move_down 5
    
    # Centralizar texto exatamente sobre a linha
    @pdf.bounding_box([signature_start, @pdf.cursor], width: signature_width) do
      @pdf.text "Assinatura do Cliente", align: :center, size: 10
    end

    # Informações do rodapé
    @pdf.move_cursor_to 30
    @pdf.stroke_horizontal_rule
    @pdf.move_down 5
    @pdf.text "Gerado em #{I18n.l(Time.current, format: :long)}", size: 8, align: :center, style: :italic
  end

  def format_currency(value)
    return "R$ 0,00" unless value
    number_to_currency(value, unit: "R$ ", separator: ",", delimiter: ".")
  end

  def status_text(status)
    case status
    when "pending" then "Pendente"
    when "in_progress" then "Em Andamento"
    when "completed" then "Concluída"
    when "cancelled" then "Cancelada"
    else status.humanize
    end
  end

  def priority_text(priority)
    case priority
    when "low" then "Baixa"
    when "medium" then "Média"
    when "high" then "Alta"
    when "urgent" then "Urgente"
    else priority.humanize
    end
  end

  def payment_status_text(status)
    case status
    when "pending_payment" then "Pagamento Pendente"
    when "paid" then "Pago"
    when "partially_paid" then "Parcialmente Pago"
    when "cancelled_payment" then "Pagamento Cancelado"
    else status.humanize
    end
  end
end
