When /^I run "([^"]*)"$/ do |arg1|
  @execution_results = %x[#{arg1}]
  $?.should be_success
  @execution_results.should_not match(/Could not find generator/)
end

Then /^there should be a directory called "([^"]*)"$/ do |arg1|
  File.should be_directory(arg1)
end

Then /^the "([^"]*)" directory should be a git repository$/ do |arg1|
  step 'there should be a directory called "%s/.git"' % arg1
end
