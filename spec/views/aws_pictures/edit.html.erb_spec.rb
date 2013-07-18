require 'spec_helper'

describe "aws_pictures/edit" do
  before(:each) do
    @aws_picture = assign(:aws_picture, stub_model(AwsPicture,
      :name => "MyString"
    ))
  end

  it "renders the edit aws_picture form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", aws_picture_path(@aws_picture), "post" do
      assert_select "input#aws_picture_name[name=?]", "aws_picture[name]"
    end
  end
end
