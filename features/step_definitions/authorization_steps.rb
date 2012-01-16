Given /^I am not authorized$/ do
  Mist.reset_authorizations!
end

Given /^I am authorized$/ do
  Mist.authorize { |controller| true }
end

Given /^I am authorized to (.*)$/ do |what|
  what = what.gsub(/ /, '_').underscore.to_sym
  Mist.authorize(what) { |controller| true }
end

Given /^I am not authorized to (.*)$/ do |what|
  what = what.gsub(/ /, '_').underscore.to_sym
  Mist.authorize(what) { |controller| false }
end
