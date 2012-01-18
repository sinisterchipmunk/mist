Then /^the "([^"]*)" sidebar should contain:$/ do |which, table|
  id = "sidebar-#{which.gsub(/ /, '-')}"
  hashes = table.hashes
  
  hashes.each do |hash|
    find('#'+id).should have_content(hash['title'])
  end
end
