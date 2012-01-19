require 'spec_helper'

describe "mist/posts/edit" do
  before(:each) do
    @post = assign(:post, create(:post))
  end

  it "renders the edit post form" do
    render
  end
end
