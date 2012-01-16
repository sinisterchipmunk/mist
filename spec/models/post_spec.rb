require 'spec_helper'

describe Post do
  it "preview" do
    subject.content = "# This is a header and stuff\r\nHere's a paragraph, or it would be if
      I had anything much to talk about, but it's really not right now because I'm busy.
      Go away.\r\n\r\nHere's some sample code to keep you sated:\r\n\r\n    file: test.rb\r\n
      \   one = :one\r\n\r\n## and this is another header"
    proc { subject.content_as_html_preview }.should_not raise_error
  end
  
  it "should omit cr's" do
    subject.content = "a\r\nb"
    subject.content.should == "a\nb"
  end
  
  describe "with 1 code example" do
    before do
      FakeWeb.register_uri(:post, 'https://api.github.com/gists', :response => fixture('gist_with_1_code_example'))
    end
    
    describe "reloading the post later" do
      before do
        FakeWeb.register_uri(:get, 'https://api.github.com/gists/1', :response => fixture('gist_with_1_code_example'))
        Post.create!(:title => 'Code Example', :content => "# Test Content\n\n    file: test.rb\n    def one\n      1\n    end\n\n# Moar test content")
      end
      
      subject { Post.find('code-example') }
      
      describe "and then adding a new code example" do
        before { subject.content << "\n    file: moar-file.rb\n    moar = :more\n\nDone" }
        
        it "should find 2 code examples" do
          subject.code_examples.should have(2).examples
        end
        
        it "should create a new gist file" do
          subject.set_gist_file_contents
          subject.gist.files.should have_key('moar-file.rb')
          subject.gist.files['moar-file.rb'].should have_key(:content)
          subject.gist.files['moar-file.rb'][:content].should == "moar = :more\n"
        end
      end
      
      describe "and then removing the code example" do
        before { subject.content = "no code examples here" }
        
        it "should find 0 code examples" do
          subject.code_examples.should be_empty
        end
        
        it "should mark gist files for deletion" do
          subject.set_gist_file_contents
          subject.gist.files.should have_key('test.rb')
          subject.gist.files['test.rb'].should be_nil
        end
      end
      
      describe "with the gist now missing" do
        before do
          FakeWeb.register_uri(:get, 'https://api.github.com/gists/1', :response => fixture('gist_404'))
        end
        
        it "should not raise an error" do
          proc { subject }.should_not raise_error
        end
        
        it "should embed code using regular markdown" do
          subject.content_as_html.should_not =~ /gist.github.com/
        end
        
        describe "when saving the record" do
          it "should create a new gist" do
            subject.save!
            subject.gist.should be_persisted
          end
        end
      end
      
      it "should ensure a blank line before and after gist embeds" do
        # otherwise not having the blanks will cause markdown to not handle headers properly
        content = subject.content_with_embedded_gists
        content.should =~ /\n\n<script.*?<\/script>\n\n/
      end

      it "should still have the gist" do
        subject.gist.should be_persisted
      end

      it "should contain gist code" do
        # so the blogger can later edit the gist.
        # Also, if the gist is externally upated, it should be reflected
        # when blog post is updated. This test shows as much because in
        # the fakeweb response, 1 is switched with :one.
        subject.content.should == "# Test Content\n\n    file: test.rb\n    def one\n      :one\n    end\n\n# Moar test content"
      end
    end
    
    describe "constructing a new post" do
      before do
        subject.title = "Code Example"
        subject.content = "# Test Content\n\n    file: test.rb\n    def one\n      1\n    end\n\n# Moar test content"
      end
      
      describe "the gist description" do
        let(:desc) { subject.gist.description }
        
        it "include link to post" do
          desc.should =~ /example.com\/posts\/code-example/
        end

        it "should not include code example filename" do
          subject.gist.description.should_not =~ /test.rb/
        end
      end

      it "should know its own url" do
        subject.url.should == "http://example.com/posts/code-example"
      end

      it { should have_code_examples }
    
      it "should embed the gist in html" do
        subject.save!
        embed = '<script src="https://gist.github.com/1.js?file=test.rb"></script>'
        subject.content_as_html.should =~ /#{Regexp::escape embed}/
      end
      
      it "should not embed the gist in html preview" do
        subject.save!
        subject.content_as_html_preview.should_not =~ /gist.github.com/
      end
      
      it "should not embed code in html preview" do
        subject.save!
        subject.content_as_html_preview.should_not =~ /file: test.rb/
        subject.content_as_html_preview.should_not =~ /def one/
      end
      
      it "should include the first line in html preview" do
        subject.save!
        subject.content_as_html_preview.should =~ /Test Content/
      end
      
      it "should not include moar content in the html preview" do
        subject.save!
        subject.content_as_html_preview.should_not =~ /Moar test content/
      end
    
      it "should not embed gist info if there are no code examples" do
        subject.content = "No code"
        subject.save!
        subject.content_as_html.should_not =~ /gist.github.com/
      end
    
      it "should use the example's filename" do
        # we don't want the fake response to modify the gist this time
        subject.gist.stub(:save).and_return(true)
        subject.save!
        subject.gist.files.should have_key('test.rb')
      end
    
      it "should identify 1 code example" do
        subject.code_examples.length.should == 1
        subject.code_examples.first.should == "def one\n  1\nend\n"
      end
    
      it "should not have saved a gist yet" do
        subject.gist.should_not be_persisted
      end

      describe "saving" do
        it "should save a gist" do
          subject.save!
          subject.gist.should be_persisted
        end
      end
    end
  end
  
  describe "with no code examples" do
    before do
      subject.title = "No Code Example"
      subject.content = "# Test Content"
    end
    
    it { should_not have_code_examples }
    
    it "should not have a gist at all" do
      subject.gist.should be_nil
    end
    
    it "should not create a gist" do
      subject.save!
      subject.gist.should be_nil
    end
  end
  
  describe "validation" do
    before { subject.valid? }
    
    it "should require title" do
      subject.errors[:title].should include("can't be blank")
    end
    
    it "should require content" do
      subject.errors[:content].should include("can't be blank")
    end
    
    it "should enforce uniqueness of title" do
      create :post
      post = build :post
      post.valid?
      post.errors[:title].should include("has already been taken")
    end
  end
  
  describe "creation" do
    it "should return the post" do
      Post.create!(attributes_for :post).should be_kind_of(Post)
    end
    
    it "should not be a new record" do
      Post.create!(attributes_for :post).should_not be_new_record
    end
  end
  
  describe "new valid record" do
    subject { build :post }
    
    it { should_not be_persisted }
    it { should be_new_record }
    it { should be_changed }
    
    describe "after saving" do
      before { subject.save! }
      
      it { should be_persisted }
      it { should_not be_new_record }
      it { should_not be_changed }
      
      it "should increase count" do
        Post.count.should == 1
      end

      it "should have created an attribute file" do
        File.should be_file(subject.path)
      end
      
      it "should have created a commit" do
        Mist.log.size.should == 1
      end
      
      it "should load the content in a separate query" do
        Post.find(subject.id).content.should == subject.content
      end
    end
  end
  
  describe "an existing record" do
    subject { create :post }
    
    describe "destroying" do
      before { subject.destroy }
      
      it "should not be found" do
        Post.find(subject.id).should be_nil
      end
      
      it "should produce a commit" do
        Mist.log.size.should == 2
      end
      
      it "should reduce count" do
        Post.count.should == 0
      end
    end
    
    describe "changing its content" do
      before { subject.content = "changed"; subject.save! }
      
      it "should create a commit" do
        Mist.log.size.should == 2
      end
      
      it "should load the new content in a separate query" do
        Post.find(subject.id).content.should == "changed"
      end
    end
    
    describe "changing its subject" do
      before do
        @old_path = subject.path
        subject.title = "changed"
        subject.save!
      end
      
      it "should create a commit" do
        Mist.log.size.should == 2
      end
      
      it "should have changed the content path" do
        @old_path.should_not == subject.path
      end
      
      it "should have removed the old content path" do
        File.should_not exist(@old_path)
      end
      
      it "should hvae created a new content path" do
        File.should be_file(subject.path)
      end
    end
    
    describe "changing its subject and its content simultaneously" do
      before do
        @old_path = subject.path
        subject.title = "changed"
        subject.content = "changed"
        subject.save!
      end
      
      it "should create a commit" do
        Mist.log.size.should == 2
      end
      
      it "should have changed the content path" do
        @old_path.should_not == subject.path
      end
      
      it "should have removed the old content path" do
        File.should_not exist(@old_path)
      end
      
      it "should have created a new content path" do
        File.should be_file(subject.path)
      end

      it "should load the new content in a separate query" do
        Post.find(subject.id).content.should == "changed"
      end
    end
  end
  
  describe "active model lint tests" do
    # make sure we didn't break them
    
    include Test::Unit::Assertions
    include ActiveModel::Lint::Tests
  
    def model
      @model ||= Class.new(Mist::GitModel) do
        def self.name
          "TestModel"
        end
      end.new
    end
  
    # to_s is to support ruby-1.9
    ActiveModel::Lint::Tests.public_instance_methods.map{|m| m.to_s}.grep(/^test/).each do |m|
      example m.gsub('_',' ') do
        send m
      end
    end
  end
end
