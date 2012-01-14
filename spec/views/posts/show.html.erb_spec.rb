require 'spec_helper'

describe "posts/show" do
  before(:each) do
    @post = assign(:post, create(:post))
  end

  it "renders attributes in <p>" do
    render
  end
end
