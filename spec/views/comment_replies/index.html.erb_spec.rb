require 'spec_helper'

describe "comment_replies/index" do
  before(:each) do
    assign(:comment_replies, [
      stub_model(CommentReply,
        :comment_id => "",
        :content_type => "Content Type",
        :message => "Message",
        :photo_url => "Photo Url",
        :from_user_id => 1,
        :from_user_profile_pic_url => "From User Profile Pic Url"
      ),
      stub_model(CommentReply,
        :comment_id => "",
        :content_type => "Content Type",
        :message => "Message",
        :photo_url => "Photo Url",
        :from_user_id => 1,
        :from_user_profile_pic_url => "From User Profile Pic Url"
      )
    ])
  end

  it "renders a list of comment_replies" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "Content Type".to_s, :count => 2
    assert_select "tr>td", :text => "Message".to_s, :count => 2
    assert_select "tr>td", :text => "Photo Url".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "From User Profile Pic Url".to_s, :count => 2
  end
end
