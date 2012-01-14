Given /^I have created a post called "([^"]*)"$/ do |title|
  step 'I am on the posts page'
  step 'I follow "New Post"'
  step 'I fill in "Title" with "Post title"'
  step 'I fill in "Content" with "This is post content"'
  step 'I press "Save"'
end
