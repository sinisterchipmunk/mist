Given /^I am on the (.*?) page$/ do |name|
  visit Mist::Engine.routes.url_helpers.send("#{name.gsub(/ /, '_')}_path")
end

Given /^I am on the (.*?) page in "([^"]*)" format$/ do |name, format|
  visit Mist::Engine.routes.url_helpers.send("#{name.gsub(/ /, '_')}_path", :format => format)
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
  page.current_url.should =~ /^http:\/\/www.example.com\/#{name}\/?/
end

Then /^I should see "([^"]*)"$/ do |arg1|
  page.should have_content(arg1)
end

When /^I go to the (.*?) page$/ do |name|
  visit Mist::Engine.routes.url_helpers.send("#{name.gsub(/ /, '_')}_path")
end

Then /^I should not see "([^"]*)"$/ do |content|
  page.should_not have_content(content)
end

Then /^show me the response$/ do
  puts page.body
end

Then /^the page source should contain "([^"]*)"$/ do |src|
  page.body.should match(Regexp.compile(Regexp.escape src))
end
