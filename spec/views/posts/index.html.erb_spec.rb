require 'spec_helper'

describe "posts/index" do
  NUMBERS = %w(one two three four five six seven eight nine ten)
  
  before(:each) do
    list = []
    NUMBERS.each do |n|
      list << create(:post, :title => n, :content => "#{n}-Paragraph1\n\n#{n}-Paragraph2")
    end
    assign(:posts, list)
  end

  it "renders the full content of the first post" do
    render
    rendered.should =~ /one-Paragraph1/
    rendered.should =~ /one-Paragraph2/
  end
  
  it "renders only the first paragraph of all other posts" do
    render
    NUMBERS[1..-1].each do |n|
      rendered.should =~ /#{n}-Paragraph1/
      rendered.should_not =~ /#{n}-Paragraph2/
    end
  end
end
