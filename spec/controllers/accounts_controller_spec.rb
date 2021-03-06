# encoding: utf-8
describe AccountsController, :omniauth do
  describe '#show' do
    it 'should show an account' do
      sign_in
      get :show
      expect(response.status).to be 200
      expect(response).to render_template(:show)

      # Ensure that the controller @account matches the test
      # @account we created here.
      expect(assigns(:account)).to match @user.account
    end

    it 'should redirect to root if not logged in' do
      get :show
      expect(response).to redirect_to root_path
      expect(response.body).to have_content 'You are being redirected'
    end
  end

  describe '#update' do
    it 'should update the account successfully' do
      sign_in
      params = {
        account: {
          theme: 'dark',
          user_attributes: {
            id:          @user.id,
            name:        Faker::Name.name,
            first_name:  Faker::Name.first_name,
            middle_name: Faker::Name.first_name,
            last_name:   Faker::Name.last_name
          }
        }
      }

      post :update, params
      @user.account.reload
      @user.reload

      expect(response).to redirect_to account_path
      expect(flash[:notice]).to match 'Your account was updated successfully'
      expect(response.status).to be 302

      expect(@user.name).to match params[:account][:user_attributes][:name]
      expect(@user.first_name).to match params[:account][:user_attributes][:first_name]
      expect(@user.middle_name).to match params[:account][:user_attributes][:middle_name]
      expect(@user.last_name).to match params[:account][:user_attributes][:last_name]
      expect(@user.account.theme).to match params[:account][:theme]
    end
  end
end
