Given /^I am on the (.*?) page$/ do |name|
  visit "/#{name}"
end

When /^I follow "([^"]*)"$/ do |arg1|
  click_link arg1
end

When /^I fill in "([^"]*)" with "([^"]*)"$/ do |arg1, arg2|
  fill_in arg1, :with => arg2
end

When /^I press "([^"]*)"$/ do |arg1|
  click_button arg1
end

Then /^I should be on the (.*?) page$/ do |name|
  page.current_url.should == "http://www.example.com/#{name}"
end

Then /^I should see "([^"]*)"$/ do |arg1|
  page.should have_content(arg1)
end
