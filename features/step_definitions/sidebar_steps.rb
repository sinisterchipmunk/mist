Then /^the "([^"]*)" sidebar should contain:$/ do |which, table|
  table.hashes.each do |hash|
    step 'the "%s" sidebar should contain "%s"' % [which, hash['title']]
  end
end

Then /^the "([^"]*)" sidebar should not contain:$/ do |which, table|
  table.hashes.each do |hash|
    step 'the "%s" sidebar should not contain "%s"' % [which, hash['title']]
  end
end

Then /^the "([^"]*)" sidebar should contain "([^"]*)"$/ do |which, content|
  id = "sidebar-#{which.gsub(/ /, '-')}"
  find('#'+id).should have_content(content)
end

Then /^the "([^"]*)" sidebar should not contain "([^"]*)"$/ do |which, content|
  id = "sidebar-#{which.gsub(/ /, '-')}"
  find('#'+id).should_not have_content(content)
end
