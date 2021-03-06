# encoding: utf-8
describe SessionsController, :omniauth do
  before do
    request.env['omniauth.auth'] = auth_mock
  end

  describe '#new' do
    it "redirects to '/auth/facebook'" do
      post :new
      expect(response.body).to have_content 'You are being redirected'
    end
  end

  describe '#create' do
    it 'creates a user' do
      expect do
        post :create, provider: :facebook
      end.to change { User.count }.by 1
    end

    it 'creates a session' do
      expect(session[:user_id]).to be_nil
      post :create, provider: :facebook
      expect(session[:user_id]).not_to be_nil
    end

    it 'redirects to the home page' do
      post :create, provider: :facebook
      expect(response).to redirect_to root_url
    end
  end

  describe '#destroy' do
    before do
      post :create, provider: :facebook
    end

    it 'resets the session' do
      expect(session[:user_id]).not_to be_nil
      delete :destroy
      expect(session[:user_id]).to be_nil
    end

    it 'redirects to the home page' do
      delete :destroy
      expect(response).to redirect_to root_url
    end
  end
end
