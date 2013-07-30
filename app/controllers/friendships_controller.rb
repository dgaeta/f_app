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
    @responseFriendship = @userRecipient.friendships.build(:friend_id => params[:friend_id])
    @reponseFriendship.status = "ACCEPTED"
    @responseFriendship.save 

    @userWhoSentRequest = User.where(:id => params[:friend_id]).first
    @sentFriendship =  @userWhoSentRequest.friendships.where(:friend_id => @userRecipient.id)
    @sentFriendship.status = "ACCEPTED"
    @sentFriendship.save
    @notification = Notification.new
    @notification.content = "Friend request accepted"
    @notification.message = @userRecipient.first_name + "is now your friend on Fitsby!"
    @notification.notifiable_id = param[:friend_id]
    @notification.sender_id = @userRecipient.id 
    @notification.save

    true_json =  { :status => "okay"  }
    render(json: JSON.pretty_generate(true_json))
    
  end

  def create_friend_request
    @user = User.where(:id => params[:user_id]).first 
    @friendship = @user.friendships.build(:friend_id => params[:friend_id])
    @friendship.status = "SENT"
    if @friendship.save
      @notification = Notification.new
      @notification.content = "Friend request"
      @notification.message = @user.first_name + " wants to be your friend on Fitsby!"
      @notification.notifiable_id = params[:friend_id]
      @notification.sender_id = @user.id 
      @notification.save
      request_sent_json =  { :status => "friend request sent"  }
      render(json: JSON.pretty_generate(request_sent_json))
    else
      failed_request_json =  { :status => "fail"  }
      render(json: JSON.pretty_generate(request_sent_json))
    end
  end

  def show_friends
    @user = User.where(:id => params[:user_id]).first 
  
    if @user 
      friends = @user.friendships.where(:status => "ACEEPTED")
      friends_json =  { :status => "okay", :friends => friends  }
      render(json: JSON.pretty_generate(friends_json))
    else 
      failed_request_json =  { :status => "fail"  }
      render(json: JSON.pretty_generate(request_sent_json))
    end
  end


end
