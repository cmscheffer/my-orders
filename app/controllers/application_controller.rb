class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :remove_already_authenticated_flash

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  private

  # Remove a mensagem irritante "Você já está autenticado"
  def remove_already_authenticated_flash
    if flash[:alert] == "Você já está autenticado."
      flash.delete(:alert)
    end
  end
end
