require 'spec_helper'

describe "posts/index" do
  before(:each) do
    assign(:posts, [
      create(:post, :title => "one"),
      create(:post, :title => "two")
    ])
  end

  it "renders a list of posts" do
    render
  end
end
