class GameMembersController < ApplicationController
  # GET /game_members
  # GET /game_members.json
  def index
    @game_members = GameMember.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @game_members }
    end
  end

  # GET /game_members/1
  # GET /game_members/1.json
  def show
    @game_member = GameMember.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @game_member }
    end
  end

  # GET /game_members/new
  # GET /game_members/new.json
  def new
    @game_member = GameMember.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @game_member }
    end
  end

  # GET /game_members/1/edit
  def edit
    @game_member = GameMember.find(params[:id])
  end

  # POST /game_members
  # POST /game_members.json
  def create
    @game_member = GameMember.new(params[:game_member])

    respond_to do |format|
      if @game_member.save
        format.html { redirect_to @game_member, notice: 'Game member was successfully created.' }
        format.json { render json: @game_member, status: :created, location: @game_member }
      else
        format.html { render action: "new" }
        format.json { render json: @game_member.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /game_members/1
  # PUT /game_members/1.json
  def update
    @game_member = GameMember.find(params[:id])

    respond_to do |format|
      if @game_member.update_attributes(params[:game_member])
        format.html { redirect_to @game_member, notice: 'Game member was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @game_member.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /game_members/1
  # DELETE /game_members/1.json
  def destroy
    @game_member = GameMember.find(params[:id])
    @game_member.destroy

    respond_to do |format|
      format.html { redirect_to game_members_url }
      format.json { head :no_content }
    end
  end

 def number_of_players 
    @game_member = GameMember.where("game_id = ?", params[:game_id]).pluck(:game_id)
    

    render(:text => @game_member.count)

    respond_to do |format|
      format.json {  @game_member.count }
    end
  end 
 
 def check_in_request
   @game_member = GameMember.where("id = ?", params[2])  #find the current user and then bring him and his whole data down from the cloud
   @game_member.checkins - Time.now.to_i
   @game_member.save
   
   render(:text => @game_member)
   
   #@game_member.update_all(:checkins => 2 )
   #@current_user.update_attributes(params[:checkins])
   
  

    #respond_to do |format|
      #if @game_member.update_attributes(:checkins, @checkins)
        #format.html { redirect_to @game_member, notice: 'You checked in.' }
        #format.json { head :no_content }
      #else
        #format.html { redirect_to @game_member, notice: 'Check in unsuccessful.' }
        #format.json { render json: @game_member.errors, status: :unprocessable_entity }
      #end
    #end
  end

  def check_out_request
    @check_out_time_as_an_integer = Time.now.to_i - @check_in_time_as_an_integer

    
    check_out_time = Time.now
    
    render(:text => @check_out_time_as_an_integer)
 

    #respond_to do |format|
      #if @game_member.update_attributes(:checkins, @checkins)
        #format.html { redirect_to @game_member, notice: 'You checked in.' }
        #format.json { head :no_content }
      #else
        #format.html { redirect_to @game_member, notice: 'Check in unsuccessful.' }
        #format.json { render json: @game_member.errors, status: :unprocessable_entity }
      #end
    #end
  end


end
