require 'spec_helper'

describe "comment_replies/edit" do
  before(:each) do
    @comment_reply = assign(:comment_reply, stub_model(CommentReply,
      :comment_id => "",
      :content_type => "MyString",
      :message => "MyString",
      :photo_url => "MyString",
      :from_user_id => 1,
      :from_user_profile_pic_url => "MyString"
    ))
  end

  it "renders the edit comment_reply form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", comment_reply_path(@comment_reply), "post" do
      assert_select "input#comment_reply_comment_id[name=?]", "comment_reply[comment_id]"
      assert_select "input#comment_reply_content_type[name=?]", "comment_reply[content_type]"
      assert_select "input#comment_reply_message[name=?]", "comment_reply[message]"
      assert_select "input#comment_reply_photo_url[name=?]", "comment_reply[photo_url]"
      assert_select "input#comment_reply_from_user_id[name=?]", "comment_reply[from_user_id]"
      assert_select "input#comment_reply_from_user_profile_pic_url[name=?]", "comment_reply[from_user_profile_pic_url]"
    end
  end
end
