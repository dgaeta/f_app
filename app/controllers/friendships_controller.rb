class FriendshipsController < ApplicationController
  # GET /friendships
  # GET /friendships.json
  def index
    @friendships = Friendship.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @friendships }
    end
  end

  # GET /friendships/1
  # GET /friendships/1.json
  def show
    @friendship = Friendship.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @friendship }
    end
  end

  # GET /friendships/new
  # GET /friendships/new.json
  def new
    @friendship = Friendship.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @friendship }
    end
  end

  # GET /friendships/1/edit
  def edit
    @friendship = Friendship.find(params[:id])
  end

  # POST /friendships
  # POST /friendships.json
  def create
    @friendship = current_user.friendships.build(:friend_id => params[:friend_id])
    @friendship.status = "SENT"
    if @friendship.save
      flash[:notice] = "Added friend."
      redirect_to root_url
    else
      flash[:error] = "Unable to add friend."
      redirect_to root_url
    end
  end

  # PUT /friendships/1
  # PUT /friendships/1.json
  def update
    @friendship = Friendship.find(params[:id])

    respond_to do |format|
      if @friendship.update_attributes(params[:friendship])
        format.html { redirect_to @friendship, notice: 'Friendship was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @friendship.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /friendships/1
  # DELETE /friendships/1.json
  def destroy
    @friendship = current_user.friendships.find(params[:id])
    @friendship.destroy
    flash[:notice] = "Removed friendship."
    redirect_to current_user
  end

  def accept_friend
    @userRecipient = User.where(:id => params[:user_id]).first
    friendship = Friendship.where(:user_id => @userRecipient.id, :friend_id => params[:friend_id]).first
    unless friendship
      @friend = User.where(:id => params[:friend_id]).first
      @responseFriendship = @userRecipient.friendships.build(:friend_id => params[:friend_id], :status => "ACCEPTED", 
        :friend_first_name => @friend.first_name, :friend_last_name => @friend.last_name)
      @responseFriendship.save 

      @userWhoSentRequest = User.where(:id => params[:friend_id]).first
      @sentFriendship =  @userWhoSentRequest.friendships.where(:friend_id => @userRecipient.id).first
      @sentFriendship.status = "ACCEPTED"
      @sentFriendship.save
      @notification = Notification.new
      @notification.content = "Friend request accepted"
      @notification.message = @userRecipient.first_name + " is now your friend on Fitsby!"
      @notification.notifiable_id = @userWhoSentRequest.id
      @notification.sender_id = @userRecipient.id 
      @notification.save

      true_json =  { :status => "okay"  }
      render(json: JSON.pretty_generate(true_json))
      return
    end
    failed_request_json =  { :status => "friendship already exists"  }
    render(json: JSON.pretty_generate(failed_request_json))
    return
  end

  def create_friend_request
    @user = User.where(:id => params[:user_id]).first 
    friendship = Friendship.where(:user_id => @user.id, :friend_id => params[:friend_id]).first
    unless friendship
      @friendship = @user.friendships.build(:friend_id => params[:friend_id], :status => "SENT")
      @friend = User.where(:id => params[:friend_id]).first
      @friendship.friend_first_name = @friend.first_name
      @friendship.friend_last_name = @friend.last_name
      if @friendship.save
        @notification = Notification.new
        @notification.content = "Friend request"
        @notification.notifiable_type = "User"
        @notification.message = @user.first_name + " wants to be your friend on Fitsby!"
        @notification.notifiable_id = params[:friend_id]
        @notification.sender_id = @user.id 
        @notification.save
        request_sent_json =  { :status => "friend request sent"  }
        render(json: JSON.pretty_generate(request_sent_json))
        return 
      else
        failed_request_json =  { :status => "fail"  }
        render(json: JSON.pretty_generate(failed_sent_json))
        return
      end
    end
      failed_request_json =  { :status => "friend request already sent"  }
      render(json: JSON.pretty_generate(failed_request_json))
      return 
  end

  def show_friends
    @user = User.where(:id => params[:user_id]).first 
    s3 = AWS::S3.new
    bucket_for_prof_pics = s3.buckets['profilepics.fitsby.com']
  
    if @user 
      friends = @user.friendships.where(:status => "ACCEPTED")
      friends = friends.map do |friend|
        {:friend_id => friend.friend_id,
        :first_name => friend.friend_first_name,
        :last_name => friend.friend_last_name,
        :contains_sender_profile_pic => User.where(:id => friend.friend_id).pluck(:contains_profile_picture).first,
        :sender_profile_pic =>  (bucket_for_prof_pics.objects[User.where(:id => friend.friend_id).pluck(:s3_profile_pic_name)].url_for(:read, :expires => 10*60))}
      end
      friends_json =  { :status => "okay", :friends => friends  }
      render(json: JSON.pretty_generate(friends_json))
    else 
      failed_request_json =  { :status => "fail"  }
      render(json: JSON.pretty_generate(request_sent_json))
    end
  end


end
