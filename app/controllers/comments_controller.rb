class CommentsController < ApplicationController
 

  # GET /comments
  # GET /comments.json
  def index
    @comments = Comment.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @comments }
    end
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
    #@comment = Comment.find(params[:id])
    @comment = Comment.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @comment }
    end
  end

  # GET /comments/new
  # GET /comments/new.json
  def new
    @comment = Comment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @comment }
    end
  end

  # GET /comments/1/edit
  def edit
    @comment = Comment.find(params[:id])
  end

  # POST /comments
  # POST /comments.json
  def create
    @comment = Comment.new(params[:comment])
    @comment.save

    @game_id = @comment.from_game_id
    @user_id = @comment.from_user_id

    user = User.where(:id => @user_id).first
    users_game_member_info = GameMember.where(:user_id => @user_id, :game_id => @game_id).first

    @comment.first_name = user.first_name
    @comment.last_name = user.last_name
    @comment.from_game_id = @game_id
    @comment.from_user_id = @user_id 
    @comment.save

    respond_to do |format|
      if @comment.save
        true_json =  { :status => "okay"}
        format.html { redirect_to @comment, notice: 'Comment was successfully created.' }
        format.json { render json: JSON.pretty_generate(true_json) }
      else
        false_json = { :status => "fail."} 
        format.html { render action: "new" }
        ormat.json { render json: JSON.pretty_generate(false_json) }
      end
    end
  end



  # PUT /comments/1
  # PUT /comments/1.json
  def update
    @comment = Comment.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.html { redirect_to @comment, notice: 'Comment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to comments_url }
      format.json { head :no_content }
    end
  end



def game_comments 
   all_comments = Comment.where(:from_game_id => params[:game_id]).order("created_at DESC")

   all_comments = all_comments.map do |comment|
     {:_id => comment.id,
      :user_id => comment.from_user_id,
      :first_name => comment.first_name,
      :last_name => comment.last_name,
      :message => comment.message,
      :email => comment.email,
      :bold => comment.bold,
      :checkin => comment.checkin,
      :stamp => comment.created_at.strftime("%-I:%M%p (%m/%d/%y)")}
    end


    if all_comments == nil 
      then 
        false_json = { :status => "fail."} 
        render(json: JSON.pretty_generate(false_json))
      else
        true_json =  { :status => "okay" , :all_comments => all_comments }
        render(json: JSON.pretty_generate(true_json))
    end
  end

  def post_comment
    @comment = Comment.new(:from_user_id => params[:user_id],  :message => params[:message], :from_game_id => params[:game_id])
    @comment.save
    @comment.from_game_id = params[:game_id]
    t = Time.now
    @comment.stamp = t
    @comment.save

    @user_id = @comment.from_user_id

    user = User.where(:id => @user_id).first

    @comment.first_name = user.first_name
    @comment.last_name = user.last_name
    @comment.email = user.email
    @comment.save

    if @comment.save
  ########## push start ################
     notification = Gcm::Notification.new
     if user.device_id == "0" 
      device = Gcm::Device.all.first
      notification.device_id = device.id
     else 
      notification.device_id = Gcm::Device.where(:id => user.device_id).pluck(:id).first
     end
     notification.collapse_key = "Update"
     notification.delay_while_idle = true
     @game = Game.find(@comment.from_game_id)
     @a = 0 
     @num = @game.players
     @registration_ids = []
     user_ids = GameMember.where(:game_id => @game.id).pluck(:user_id)
     while @a < @num do 
      user = User.find(user_ids[@a])
      if (user.enable_notifications == "FALSE") or (user.device_id == "0")
        @a += 1 
      else
        unless @comment.from_user_id == user.id
        device = Gcm::Device.find(user.device_id)
        @registration_ids << device.registration_id
        end
        @a += 1 
      end
     end
     notification.data = {:registration_ids => @registration_ids,
      :data => {:message_text => "New Comment from Game #{@game.id}                                  "}}
     notification.save
     unless @registration_ids.empty?
       notification.save
     end
  ######### push end #####################
     true_json =  { :status => "okay"}
     render(json: JSON.pretty_generate(true_json))
    else
     false_json = { :status => "fail."} 
     render(json: JSON.pretty_generate(false_json) )
    end
  end

end
