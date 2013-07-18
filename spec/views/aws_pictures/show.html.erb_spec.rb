require 'spec_helper'

describe "aws_pictures/show" do
  before(:each) do
    @aws_picture = assign(:aws_picture, stub_model(AwsPicture,
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
  end
end
