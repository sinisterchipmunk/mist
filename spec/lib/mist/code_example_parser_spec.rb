require 'spec_helper'

describe Mist::CodeExampleParser do
  describe "with nil arg" do
    subject { Mist::CodeExampleParser.new(nil).examples }
    it { should have(0).examples }
  end
  
  describe "with text but no examples" do
    subject { Mist::CodeExampleParser.new("this is text").examples }
    it { should have(0).examples }
  end
  
  describe "with text and blank lines but no examples" do
    subject { Mist::CodeExampleParser.new("this is\n\ntext").examples }
    it { should have(0).examples }
  end
  
  describe "with crlf" do
    subject { Mist::CodeExampleParser.new("# Test\r\n\r\n    file: test.rb\r\n    one = :one\r\n") }
    
    it "should strip cr from filenames" do
      subject.examples[0].filename.should == "test.rb"
    end
    
    it "should not leave cr or lf preceding code" do
      subject.examples[0][0].should_not == ?\r
      subject.examples[0][0].should_not == ?\n
    end
  end
  
  let(:basic_code) { "    def one\n      1\n    end" }
  let(:content) { basic_code }
  subject { Mist::CodeExampleParser.new(content).examples }
  
  describe "with 1 code example with explicit filename" do
    let(:content) { "test1\n    file: filename.rb\n#{basic_code}\ntest2" }
    it "should set filename" do
      subject[0].filename.should == "filename.rb"
    end
    it "should not have filename in content" do
      subject[0].should == "def one\n  1\nend\n"
    end
    it "should not affect its range" do
      content[subject[0].offset].should == "    file: filename.rb\n#{basic_code}\n"
    end
  end

  describe "2 examples with different filenames" do
    let(:content) { "    file: file1.rb\n#{basic_code}\n\n    file: file2.rb\n#{basic_code}" }
    it "should not merge the examples" do
      subject[0].filename.should == 'file1.rb'
      subject[1].filename.should == 'file2.rb'
    end
  end
  
  describe "with 1 code example but no text" do
    it { should have(1).example }
    
    it "should have a default filename" do
      subject[0].filename.should == "Example 1"
    end
    
    it "should define a range" do
      content[subject[0].offset].should == basic_code
    end
    
    it "should outdent code appropriately" do
      subject[0].should == "def one\n  1\nend"
    end
  end
  
  describe "with text preceding 1 code example" do
    let(:content) { "this is text\n#{basic_code}" }
    
    it { should have(1).example }
    
    it "should outdent code" do
      subject[0].should == "def one\n  1\nend"
    end
    
    it "should define a range" do
      content[subject[0].offset].should == basic_code
    end
  end
  
  describe "with text proceding 1 code example" do
    let(:content) { "#{basic_code}\nthis is text" }
    
    it { should have(1).example }
    
    it "should outdent code" do
      subject[0].should == "def one\n  1\nend\n"
    end
    
    it "should define a range" do
      content[subject[0].offset].should == "#{basic_code}\n"
    end
  end
  
  describe "with 2 code examples separated by text" do
    let(:content) { "#{basic_code}\nthis is text\n#{basic_code}" }
    
    it { should have(2).examples }
    
    it "should give default filenames" do
      subject[0].filename.should == "Example 1"
      subject[1].filename.should == "Example 2"
    end
    
    it "should outdent code" do
      subject[0].should == "def one\n  1\nend\n"
      subject[1].should == "def one\n  1\nend"
    end
    
    it "should define a range" do
      content[subject[0].offset].should == "#{basic_code}\n"
      content[subject[1].offset].should == "#{basic_code}"
    end
  end
  
  describe "1 example with a blank line in it" do
    let(:content) { "#{basic_code}\n\n#{basic_code}" }
    
    it { should have(1).example }
    
    it "should outdent code" do
      subject[0].should == "def one\n  1\nend\n\ndef one\n  1\nend"
    end
    
    it "should define a range" do
      content[subject[0].offset].should == content
    end
  end
end
