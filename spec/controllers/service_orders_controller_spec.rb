require 'rails_helper'

RSpec.describe ServiceOrdersController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:user_order) { create(:service_order, user: regular_user) }
  let(:other_order) { create(:service_order, user: other_user) }

  describe 'as admin' do
    before { sign_in admin }

    describe 'GET #index' do
      it 'returns a success response' do
        get :index
        expect(response).to be_successful
      end

      it 'sees all service orders' do
        create_list(:service_order, 3, user: regular_user)
        create_list(:service_order, 2, user: other_user)
        get :index
        expect(assigns(:service_orders).count).to eq(5)
      end

      it 'filters by status' do
        create(:service_order, status: :pending)
        create(:service_order, :completed)
        get :index, params: { status: 'pending' }
        expect(assigns(:service_orders).all?(&:pending?)).to be true
      end

      it 'filters by priority' do
        create(:service_order, priority: :low)
        create(:service_order, :urgent)
        get :index, params: { priority: 'urgent' }
        expect(assigns(:service_orders).all?(&:urgent?)).to be true
      end
    end

    describe 'GET #show' do
      it 'returns a success response' do
        get :show, params: { id: user_order.id }
        expect(response).to be_successful
      end
    end

    describe 'GET #new' do
      it 'returns a success response' do
        get :new
        expect(response).to be_successful
      end
    end

    describe 'POST #create' do
      context 'with valid params' do
        let(:valid_attributes) do
          {
            title: 'Test Order',
            description: 'This is a test description with enough characters',
            status: 'pending',
            priority: 'medium',
            customer_name: 'John Doe',
            service_value: 100.0
          }
        end

        it 'creates a new ServiceOrder' do
          expect {
            post :create, params: { service_order: valid_attributes }
          }.to change(ServiceOrder, :count).by(1)
        end

        it 'assigns order to current user' do
          post :create, params: { service_order: valid_attributes }
          expect(ServiceOrder.last.user).to eq(admin)
        end

        it 'redirects to the created order' do
          post :create, params: { service_order: valid_attributes }
          expect(response).to redirect_to(ServiceOrder.last)
        end
      end

      context 'with invalid params' do
        let(:invalid_attributes) do
          {
            title: 'ab',  # Too short
            description: 'short',  # Too short
            status: 'pending',
            priority: 'medium'
          }
        end

        it 'does not create a new ServiceOrder' do
          expect {
            post :create, params: { service_order: invalid_attributes }
          }.not_to change(ServiceOrder, :count)
        end

        it 'renders new template' do
          post :create, params: { service_order: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe 'GET #edit' do
      it 'returns a success response' do
        get :edit, params: { id: user_order.id }
        expect(response).to be_successful
      end
    end

    describe 'PATCH #update' do
      context 'with valid params' do
        let(:new_attributes) { { title: 'Updated Title' } }

        it 'updates the service order' do
          patch :update, params: { id: user_order.id, service_order: new_attributes }
          user_order.reload
          expect(user_order.title).to eq('Updated Title')
        end

        it 'redirects to the order' do
          patch :update, params: { id: user_order.id, service_order: new_attributes }
          expect(response).to redirect_to(user_order)
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the service order' do
        order_to_delete = create(:service_order, user: admin)
        expect {
          delete :destroy, params: { id: order_to_delete.id }
        }.to change(ServiceOrder, :count).by(-1)
      end
    end

    describe 'PATCH #complete' do
      it 'marks order as completed' do
        patch :complete, params: { id: user_order.id }
        user_order.reload
        expect(user_order.status).to eq('completed')
      end
    end

    describe 'PATCH #cancel' do
      it 'marks order as cancelled' do
        patch :cancel, params: { id: user_order.id }
        user_order.reload
        expect(user_order.status).to eq('cancelled')
      end
    end

    describe 'GET #pdf' do
      it 'generates PDF' do
        get :pdf, params: { id: user_order.id }
        expect(response).to be_successful
        expect(response.content_type).to eq('application/pdf')
      end

      it 'has correct filename' do
        get :pdf, params: { id: user_order.id }
        expect(response.headers['Content-Disposition']).to include("ordem_servico_#{user_order.id}.pdf")
      end
    end
  end

  describe 'as regular user' do
    before { sign_in regular_user }

    describe 'GET #index' do
      it 'returns a success response' do
        get :index
        expect(response).to be_successful
      end

      it 'sees only own service orders' do
        create_list(:service_order, 3, user: regular_user)
        create_list(:service_order, 2, user: other_user)
        get :index
        expect(assigns(:service_orders).count).to eq(3)
        expect(assigns(:service_orders).all? { |o| o.user == regular_user }).to be true
      end
    end

    describe 'GET #show' do
      it 'can view own orders' do
        get :show, params: { id: user_order.id }
        expect(response).to be_successful
      end

      it 'can view other orders (read-only access)' do
        get :show, params: { id: other_order.id }
        expect(response).to be_successful
      end
    end

    describe 'GET #edit' do
      it 'can edit own orders' do
        get :edit, params: { id: user_order.id }
        expect(response).to be_successful
      end

      it 'cannot edit other users orders' do
        get :edit, params: { id: other_order.id }
        expect(response).to redirect_to(service_orders_path)
      end
    end

    describe 'PATCH #update' do
      it 'can update own orders' do
        patch :update, params: { id: user_order.id, service_order: { title: 'My Updated Title' } }
        user_order.reload
        expect(user_order.title).to eq('My Updated Title')
      end

      it 'cannot update other users orders' do
        original_title = other_order.title
        patch :update, params: { id: other_order.id, service_order: { title: 'Hacked Title' } }
        other_order.reload
        expect(other_order.title).to eq(original_title)
        expect(response).to redirect_to(service_orders_path)
      end
    end

    describe 'DELETE #destroy' do
      it 'can delete own orders' do
        order_to_delete = create(:service_order, user: regular_user)
        expect {
          delete :destroy, params: { id: order_to_delete.id }
        }.to change(ServiceOrder, :count).by(-1)
      end

      it 'cannot delete other users orders' do
        expect {
          delete :destroy, params: { id: other_order.id }
        }.not_to change(ServiceOrder, :count)
        expect(response).to redirect_to(service_orders_path)
      end
    end
  end

  describe 'as guest' do
    describe 'GET #index' do
      it 'redirects to login' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
