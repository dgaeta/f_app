  class SessionsController < ApplicationController


   # GET /sessions
  # GET /sessions.json
  def index
    @sessions = Session.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sessions }
    end
  end

  # GET /sessions/1
  # GET /sessions/1.json
  def show
    @session = Session.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @session }
    end
  end

  # GET /sessions/new
  # GET /sessions/new.json
  def new
    @session = Session.new

    respond_to do |format|
      format.html # new.html.erb
      true_json =  { :status => "okay", :first_name => first_name, :last_name => last_name, :email => email}
      format.json { render json: JSON.pretty_generate(true_json) }
    end
  end

  # GET /sessions/1/edit
  def edit
    @session = Session.find(params[:id])
  end

  # POST /sessions
  # POST /sessions.json
  def create
  
    user = login(params[:email], params[:password], params[:remember])
   

    respond_to do |format|
      if user
        first_name = user.first_name
        last_name = user.last_name
        email = user.email
        true_json =  { :status => "okay", :first_name => first_name, :last_name => last_name, :email => email}
        redirect_back_or_to root_url, :notice => "Logged in!"
        #format.html {  'login successful' }
        format.json { render json: JSON.pretty_generate(true_json) }
      else
        flash.now.alert = "Email or password was invalid"
        false_json = { :status => "fail.", :errors => @session.errors } 
        #format.html { render action: "new" }
        format.json { render json: JSON.pretty_generate(false_json) }

      end
    end
  end

  # PUT /sessions/1
  # PUT /sessions/1.json
  def update
    @session = Session.find(params[:id])

    respond_to do |format|
      if @session.update_attributes(params[:session])
        format.html { redirect_to @session, notice: 'Session was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @session.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sessions/1
  # DELETE /sessions/1.json
  def destroy
    @session = Session.find(params[:id])
    @session.destroy
    

    respond_to do |format|
      true_json =  { :status => "okay"}
        redirect_back_or_to root_url, :notice => "Logged out!"
        format.html {  'logout successful' }
        format.json { render json: JSON.pretty_generate(true_json) }
    end
  end
end
