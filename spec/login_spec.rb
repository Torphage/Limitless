require_relative 'spec_helper'



feature("User") do

    context("Registration") do

        before(:all) do
            visit "/signup"
            within("#signup") do
                fill_in 'first_name', with: 'First'
                fill_in 'last_name', with: 'Last'
                fill_in 'email', with: 'bar@bar.com'
                fill_in 'username', with: 'Bar'
                fill_in 'password', with: '123'
            end
            click_button('Create account')
            click_button('Logout')
        end
    
        scenario("Should fail, provided email is not valid") do
            visit "/"
            click_link('Sign Up')
            expect(page).to have_content("Create account")
            within("#signup") do
                fill_in 'first_name', with: 'First'
                fill_in 'last_name', with: 'Last'
                fill_in 'email', with: 'Foo'
                fill_in 'username', with: 'Foo'
                fill_in 'password', with: '123'
            end
            click_button('Create account')
            expect(page).to have_content("Please provide a valid email address.")
        end
    
        scenario("Should fail, username already in use") do
            visit "/"
            click_link('Sign Up')
            expect(page).to have_content("Create account")
            within("#signup") do
                fill_in 'first_name', with: 'First'
                fill_in 'last_name', with: 'Last'
                fill_in 'email', with: 'foo@bar.com'
                fill_in 'username', with: 'Bar'
                fill_in 'password', with: '123'
            end
            click_button('Create account')
            expect(page).to have_content("This username is already in use.")
        end
    
        scenario("Should fail, email is already in use") do
            visit "/"
            click_link('Sign Up')
            expect(page).to have_content("Create account")
            within("#signup") do
                fill_in 'first_name', with: 'First'
                fill_in 'last_name', with: 'Last'
                fill_in 'email', with: 'bar@bar.com'
                fill_in 'username', with: 'Foo'
                fill_in 'password', with: '123'
            end
            click_button('Create account')
            expect(page).to have_content("This email is already in use.")
        end
    
        scenario("Success & Logout") do
            visit "/"
            click_link('Sign Up')
            expect(page).to have_content("Create account")
            within("#signup") do
                fill_in 'first_name', with: 'First'
                fill_in 'last_name', with: 'Last'
                fill_in 'email', with: 'foo@bar.com'
                fill_in 'username', with: 'Foo'
                fill_in 'password', with: '123'
            end
            click_button('Create account')
            expect(page).to have_content("Logout")
            click_button('Logout')
        end
    end

    context("Login") do

        scenario("Should fail, password is invalid") do
            visit "/"
            click_link('Login')
            expect(page).to have_content("Log In")
            fill_in 'username', with: 'First'
            fill_in 'password', with: '123456'
            click_button('Log In')
            expect(page).to have_content("Username or password is invalid")
        end
    
        scenario("Should fail, email is invalid") do
            visit "/"
            click_link('Login')
            expect(page).to have_content("Log In")
            fill_in 'username', with: 'Not Foo'
            fill_in 'password', with: '123'
            click_button('Log In')
            expect(page).to have_content("Username or password is invalid")
        end
    
        scenario("Should pass, Successful") do
            visit "/"
            click_link('Login')
            expect(page).to have_content("Log In")
            fill_in 'username', with: 'Foo'
            fill_in 'password', with: '123'
            click_button('Log In')
            expect(page).to have_content("Logout")
            click_button('Logout')
        end
    end
end     

feature("Document") do

    context("Open") do
        
        before(:all) do
            visit "/"
            click_link('Login')
            expect(page).to have_content("Log In")
            within("#login") do
                fill_in 'username', with: 'Foo'
                fill_in 'password', with: '123'
            end
            click_button('Log In')
            expect(page).to have_content("Logout")

            visit "/profile/3"
            expect(page).to have_selector(:link_or_button, "Create Post")
            within("#create_document") do
                fill_in 'title', with: 'Doc1'
            end
            click_button('Create Post')
            expect(page).to have_selector(:link_or_button, "Edit")
            expect(page).to have_content("Doc1")
            click_button('Logout')

            visit "/"
            click_link('Login')
            expect(page).to have_content("Log In")
            within('#login') do
                fill_in 'username', with: 'Bar'
                fill_in 'password', with: '123'
            end
            click_button('Log In')
            expect(page).to have_content("Logout")

            visit "/profile/2"
            expect(page).to have_selector(:link_or_button, "Create Post")
            within("#create_document") do
                fill_in 'title', with: 'Doc2'
                fill_in 'guests', with: 'Foo'
            end
            click_button('Create Post')
            expect(page).to have_selector(:link_or_button, "Edit")
            expect(page).to have_content("Doc2")
            click_button('Logout')
        end

        scenario("Should pass, allowed: only owner") do
            visit "/"
            click_link('Login')
            expect(page).to have_content("Log In")
            within("#login") do
                fill_in 'username', with: 'Foo'
                fill_in 'password', with: '123'
            end
            click_button('Log In')
            
            visit "/profile/3"
            expect(page).to have_content("Doc1")
            expect(page).to have_selector(:link_or_button, "Edit")
            click_button('Logout')
        end

        scenario("Should pass, edit allowed document from another profile") do
            visit "/"
            click_link('Login')
            expect(page).to have_content("Log In")
            within("#login") do
                fill_in 'username', with: 'Foo'
                fill_in 'password', with: '123'
            end
            click_button('Log In')
            
            visit "/profile/2"
            expect(page).to have_content("Doc2")
            expect(page).to have_selector(:link_or_button, "Edit")
            click_button('Logout')
        end

        scenario("Should fail, not allowed") do
            visit "/"
            click_link('Login')
            expect(page).to have_content("Log In")
            fill_in 'username', with: 'Bar'
            fill_in 'password', with: '123'
            click_button('Log In')
            
            visit "/profile/3"
            expect(page).to have_content("Doc1")
            expect(page).to have_no_selector(:link_or_button, "Edit")
            click_button('Logout')
        end
    end

    context("Create") do

        before(:each) do
            visit "/"
            click_link('Login')
            expect(page).to have_content("Log In")
            within("#login") do
                fill_in 'username', with: 'Foo'
                fill_in 'password', with: '123'
            end
            click_button('Log In')
        end

        scenario("Should pass, Only with title") do
            visit "/profile/3"
            expect(page).to have_selector(:link_or_button, "Create Post")
            within("#create_document") do
                fill_in 'title', with: 'Doc2'
            end
            click_button('Create Post')
            expect(page).to have_selector(:link_or_button, "Edit")
            expect(page).to have_content("Doc2")
        end

        scenario("Ahould pass, Add existing user") do
            visit "/profile/3"
            expect(page).to have_selector(:link_or_button, "Create Post")
            within("#create_document") do
                fill_in 'title', with: 'Doc3'
                fill_in 'guests', with: 'Bar'
            end
            click_button('Create Post')
            expect(page).to have_selector(:link_or_button, "Edit")
            expect(page).to have_content("Doc3")
        end

        scenario("Shoud fail, add non existing user") do
            visit "/profile/3"
            expect(page).to have_selector(:link_or_button, "Create Post")
            within("#create_document") do
                fill_in 'title', with: 'Doc4'
                fill_in 'guests', with: 'Bar'
            end
            click_button('Create Post')
            expect(page).to have_selector(:link_or_button, "Edit")
            expect(page).to have_content("Doc4")
        end
    end
end
# cmd -> app.rb -> bundle exec rspec


#   click_link('Show Confirm')          -> klickar länken
#   fill_in 'Name', with: 'Jimmy'       -> fyller i formulär
#   click_button 'Like'                 -> klickar..
#   end