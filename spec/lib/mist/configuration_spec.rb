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
  
  describe "authorization" do
    it "should accept multiple arguments" do
      Mist.authorize(:one, :two) { true }
      Mist.should be_authorized(:one)
      Mist.should be_authorized(:two)
    end
    
    it "should work default to :all given no arguments" do
      Mist.authorize { true }
      Mist.should be_authorized(:create_post)
    end
    
    it "should require a block to set up" do
      proc { Mist.authorize(:test) }.should raise_error(ArgumentError)
    end
    
    describe "with authorization for a single action" do
      before { Mist.authorize(:test) { |*c| @received = c; true } }
    
      it "should return the block result" do
        Mist.should be_authorized(:test)
      end
      
      it "should pass extra arguments to the block" do
        Mist.authorized?(:test, 1, 2, 3)
        @received.should == [1, 2, 3]
      end
      
      it "should return false for other actions" do
        Mist.should_not be_authorized(:other)
      end
      
      it "should reset" do
        Mist.reset_authorizations!
        Mist.should_not be_authorized(:test)
      end
    end
  
    describe "with authorization for all actions" do
      before { Mist.authorize(:all) { true } }
    
      it "should return block result for any action" do
        Mist.should be_authorized(:test)
      end
    end
    
    describe "by default" do
      it "should deny authorization for all actions" do
        Mist.should_not be_authorized(:test)
      end
    end

    describe "overriding all actions with a given action" do
      before { Mist.authorize(:all) { true }; Mist.authorize(:test) { false } }
  
      it "should return overridden result for the overridden action" do
        Mist.should_not be_authorized(:test)
      end
    
      it "should not return overridden result for other actions" do
        Mist.should be_authorized(:other)
      end
    end
  
    describe "overriding the same action" do
      before { Mist.authorize(:test) { false }; Mist.authorize(:test) { true } }
    
      it "should use the last block given" do
        Mist.should be_authorized(:test)
      end
    end
  end
end
