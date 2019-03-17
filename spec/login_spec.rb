require_relative 'spec_helper'

feature "Registration" do

  scenario "Password Failure" do
    visit "user/new"
    expect(page).to have_content "Create account"
    fill_in 'name', with: 'hej'
    fill_in 'email', with: 'h@j'
    fill_in 'pwd', with: '123'
    click_button 'Create account'
    expect(page).to have_content "Password is too short"
  end

  scenario "Name Failure" do
    visit "user/new"
    expect(page).to have_content "Create account" 
    fill_in 'email', with: 'h@j'
    fill_in 'pwd', with: '1234567'
    click_button 'Create account'
    expect(page).to have_content "Name is required"
  end

  scenario "Email Empty Failure" do
    visit "user/new"
    expect(page).to have_content "Create account"
    fill_in 'name', with: 'hej'
    fill_in 'pwd', with: '1234567'
    click_button 'Create account'
    expect(page).to have_content "Email is required"
  end

  scenario "Success (from start page)" do
    visit "/"
    click_link('Not a member? Sign up here!')
    expect(page).to have_content "Create account"
    fill_in 'name', with: 'hej'
    fill_in 'email', with: 'h@j'
    fill_in 'pwd', with: '1234567'
    click_button 'Create account'
    expect(page).to have_content "Registration successful"
    click_link('Get back to start by clicking here!')
  end

  scenario "Email Failure" do
    visit "user/new"
    expect(page).to have_content "Create account"
    fill_in 'name', with: 'hej'
    fill_in 'email', with: 'h@j'
    fill_in 'pwd', with: '1234567'
    click_button 'Create account'
    expect(page).to have_content "Email is already used"
  end

end

feature "Login" do

  scenario "Password failure" do
    visit "/"
    expect(page).to have_content "Begin to shop once you're logged in :)"
    fill_in 'email', with: 'h@j'
    fill_in 'pwd', with: '123'
    click_button 'Log in'
    expect(page).to have_content "Invalid email or password"
  end

  scenario "Email failure" do
    visit "/"
    expect(page).to have_content "Begin to shop once you're logged in :)"
    fill_in 'email', with: 'h@jj'
    fill_in 'pwd', with: '1234567'
    click_button 'Log in'
    expect(page).to have_content "Invalid email or password"
  end

  scenario "Successful & Log out" do
    visit "/"
    expect(page).to have_content "Begin to shop once you're logged in :)"
    fill_in 'email', with: 'h@j'
    fill_in 'pwd', with: '1234567'
    click_button 'Log in'
    expect(page).to have_content "You are logged in as:"
    click_button 'Log out'
  end

end        # ctrl + *

feature "Cart" do

  scenario "Empty cart" do
    visit "/"
    expect(page).to have_content "Begin to shop once you're logged in :)"
    fill_in 'email', with: 'h@j'
    fill_in 'pwd', with: '1234567'
    click_button 'Log in'
    expect(page).to have_content "You are logged in as:"
    click_link('Check cart')
    expect(page).to have_content "No items in cart"
    click_link('Get back to start by clicking here!')
    click_button 'Log out'
  end

  scenario "Add & delete from cart" do
    visit "/"
    expect(page).to have_content "Begin to shop once you're logged in :)"
    fill_in 'email', with: 'h@j'
    fill_in 'pwd', with: '1234567'
    click_button 'Log in'
    expect(page).to have_content "You are logged in as:"
    click_button 'Add item 1 to cart'
    click_link('Check cart')
    expect(page).to have_content "Cart:"
    click_button 'Delete from cart'
    expect(page).to have_content "No items in cart"
    click_link('Get back to start by clicking here!')
    click_button 'Log out'
  end

end

# cmd -> app.rb -> bundle exec rspec


#   click_link('Show Confirm')          -> klickar länken
#   fill_in 'Name', with: 'Jimmy'       -> fyller i formulär
#   click_button 'Like'                 -> klickar..
#   end