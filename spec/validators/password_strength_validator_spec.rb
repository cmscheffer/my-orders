require 'rails_helper'

RSpec.describe PasswordStrengthValidator do
  # Criar um model dummy para testar o validador
  class DummyUser
    include ActiveModel::Validations
    attr_accessor :password
    
    validates :password, password_strength: true
    
    def initialize(password = nil)
      @password = password
    end
  end
  
  describe 'validações de senha' do
    context 'senhas inválidas' do
      it 'rejeita senha muito curta' do
        user = DummyUser.new('Ab1!')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('deve ter no mínimo 6 caracteres')
      end
      
      it 'rejeita senha sem letra maiúscula' do
        user = DummyUser.new('abc123!')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('deve conter pelo menos uma letra maiúscula')
      end
      
      it 'rejeita senha sem número' do
        user = DummyUser.new('Abcdef!')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('deve conter pelo menos um número')
      end
      
      it 'rejeita senha sem caractere especial' do
        user = DummyUser.new('Abc123')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('deve conter pelo menos um caractere especial (!@#$%^&* etc)')
      end
      
      it 'mostra todos os erros de uma senha fraca' do
        user = DummyUser.new('abc')
        expect(user).not_to be_valid
        expect(user.errors[:password].size).to be >= 3
      end
    end
    
    context 'senhas válidas' do
      it 'aceita senha forte mínima' do
        user = DummyUser.new('Abc123!')
        expect(user).to be_valid
      end
      
      it 'aceita senha com todos os requisitos' do
        user = DummyUser.new('MyP@ssw0rd123')
        expect(user).to be_valid
      end
      
      it 'aceita senha com caracteres especiais variados' do
        passwords = ['Abc123!', 'Abc123@', 'Abc123#', 'Abc123$', 'Abc123%']
        passwords.each do |password|
          user = DummyUser.new(password)
          expect(user).to be_valid, "Esperava que '#{password}' fosse válida"
        end
      end
    end
    
    context 'senha em branco' do
      it 'não valida senha nil' do
        user = DummyUser.new(nil)
        # Não deve adicionar erros para senha nil (deixa Devise validar)
        user.valid?
        # O validador não adiciona erro para nil, mas outros validadores podem
      end
    end
  end
  
  describe '.strong_password?' do
    it 'retorna true para senha forte' do
      expect(PasswordStrengthValidator.strong_password?('MyP@ssw0rd123')).to be true
    end
    
    it 'retorna false para senha fraca' do
      expect(PasswordStrengthValidator.strong_password?('abc')).to be false
    end
    
    it 'retorna false para senha vazia' do
      expect(PasswordStrengthValidator.strong_password?('')).to be false
    end
    
    it 'retorna false para senha nil' do
      expect(PasswordStrengthValidator.strong_password?(nil)).to be false
    end
  end
  
  describe '.requirements' do
    it 'retorna array com requisitos' do
      requirements = PasswordStrengthValidator.requirements
      expect(requirements).to be_an(Array)
      expect(requirements.size).to eq(4)
      expect(requirements).to include(match(/mínimo.*caracteres/i))
      expect(requirements).to include(match(/letra maiúscula/i))
      expect(requirements).to include(match(/número/i))
      expect(requirements).to include(match(/caractere especial/i))
    end
  end
end
