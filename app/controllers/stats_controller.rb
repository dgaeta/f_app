class StatsController < ApplicationController
  # GET /stats
  # GET /stats.json
  def index
    @stats = Stat.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @stats }
    end
  end

  # GET /stats/1
  # GET /stats/1.json
  def show
    @stat = Stat.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @stat }
    end
  end

  # GET /stats/new
  # GET /stats/new.json
  def new
    @stat = Stat.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @stat }
    end
  end

  # GET /stats/1/edit
  def edit
    @stat = Stat.find(params[:id])
  end

  # POST /stats
  # POST /stats.json
  def create
    @stat = Stat.new(params[:stat])

    respond_to do |format|
      if @stat.save
        format.html { redirect_to @stat, notice: 'Stat was successfully created.' }
        format.json { render json: @stat, status: :created, location: @stat }
      else
        format.html { render action: "new" }
        format.json { render json: @stat.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /stats/1
  # PUT /stats/1.json
  def update
    @stat = Stat.find(params[:id])

    respond_to do |format|
      if @stat.update_attributes(params[:stat])
        format.html { redirect_to @stat, notice: 'Stat was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @stat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stats/1
  # DELETE /stats/1.json
  def destroy
    @stat = Stat.find(params[:id])
    @stat.destroy

    respond_to do |format|
      format.html { redirect_to stats_url }
      format.json { head :no_content }
    end
  end

  def user_stats
    user_stats = Stat.includes(:user).where(:winners_id => params[:user_id])

    money_earned = user_stats[0].money_earned
    games_played = user_stats[0].games_played
    games_won = user_stats[0].games_won
    joined_date = User.where(:id => params[:user_id]).pluck(:created_at).first
    joined_month = joined_date.month
    joined_day = joined_date.day
    joined_year = joined_date.year
    total_minutes_at_gym = user_stats.total_minutes_at_gym
    successful_checks = user_stats.successful_checks

    if user_stats == nil 
      then 
        false_json = { :status => "fail."} 
        render(json: JSON.pretty_generate(false_json))
      else
        true_json =  { :status => "okay" , :money_earned => money_earned, :games_played => games_played, :games_won => games_won, 
          :joined_month => joined_month, :joined_day => joined_day, :joined_year => joined_year, :successful_checks => successful_checks,
          :total_minutes_at_gym => total_minutes_at_gym}
        render(json: JSON.pretty_generate(true_json))
    end
  end
  
end
