class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!, except: [:show, :edit, :update]
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user_access!, only: [:show, :edit, :update]

  def index
    @users = User.all.order(created_at: :desc).page(params[:page]).per(15)
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    Rails.logger.info "=" * 80
    Rails.logger.info "🔍 DEBUG - Criando usuário"
    Rails.logger.info "Params recebidos: #{params.inspect}"
    Rails.logger.info "User params filtrados: #{user_params.inspect}"
    
    @user = User.new(user_params)
    @user.password = params[:user][:password] if params[:user][:password].present?
    
    Rails.logger.info "Usuário antes de salvar:"
    Rails.logger.info "  - Name: #{@user.name}"
    Rails.logger.info "  - Email: #{@user.email}"
    Rails.logger.info "  - Role: #{@user.role}"
    Rails.logger.info "  - Password presente? #{@user.password.present?}"
    Rails.logger.info "  - Password length: #{@user.password&.length}"
    
    Rails.logger.info "Validando usuário..."
    @user.valid?
    
    Rails.logger.info "Erros de validação:"
    @user.errors.each do |error|
      Rails.logger.error "  - #{error.attribute}: #{error.message}"
    end
    
    if @user.save
      Rails.logger.info "✅ Usuário criado com sucesso! ID: #{@user.id}"
      redirect_to users_path, notice: 'Usuário criado com sucesso.'
    else
      error_count = @user.errors.count
      error_list = @user.errors.full_messages.join(', ')
      
      Rails.logger.error "=" * 80
      Rails.logger.error "❌ FALHA ao criar usuário"
      Rails.logger.error "Total de erros: #{error_count}"
      Rails.logger.error "Erros completos:"
      @user.errors.each do |error|
        Rails.logger.error "  - Campo: #{error.attribute}"
        Rails.logger.error "    Mensagem: #{error.message}"
        Rails.logger.error "    Tipo: #{error.type}"
      end
      Rails.logger.error "=" * 80
      
      error_msg = error_count == 1 ? "1 erro encontrado" : "#{error_count} erros encontrados"
      flash.now[:alert] = "❌ Falha ao criar usuário! #{error_msg}. Corrija os problemas abaixo."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    user_update_params = user_params
    
    # Se não informou senha, não atualizar
    if params[:user][:password].blank?
      user_update_params = user_update_params.except(:password, :password_confirmation)
    end
    
    if @user.update(user_update_params)
      redirect_to users_path, notice: 'Usuário atualizado com sucesso.'
    else
      error_count = @user.errors.count
      error_list = @user.errors.full_messages.join(', ')
      
      Rails.logger.error "❌ Erro ao atualizar usuário: #{error_list}"
      
      error_msg = error_count == 1 ? "1 erro encontrado" : "#{error_count} erros encontrados"
      flash.now[:alert] = "❌ Falha ao atualizar usuário! #{error_msg}. Corrija os problemas abaixo."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to users_path, alert: 'Você não pode excluir seu próprio usuário.'
      return
    end
    
    @user.destroy
    redirect_to users_path, notice: 'Usuário excluído com sucesso.'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    if current_user.admin?
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
    else
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
  end

  def authorize_admin!
    unless current_user.admin?
      redirect_to root_path, alert: 'Acesso negado. Apenas administradores.'
    end
  end

  def authorize_user_access!
    unless current_user.admin? || @user == current_user
      redirect_to root_path, alert: 'Acesso negado.'
    end
  end
end
