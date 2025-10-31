require 'rails_helper'

RSpec.describe ServiceOrder, type: :model do
  # Associations
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:technician).optional }
    it { should have_many(:service_order_parts).dependent(:destroy) }
    it { should have_many(:parts).through(:service_order_parts) }
  end

  # Validations
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:priority) }
    
    it { should validate_length_of(:title).is_at_least(3).is_at_most(100) }
    it { should validate_length_of(:description).is_at_least(10) }
    it { should validate_length_of(:equipment_name).is_at_most(100) }
    
    it { should validate_numericality_of(:service_value).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:parts_value).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:total_value).is_greater_than_or_equal_to(0) }
  end

  # Enums
  describe 'enums' do
    it do
      should define_enum_for(:status)
        .with_values(pending: 0, in_progress: 1, completed: 2, cancelled: 3)
    end
    
    it do
      should define_enum_for(:priority)
        .with_values(low: 0, medium: 1, high: 2, urgent: 3)
    end
    
    it do
      should define_enum_for(:payment_status)
        .with_values(pending_payment: 0, paid: 1, partially_paid: 2, cancelled_payment: 3)
        .with_prefix(true)
    end
  end

  # Callbacks
  describe 'callbacks' do
    it 'calculates total_value before save' do
      service_order = build(:service_order, service_value: 100, parts_value: 50)
      service_order.save
      expect(service_order.total_value).to eq(150)
    end
    
    it 'handles nil service_value' do
      service_order = build(:service_order, service_value: nil, parts_value: 50)
      service_order.save
      expect(service_order.total_value).to eq(50)
    end
    
    it 'handles nil parts_value' do
      service_order = build(:service_order, service_value: 100, parts_value: nil)
      service_order.save
      expect(service_order.total_value).to eq(100)
    end
  end

  # Scopes
  describe 'scopes' do
    let!(:old_order) { create(:service_order, created_at: 2.days.ago) }
    let!(:new_order) { create(:service_order, created_at: 1.day.ago) }
    let!(:pending_order) { create(:service_order, status: :pending) }
    let!(:completed_order) { create(:service_order, :completed) }
    let!(:urgent_order) { create(:service_order, :urgent) }
    
    it 'orders by recent' do
      expect(ServiceOrder.recent.first).to eq(new_order)
      expect(ServiceOrder.recent.last).to eq(old_order)
    end
    
    it 'filters by status' do
      expect(ServiceOrder.by_status(:pending)).to include(pending_order)
      expect(ServiceOrder.by_status(:pending)).not_to include(completed_order)
    end
    
    it 'filters by priority' do
      expect(ServiceOrder.by_priority(:urgent)).to include(urgent_order)
      expect(ServiceOrder.by_priority(:urgent)).not_to include(pending_order)
    end
  end

  # Instance methods
  describe '#can_be_completed?' do
    it 'returns true for pending orders' do
      order = build(:service_order, status: :pending)
      expect(order.can_be_completed?).to be true
    end
    
    it 'returns true for in_progress orders' do
      order = build(:service_order, :in_progress)
      expect(order.can_be_completed?).to be true
    end
    
    it 'returns false for completed orders' do
      order = build(:service_order, :completed)
      expect(order.can_be_completed?).to be false
    end
    
    it 'returns false for cancelled orders' do
      order = build(:service_order, :cancelled)
      expect(order.can_be_completed?).to be false
    end
  end

  describe '#can_be_cancelled?' do
    it 'returns true for pending orders' do
      order = build(:service_order, status: :pending)
      expect(order.can_be_cancelled?).to be true
    end
    
    it 'returns false for completed orders' do
      order = build(:service_order, :completed)
      expect(order.can_be_cancelled?).to be false
    end
    
    it 'returns false for already cancelled orders' do
      order = build(:service_order, :cancelled)
      expect(order.can_be_cancelled?).to be false
    end
  end

  describe '#mark_as_completed!' do
    it 'marks pending order as completed' do
      order = create(:service_order, status: :pending)
      order.mark_as_completed!
      expect(order.reload.status).to eq('completed')
      expect(order.completed_at).to be_present
    end
    
    it 'does not mark cancelled order as completed' do
      order = create(:service_order, :cancelled)
      order.mark_as_completed!
      expect(order.reload.status).to eq('cancelled')
    end
  end

  describe '#mark_as_cancelled!' do
    it 'marks pending order as cancelled' do
      order = create(:service_order, status: :pending)
      order.mark_as_cancelled!
      expect(order.reload.status).to eq('cancelled')
    end
    
    it 'does not mark completed order as cancelled' do
      order = create(:service_order, :completed)
      order.mark_as_cancelled!
      expect(order.reload.status).to eq('completed')
    end
  end

  describe '#overdue?' do
    it 'returns true for past due date and not completed' do
      order = build(:service_order, :overdue)
      expect(order.overdue?).to be true
    end
    
    it 'returns false for future due date' do
      order = build(:service_order, due_date: 5.days.from_now)
      expect(order.overdue?).to be false
    end
    
    it 'returns false for completed orders' do
      order = build(:service_order, :completed, due_date: 5.days.ago)
      expect(order.overdue?).to be false
    end
    
    it 'returns false when no due date' do
      order = build(:service_order, due_date: nil)
      expect(order.overdue?).to be false
    end
  end

  describe '#status_badge_class' do
    it 'returns correct badge class for each status' do
      expect(build(:service_order, status: :pending).status_badge_class).to eq('bg-warning')
      expect(build(:service_order, :in_progress).status_badge_class).to eq('bg-info')
      expect(build(:service_order, :completed).status_badge_class).to eq('bg-success')
      expect(build(:service_order, :cancelled).status_badge_class).to eq('bg-secondary')
    end
  end

  describe '#priority_badge_class' do
    it 'returns correct badge class for each priority' do
      expect(build(:service_order, priority: :low).priority_badge_class).to eq('bg-secondary')
      expect(build(:service_order, priority: :medium).priority_badge_class).to eq('bg-primary')
      expect(build(:service_order, priority: :high).priority_badge_class).to eq('bg-warning')
      expect(build(:service_order, :urgent).priority_badge_class).to eq('bg-danger')
    end
  end

  describe '#equipment_info' do
    it 'returns full equipment info when all fields present' do
      order = build(:service_order, 
                    equipment_name: 'Notebook', 
                    equipment_brand: 'Dell', 
                    equipment_model: 'Inspiron')
      expect(order.equipment_info).to eq('Notebook - Dell - Inspiron')
    end
    
    it 'returns only name when other fields blank' do
      order = build(:service_order, 
                    equipment_name: 'Notebook', 
                    equipment_brand: nil, 
                    equipment_model: nil)
      expect(order.equipment_info).to eq('Notebook')
    end
    
    it 'returns message when no equipment' do
      order = build(:service_order, equipment_name: nil)
      expect(order.equipment_info).to eq('Sem equipamento cadastrado')
    end
  end

  describe 'formatted values' do
    let(:order) { build(:service_order, service_value: 150.50, parts_value: 75.25, total_value: 225.75) }
    
    it 'formats service_value correctly' do
      expect(order.formatted_service_value).to eq('R$ 150.50')
    end
    
    it 'formats parts_value correctly' do
      expect(order.formatted_parts_value).to eq('R$ 75.25')
    end
    
    it 'formats total_value correctly' do
      expect(order.formatted_total_value).to eq('R$ 225.75')
    end
    
    it 'handles nil values' do
      order = build(:service_order, service_value: nil, parts_value: nil)
      expect(order.formatted_service_value).to eq('R$ 0,00')
      expect(order.formatted_parts_value).to eq('R$ 0,00')
    end
  end

  # Factory validation
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:service_order)).to be_valid
    end
    
    it 'has valid traits' do
      expect(build(:service_order, :in_progress)).to be_valid
      expect(build(:service_order, :completed)).to be_valid
      expect(build(:service_order, :cancelled)).to be_valid
      expect(build(:service_order, :urgent)).to be_valid
      expect(build(:service_order, :with_technician)).to be_valid
    end
  end
end
