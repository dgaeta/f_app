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

    respond_to do |format|
      if @comment.save
        format.html { redirect_to @comment, notice: 'Comment was successfully created.' }
        format.json { render json: @comment, status: :created, location: @comment }
      else
        format.html { render action: "new" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
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

=begin  def gamecomments

    # GET /gamecomments/1
    # GET /gamecomments/1.json
    @comment = Comment.find(params[:from_id])
    @comment_step2 = @comment_step1.find("game_member_id = ?", params[:league_id])
    

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @comment }
    end
  end
=end

  def game_comments 
    game_members = GameMember.where(:game_id => params[:game_id]).pluck(:id)
    number_of_players = game_members.count

    
    @user = User.first
    @user.game_members.collect { |u| u.comments }

    @game = Game.first
    @game.game_members.collect { |g| g.comments }
 

      @i = 0
        @num = number_of_players

      while @i < @num  do
      game_member_id = game_members[@i]
      user_id = GameMember.where(:id => game_member_id).pluck(:user_id)
      name = User
      player_stats.losses += 1
      player_stats.save
      @i +=1
      end


    render(:json => @game_member_comments)
  end
end
