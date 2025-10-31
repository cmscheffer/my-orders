require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:other_user) { create(:user) }

  describe 'as admin' do
    before { sign_in admin }

    describe 'GET #index' do
      it 'returns a success response' do
        get :index
        expect(response).to be_successful
      end

      it 'assigns all users' do
        create_list(:user, 3)
        get :index
        expect(assigns(:users).count).to be >= 3
      end
    end

    describe 'GET #new' do
      it 'returns a success response' do
        get :new
        expect(response).to be_successful
      end

      it 'assigns a new user' do
        get :new
        expect(assigns(:user)).to be_a_new(User)
      end
    end

    describe 'POST #create' do
      context 'with valid params' do
        let(:valid_attributes) do
          {
            name: 'New User',
            email: 'newuser@example.com',
            password: 'password123',
            password_confirmation: 'password123',
            role: 'user'
          }
        end

        it 'creates a new User' do
          expect {
            post :create, params: { user: valid_attributes }
          }.to change(User, :count).by(1)
        end

        it 'redirects to users list' do
          post :create, params: { user: valid_attributes }
          expect(response).to redirect_to(users_path)
        end

        it 'sets correct role' do
          post :create, params: { user: valid_attributes }
          expect(User.last.role).to eq('user')
        end
      end

      context 'with invalid params' do
        let(:invalid_attributes) do
          {
            name: '',
            email: 'invalid',
            password: '123',
            role: 'user'
          }
        end

        it 'does not create a new User' do
          expect {
            post :create, params: { user: invalid_attributes }
          }.not_to change(User, :count)
        end

        it 'renders new template' do
          post :create, params: { user: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'with invalid role' do
        let(:invalid_role_attributes) do
          {
            name: 'Test',
            email: 'test@example.com',
            password: 'password123',
            password_confirmation: 'password123',
            role: 'technician'
          }
        end

        it 'raises an error' do
          expect {
            post :create, params: { user: invalid_role_attributes }
          }.to raise_error(ArgumentError)
        end
      end
    end

    describe 'GET #edit' do
      it 'returns a success response' do
        get :edit, params: { id: regular_user.id }
        expect(response).to be_successful
      end
    end

    describe 'PATCH #update' do
      context 'with valid params' do
        let(:new_attributes) { { name: 'Updated Name' } }

        it 'updates the user' do
          patch :update, params: { id: regular_user.id, user: new_attributes }
          regular_user.reload
          expect(regular_user.name).to eq('Updated Name')
        end

        it 'redirects to users list' do
          patch :update, params: { id: regular_user.id, user: new_attributes }
          expect(response).to redirect_to(users_path)
        end
      end

      context 'without password' do
        it 'updates user without changing password' do
          original_encrypted_password = regular_user.encrypted_password
          patch :update, params: { id: regular_user.id, user: { name: 'New Name', password: '', password_confirmation: '' } }
          regular_user.reload
          expect(regular_user.encrypted_password).to eq(original_encrypted_password)
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the user' do
        user_to_delete = create(:user)
        expect {
          delete :destroy, params: { id: user_to_delete.id }
        }.to change(User, :count).by(-1)
      end

      it 'cannot delete self' do
        expect {
          delete :destroy, params: { id: admin.id }
        }.not_to change(User, :count)
        expect(response).to redirect_to(users_path)
      end
    end
  end

  describe 'as regular user' do
    before { sign_in regular_user }

    describe 'GET #index' do
      it 'denies access' do
        get :index
        expect(response).to redirect_to(root_path)
      end
    end

    describe 'GET #new' do
      it 'denies access' do
        get :new
        expect(response).to redirect_to(root_path)
      end
    end

    describe 'POST #create' do
      it 'denies access' do
        post :create, params: { user: { name: 'Test' } }
        expect(response).to redirect_to(root_path)
      end
    end

    describe 'GET #show' do
      it 'allows viewing own profile' do
        get :show, params: { id: regular_user.id }
        expect(response).to be_successful
      end

      it 'denies viewing other profiles' do
        get :show, params: { id: other_user.id }
        expect(response).to redirect_to(root_path)
      end
    end

    describe 'GET #edit' do
      it 'allows editing own profile' do
        get :edit, params: { id: regular_user.id }
        expect(response).to be_successful
      end

      it 'denies editing other profiles' do
        get :edit, params: { id: other_user.id }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
