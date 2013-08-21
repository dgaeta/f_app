require 'spec_helper'

describe "comment_replies/show" do
  before(:each) do
    @comment_reply = assign(:comment_reply, stub_model(CommentReply,
      :comment_id => "",
      :content_type => "Content Type",
      :message => "Message",
      :photo_url => "Photo Url",
      :from_user_id => 1,
      :from_user_profile_pic_url => "From User Profile Pic Url"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(//)
    rendered.should match(/Content Type/)
    rendered.should match(/Message/)
    rendered.should match(/Photo Url/)
    rendered.should match(/1/)
    rendered.should match(/From User Profile Pic Url/)
  end
end
