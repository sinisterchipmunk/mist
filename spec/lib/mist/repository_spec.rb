require 'spec_helper'

describe Mist do
  it "should generate the repo automatically" do
    Mist.repository
    File.should be_directory(Mist.repository_location.join('.git'))
  end
  
  describe "with an existing repo" do
    before do
      Git.init(Mist.repository_location.to_s)
    end
    
    it "should not generate the repo" do
      Git.should_not_receive(:init)
      
      Mist.repository
    end
  end
end
