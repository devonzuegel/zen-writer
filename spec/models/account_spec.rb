# encoding: utf-8
require 'rails_helper'

RSpec.describe Account, type: :model do
  before(:each) do
    @account = FactoryGirl.create(:account)
    @user = FactoryGirl.create(:user)
  end

  subject { @account }

  it { should respond_to(:theme) }
  it { should respond_to(:public_posts) }

  it 'factory account created as expected' do
    expect(@account).to be_valid
    expect(@account.theme).to match Account.themes.first
    expect(@account.public_posts).to match false
  end

  it 'can be assigned a user' do
    expect(@account.user).to be nil
    @account.user = @user
    @account.save
    expect(@account.user).to be @user
  end

  it 'Account.themes contains what we expect' do
    expect(Account.themes).to match %w(light dark)
  end
end
