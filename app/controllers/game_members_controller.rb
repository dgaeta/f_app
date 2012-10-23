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
    

    render(:json => @game_member.count)
  end

 
 def check_in_request
   @game_member = GameMember.find(params[:id])  #find the current user and then bring him and his whole data down from the cloud
   @game_member.checkins = Time.now.to_i
   @game_member.save
   
   render(:json => @game_member)
   
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
   @game_member = GameMember.find(params[:id])  #find the current user and then bring him and his whole data down from the cloud
   @game_member.checkouts = Time.now.to_i
   @game_member.save
   

   #VALIDATING TIME AT GYM 

    last_checkin = GameMember.where( "id = ?", params[:id]).pluck(:checkins)
    last_checkout = GameMember.where("id = ?", params[:id]).pluck(:checkouts)

    total_minutes_at_gym = last_checkout[0] - last_checkin[0]

   
        if total_minutes_at_gym > 2700 
          @game_member.successful_checks += 1
          @game_member.save
           render(json: @game_member) 
        else
          render(json: @game_member)
        end
  end


 

  def leaderboard 
    members_in_game = GameMember.
      includes(:user).
      where(:game_id => params[:game_id]).
      order("successful_checks DESC")

       

      leaderboard_stats = members_in_game.map do |member|
      {:user_id => member.user.id,
      :first_name => member.user.first_name,
      :last_name => member.user.last_name,
      :successful_checks => member.successful_checks}
    end


    render(:json => leaderboard_stats) #+ @leaderboard_last_name + @leaderboard_first_name)
  end

  def pot_size 
    number_of_players = GameMember.where("game_id = ?", params[:game_id]).pluck(:game_id)
    number_of_players = number_of_players.count
    wager = Game.where("id = ?", params[:game_id]).pluck(:wager)
    wager = wager[0].to_i

    pot_size = number_of_players*wager

    
    render(:json => pot_size)
  end


end
