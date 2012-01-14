require 'spec_helper'

describe Mist::Configuration do
  subject { Class.new { include Mist::Configuration }.new }
  
  it "should have a default repo location" do
    subject.repository_location.should_not be_blank
    subject.repository_location.should == subject.default_repository_location
  end
  
  it "should allow repo location to be set" do
    subject.repository_location = "123"
    subject.repository_location.should == '123'
  end
end
