class CompanySettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company_setting

  def edit
    # Apenas renderiza o formulário
  end

  def update
    # Processar upload de logo se fornecido
    if params[:company_setting][:logo].present?
      uploaded_file = params[:company_setting][:logo]
      
      @company_setting.logo_filename = uploaded_file.original_filename
      @company_setting.logo_data = uploaded_file.read
    end

    # Remover outros parâmetros que não queremos atualizar diretamente
    setting_params = company_setting_params.except(:logo)

    if @company_setting.update(setting_params)
      redirect_to edit_company_settings_path, notice: 'Configurações atualizadas com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def remove_logo
    if @company_setting.remove_logo!
      redirect_to edit_company_settings_path, notice: 'Logo removida com sucesso.'
    else
      redirect_to edit_company_settings_path, alert: 'Erro ao remover logo.'
    end
  end

  def show_logo
    if @company_setting.has_logo?
      send_data @company_setting.logo_data,
                type: @company_setting.logo_mime_type,
                disposition: 'inline',
                filename: @company_setting.logo_filename
    else
      head :not_found
    end
  end

  private

  def set_company_setting
    @company_setting = CompanySetting.instance
  end

  def company_setting_params
    params.require(:company_setting).permit(
      :company_name,
      :cnpj,
      :address,
      :phone,
      :email,
      :website,
      :logo
    )
  end
end
