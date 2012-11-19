class ChecklocationsController < ApplicationController
  # GET /checklocations
  # GET /checklocations.json
  def index
    @checklocations = Checklocation.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @checklocations }
    end
  end

  # GET /checklocations/1
  # GET /checklocations/1.json
  def show
    @checklocation = Checklocation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @checklocation }
    end
  end

  # GET /checklocations/new
  # GET /checklocations/new.json
  def new
    @checklocation = Checklocation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @checklocation }
    end
  end

  # GET /checklocations/1/edit
  def edit
    @checklocation = Checklocation.find(params[:id])
  end

  # POST /checklocations
  # POST /checklocations.json
  def create
    @checklocation = Checklocation.new(params[:checklocation])

    respond_to do |format|
      if @checklocation.save
        format.html { redirect_to @checklocation, notice: 'Checklocation was successfully created.' }
        format.json { render json: @checklocation, status: :created, location: @checklocation }
      else
        format.html { render action: "new" }
        format.json { render json: @checklocation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /checklocations/1
  # PUT /checklocations/1.json
  def update
    @checklocation = Checklocation.find(params[:id])

    respond_to do |format|
      if @checklocation.update_attributes(params[:checklocation])
        format.html { redirect_to @checklocation, notice: 'Checklocation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @checklocation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /checklocations/1
  # DELETE /checklocations/1.json
  def destroy
    @checklocation = Checklocation.find(params[:id])
    @checklocation.destroy

    respond_to do |format|
      format.html { redirect_to checklocations_url }
      format.json { head :no_content }
    end
  end


  def validate_gym
    @decidedlocations = Decidedlocation.where(:gym_name => params[:gym_name].downcase).first
    @user = User.where(:id => params[:user_id]).first
    @user_email = @user.email
    @gym_name = params[:gym_name]

   if  @decidedlocations == nil 
    then  
    @checklocation = Checklocation.new
    @checklocation = Checklocation.new(:requester_id => params[:user_id], :gym_name => params[:gym_name], :geo_lat => params[:geo_lat],
     :geo_long => params[:geo_long])
    @checklocation.save
    @user.number_of_requests += 1
    @number_of_requests = @user.number_of_requests
    @user.save

    @decidedlocation = Decidedlocation.new(:gym_name => params[:gym_name], :geo_lat => params[:geo_lat],
     :geo_long => params[:geo_long])
    @decidedlocation.save
  

    @geo_lat = @checklocation.geo_lat
    @geo_long = @checklocation.geo_long

    @string = "checking location, check in allowed."
     true_json =  { :status => "okay", :string => @string }
          render(json: JSON.pretty_generate(true_json))
        UserMailer.check_location_mailer(@user, @geo_lat, @geo_long, @gym_name, @user_email, @string , @number_of_requests).deliver

     elsif @decidedlocations.decision.nil?
      @decidedlocations.number_of_requests += 1
      @number_of_requests_for_gym = @decidedlocations.number_of_requests
      @decidedlocations_id = @decidedlocations.id
      @user.number_of_requests += 1
      @user.save

      @number_of_requests_by_user = @user.number_of_requests
      @number_of_requests_for_gym = @decidedlocations.number_of_requests

  

      @string = "still working on location, check in allowed."
      true_json = { :status => "okay", :string => @string} 
      render(json: JSON.pretty_generate(true_json))
      UserMailer.additional_request_for_undecided_location(@user, @gym_name, @user_email, @string, @number_of_requests_for_gym, 
        @decidedlocations_id, @number_of_requests_by_user ).deliver     
    
    elsif @decidedlocations.decision == 1 
       @geo_lat = @decidedlocations.geo_lat
       @geo_long = @decidedlocations.geo_long
       @decision = @decidedlocations.decision

       @checklocation = Checklocation.new(params[:checklocation])
       @checklocation.save
       @checklocation.requester_id = @user.id

       @user.number_of_requests += 1
      @user.save
      

       @number_of_requests = @user.number_of_requests

      @string = "location black listed. Sorry."
      false_json = { :status => "fail.", :string => @string} 
      render(json: JSON.pretty_generate(false_json))
      UserMailer.decided_location_mailer(@user, @geo_lat, @geo_long, @gym_name, @user_email, @string, @decision, @number_of_requests ).deliver
       
    elsif @decidedlocations.decision == 0 
      @geo_lat = @decidedlocations.geo_lat
       @geo_long = @decidedlocations.geo_long
       @decision = @decidedlocations.decision

       @checklocation = Checklocation.new(params[:checklocation])
       @checklocation.save
       @checklocation.requester_id = @user.id
       @checklocation.number_of_requests += 1

       @user.number_of_requests += 1
       @user.save

       @number_of_requests = @user.number_of_requests

      @string = "location good to go."
      true_json = { :status => "okay", :string => @string} 
      render(json: JSON.pretty_generate(true_json))
      UserMailer.decided_location_mailer(@user, @geo_lat, @geo_long, @gym_name, @user_email, @string, @decision, @number_of_requests ).deliver 

   
    end
    
  end
end
