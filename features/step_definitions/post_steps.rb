Given /^I have created a post called "([^"]*)"$/ do |title|
  step 'I am on the posts page'
  step 'I follow "New Post"'
  step 'I fill in "Title" with "%s"' % title
  step 'I fill in "Content" with "This is post content"'
  step 'I press "Save"'
end

Given /^I have published a post called "([^"]*)"$/ do |title|
  step 'I am on the posts page'
  step 'I follow "New Post"'
  step 'I fill in "Published at" with "%s"' % Time.now
  step 'I fill in "Title" with "%s"' % title
  step 'I fill in "Content" with "This is post content"'
  step 'I press "Save"'
end

When /^I create a post called "([^"]*)"$/ do |title|
  step 'I have created a post called "%s"' % title
end

When /^I publish a post called "([^"]*)"$/ do |title|
  step 'I have published a post called "%s"' % title
end

When /^I edit the "([^"]*)" post$/ do |post_title|
  step 'I look at the "%s" post' % post_title
  step 'I follow "Edit"'
end

When /^I look at the "([^"]*)" post$/ do |post_title|
  step 'I am on the posts page'
  step 'I follow "%s"' % post_title
end
