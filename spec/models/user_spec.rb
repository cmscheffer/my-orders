require 'rails_helper'

RSpec.describe User, type: :model do
  # Associations
  describe 'associations' do
    it { should have_many(:service_orders).dependent(:destroy) }
    it { should have_one(:technician).dependent(:destroy) }
  end

  # Validations
  describe 'validations' do
    subject { build(:user) }
    
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    
    it 'validates email format' do
      user = build(:user, email: 'invalid_email')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is invalid')
    end
  end

  # Enums
  describe 'enums' do
    it { should define_enum_for(:role).with_values(user: 0, admin: 1) }
    
    it 'accepts valid roles' do
      expect(build(:user, role: :user)).to be_valid
      expect(build(:user, role: :admin)).to be_valid
    end
    
    it 'rejects invalid roles' do
      expect { User.new(role: 'technician') }.to raise_error(ArgumentError)
    end
  end

  # Callbacks
  describe 'callbacks' do
    it 'sets default role to user on creation' do
      user = User.new(name: 'Test', email: 'test@example.com', password: 'password123')
      user.save
      expect(user.role).to eq('user')
    end
    
    it 'does not override role if already set' do
      user = User.new(name: 'Admin', email: 'admin@example.com', password: 'password123', role: :admin)
      user.save
      expect(user.role).to eq('admin')
    end
  end

  # Devise modules
  describe 'devise modules' do
    it 'includes database_authenticatable' do
      expect(User.devise_modules).to include(:database_authenticatable)
    end
    
    it 'includes registerable' do
      expect(User.devise_modules).to include(:registerable)
    end
    
    it 'includes recoverable' do
      expect(User.devise_modules).to include(:recoverable)
    end
    
    it 'includes rememberable' do
      expect(User.devise_modules).to include(:rememberable)
    end
    
    it 'includes validatable' do
      expect(User.devise_modules).to include(:validatable)
    end
  end

  # Factory validation
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:user)).to be_valid
    end
    
    it 'has a valid admin factory' do
      expect(build(:user, :admin)).to be_valid
    end
  end

  # Instance methods
  describe 'instance methods' do
    let(:user) { create(:user) }
    let(:admin) { create(:user, :admin) }

    it 'checks if user is admin' do
      expect(user.admin?).to be false
      expect(admin.admin?).to be true
    end
    
    it 'checks if user is regular user' do
      expect(user.user?).to be true
      expect(admin.user?).to be false
    end
  end

  # Edge cases
  describe 'edge cases' do
    it 'handles empty name' do
      user = build(:user, name: '')
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end
    
    it 'handles duplicate email' do
      create(:user, email: 'duplicate@example.com')
      duplicate_user = build(:user, email: 'duplicate@example.com')
      expect(duplicate_user).not_to be_valid
      expect(duplicate_user.errors[:email]).to include('has already been taken')
    end
    
    it 'handles password too short' do
      user = build(:user, password: '123', password_confirmation: '123')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('is too short (minimum is 6 characters)')
    end
  end

  # Password strength validations
  describe 'password strength validations' do
    it 'rejects password without uppercase letter' do
      user = build(:user, password: 'abc123!@#', password_confirmation: 'abc123!@#')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('deve conter pelo menos uma letra maiúscula')
    end
    
    it 'rejects password without number' do
      user = build(:user, password: 'Abcdef!@#', password_confirmation: 'Abcdef!@#')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('deve conter pelo menos um número')
    end
    
    it 'rejects password without special character' do
      user = build(:user, password: 'Abc12345', password_confirmation: 'Abc12345')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('deve conter pelo menos um caractere especial (!@#$%^&* etc)')
    end
    
    it 'accepts strong password' do
      user = build(:user, password: 'MyP@ssw0rd123', password_confirmation: 'MyP@ssw0rd123')
      expect(user).to be_valid
    end
    
    it 'accepts password with minimum requirements' do
      user = build(:user, password: 'Abc123!', password_confirmation: 'Abc123!')
      expect(user).to be_valid
    end
  end
end
