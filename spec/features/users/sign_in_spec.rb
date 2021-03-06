# encoding: utf-8
# Feature: Sign in
#   As a user
#   I want to sign in
#   So I can visit protected areas of the site
feature 'Sign in', :omniauth do
  # Scenario: User can sign in with valid account
  #   Given I have a valid account
  #   And I am not signed in
  #   When I sign in
  #   Then I see a success message
  scenario 'user can sign in with valid account' do
    sign_in_feature
    expect(page).to have_content(/sign out/i)
  end
end
