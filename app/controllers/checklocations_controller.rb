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
    @decidedlocations = Decidedlocation.where(:gym_name => params[:gym_name].downcase)
    @user = User.find(params[:user_id])
    @user_email = @user.email
    @gym_name = params[:gym_name]

   if  @decidedlocations[0] == nil 
    then  
    @checklocation = Checklocation.new
    @checklocation = Checklocation.new(params[:checklocation])


    @checklocation.requester_id = params[:user_id]
    @checklocation.number_of_requests += 1
    @checklocation.save

    @string = "checking location"
     true_json =  { :status => "okay", :string => @string }
          render(json: JSON.pretty_generate(true_json))
        #UserMailer.check_location_mailer(@user, @checklocation.geo_lat, @checklocation.geo_long, @gym_name
      #, @user_email, @string ).deliver
    
    elsif @decidedlocations.decision == 1  
      @string = "location black listed"
      false_json = { :status => "fail.", :string => @string} 
      render(json: JSON.pretty_generate(false_json))
      #UserMailer.decided_location_mailer(@user, @decidedlocations.geo_lat, @checklocation.geo_long, @gym_name
      #, @user_email, @string, @decidedlocations.decision ).deliver
       
    elsif @decidedlocations.decision == 0 
    
     @string = "location good to go"
      true_json = { :status => "okay", :string => @string} 
      render(json: JSON.pretty_generate(true_json))
      #UserMailer.decided_location_mailer(@user, @decidedlocations.geo_lat, @checklocation.geo_long, @gym_name
      #, @user_email, @string, @decidedlocations.decision ).deliver 
    end
    
  end
end
