class CommentsController < ApplicationController
 before_filter :load_commentable

  # GET /comments
  # GET /comments.json
  def index
    @comments = @commentable.comments

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
    @comment = @commentable.comments.new

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
    #@comment = Comment.new(params[:comment])
    # @comment.save

    # @game_id = @comment.from_game_id
    # @user_id = @comment.from_user_id

    # user = User.where(:id => @user_id).first
    # users_game_member_info = GameMember.where(:user_id => @user_id, :game_id => @game_id).first

    # @comment.first_name = user.first_name
    # @comment.last_name = user.last_name
    # @comment.from_game_id = @game_id
    # @comment.from_user_id = @user_id 
    # @comment.save
    @comment = @commentable.comments.new(params[:comment])

    respond_to do |format|
      if @comment.save
        true_json =  { :status => "okay"}
        format.html { redirect_to @commentable, notice: 'Comment was successfully created.' }
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
   all_comments = Comment.includes(:user).where(:from_game_id => params[:game_id]).order("created_at DESC")
   s3 = AWS::S3.new
   bucket_for_comments = s3.buckets['images.fitsby.com']
   bucket_for_prof_pics = s3.buckets['profilepics.fitsby.com']
   user_id = params[:user_id]

   if user_id
     all_comments = all_comments.map do |comment|
       {:_id => comment.id,
        :user_id => comment.from_user_id,
        :contains_profile_picture => comment.contains_profile_picture,
        #:profile_picture_name =>  (bucket_for_prof_pics.objects[comment.s3_profile_pic_name].url_for(:read, :expires => 10*60)),
        :first_name => comment.first_name,
        :last_name => comment.last_name,
        :message => comment.message,
        :email => comment.email,
        :liked_by_user =>  comment.likers.include?(user_id.to_s), 
        :number_of_likes => comment.likes,
        :bold => comment.bold,
        :checkin => comment.checkin,
        :comment_type => comment.comment_type,
        :image_name => (bucket_for_comments.objects[comment.image_name].url_for(:read, :expires => 10*60)),
        :stamp => comment.created_at.strftime("%-I:%M%p (%m/%d/%y)")}
      end
    else 
      all_comments = all_comments.map do |comment|
       {:_id => comment.id,
        :user_id => comment.from_user_id,
        :contains_profile_picture => comment.contains_profile_picture,
        #:profile_picture_name =>  (bucket_for_prof_pics.objects[comment.s3_profile_pic_name].url_for(:read, :expires => 10*60)),
        :first_name => comment.first_name,
        :last_name => comment.last_name,
        :message => comment.message,
        :email => comment.email,
        #:liked_by_user =>  comment.likers_by.include?(user_id), 
        :number_of_likes => comment.likes,
        :bold => comment.bold,
        :checkin => comment.checkin,
        :comment_type => comment.comment_type,
        :image_name => (bucket_for_comments.objects[comment.image_name].url_for(:read, :expires => 10*60)),
        :stamp => comment.created_at.strftime("%-I:%M%p (%m/%d/%y)")}
      end
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
    @comment.from_user_id = params[:user_id]
    t = Time.now
    @comment.stamp = t
    @comment.save

    @user_id = @comment.from_user_id

    user = User.where(:id => @user_id).first
    user.comments_made +=1 
    user.save

    if user.s3_profile_pic_name == "none"
      @comment.contains_profile_picture = "FALSE"
    else 
      @comment.contains_profile_picture = "TRUE"
    end
    @comment.first_name = user.first_name
    @comment.last_name = user.last_name
    @comment.email = user.email
    

    if @comment.save
     true_json =  { :status => "okay"}
     render(json: JSON.pretty_generate(true_json))
    else
     false_json = { :status => "fail."} 
     render(json: JSON.pretty_generate(false_json) )
    end
  end


    
 def multimedia_message
    @comment = Comment.new(:from_user_id => params[:user_id],  :message => params[:message], :from_game_id => params[:game_id],
      :image_name => params[:image_name], :comment_type => params[:comment_type])
    t = Time.now
    @comment.stamp = t
    @comment.save

    user = User.where(:id => @comment.from_user_id).first
    @comment.first_name = user.first_name
    @comment.last_name = user.last_name

    if @comment.save
     true_json =  { :status => "okay"}
     render(json: JSON.pretty_generate(true_json))
    else
     false_json = { :status => "fail."} 
     render(json: JSON.pretty_generate(false_json) )
    end
  end

  def like_comment
    @comment = Comment.where(:id => params[:comment_id]).first 
    @user = User.where(:id => params[:user_id]).first 

    if @user.nil? || @comment.nil?
      false_json = { :status => "user or comment not found"} 
      render(json: JSON.pretty_generate(false_json) )
    else
      if @comment.liked_by.nil?
        @comment.likes += 1
        @comment.liked_by = @user.id.to_s + ","
        liked_json = { :status => "liked"} 
        render(json: JSON.pretty_generate(liked_json) )
      else
        liked_by_array = @comment.liked_by.split(',') 
        int_array = liked_by_array.map {|value| value.to_i}
          
        if int_array.include?(@user.id)
          @comment.likes -= 1 
          @comment.drop(@user.id)
          unliked_json = { :status => "unliked"} 
          render(json: JSON.pretty_generate(unliked_json) )
        else 
          @comment.likes += 1
          @comment.liked_by = ("," + @user.id.to_s) 
          liked_json = { :status => "liked"} 
          render(json: JSON.pretty_generate(liked_json) )
        end
      end
    end
  end

  def deleteSingleComment(comment_id)
    @comment = Comment.find(comment_id)
    @comment.destroy
  end

  def deleteSingleCommentAPI
    @comment = Comment.find(:id => params[:comment_id])
    @comment.destroy 
  end

  def deleteEntireGamesComments(game_id)
    comments = Comment.where(:from_game_id => game_id).first

    comments.each do |comment|
      comment.destroy
    end
  end

  def deleteEntireGamesCommentsAPI
    comments = Comment.where(:from_game_id => params[:from_game_id]).first

    comments.each do |comment|
      comment.destroy
    end
  end

private
 def load_commentable
  klass = [Game, User, ProfilePicture, Stat].detect { |c| params["#{c.name.underscore}_id"]}
  @commentable = klass.find(params["#{klass.name.underscore}_id"])
end

end
