require 'spec_helper'

describe Mist::Permalink do
  include Mist::Permalink
  
  it "should not include periods" do # they screw with rails' formats
    permalink("Stuck in Rails 2? Use Bundler. For everything. Right now.").should_not match(/\./)
  end
  
  it "should not create double dashes" do # they're ugly
    permalink("Stuck in Rails 2? Use Bundler. For everything. Right now.").should_not match(/--/)
  end
  
  it "should not end with dashes" do # ditto
    permalink("Stuck in Rails 2? Use Bundler. For everything. Right now.").should_not match(/-$/)
  end
end
