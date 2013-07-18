require 'spec_helper'

describe "aws_pictures/new" do
  before(:each) do
    assign(:aws_picture, stub_model(AwsPicture,
      :name => "MyString"
    ).as_new_record)
  end

  it "renders new aws_picture form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", aws_pictures_path, "post" do
      assert_select "input#aws_picture_name[name=?]", "aws_picture[name]"
    end
  end
end
