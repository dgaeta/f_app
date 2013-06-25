class UsersController < ApplicationController
#skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
before_filter :require_login, :only => :index
require 'json'
#require 'gibbon'

  # GET /users
  # GET /users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show 
    @user = User.find(params[:id])
    @commentable = @user
    @comments = @commentable.comments
    @comment = Comment.new
    @friendships = @user
    @comments = @friendships.friendships
    @comment = Comment.new

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.json { render json: @user }
      format.html # new.html.erb
      
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])
    @user.save
    @user.email = @user.email.downcase
    @user.email = @user.email.downcase
    today = Time.now.to_date
    @user.signup_day = today.day.to_i
    @user.signup_month = today.month.to_i
    @user.signup_year = today.year.to_i


    stat = Stat.new(:winners_id => @user.id )
    stat.save

    respond_to do |format|
      if @user.save
        auto_login(@user)
        true_json =  { :status => "okay" ,  :id => @user.id,  :first_name => @user.first_name, :last_name => @user.last_name, 
          :email => @user.email }
        Notifier.delay.welcome_email(@user)
        format.json { render json: JSON.pretty_generate(true_json) }
        format.html { redirect_to root_url, notice: 'User was successfully created.' }  
      else
        false_json = { :status => "fail.", :errors => @user.errors } 
        format.json { render json: JSON.pretty_generate(false_json) }
        format.html { render action: "new" }
      end
    end
  end


  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    session[:current_user_id] = nil
    gb = Gibbon.new
    #list_id = gb.lists({:list_name => "Fitsby Users"})["data"].first["id"]
    gb.list_unsubscribe(:id => "3c9272b951", :email_address => @user.email, :delete_member => true, 
      :send_goodbye => false, :send_notify => false)

    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :no_content }
    end
  end

  def deploy_receive      
    @user = User.new(params[:fault])
    if @user.save
        render json: @user
    else
        @user = "error"
        render json: @user
    end
  end



  def get_and_save_stripe_info
    Stripe.api_key = @stripe_api_key   # this is our stripe test secret key (found on website)

    @user = User.where(:id => params[:user_id]).first

    # get the credit card details submitted by Android
    credit_card_number = params[:credit_card_number]
    credit_card_exp_month = params[:credit_card_exp_month]
    credit_card_exp_year = params[:credit_card_exp_year]
    credit_card_cvc = params[:credit_card_cvc]
    
    # create a Customer
    @customer = Stripe::Customer.create(
      :card => [:number => credit_card_number, :exp_month => credit_card_exp_month, :exp_year => credit_card_exp_year, :cvc => credit_card_cvc],
      :email => @user.email ) 
    @user.update_attributes(:customer_id => @customer.id)

    # Now, make a stripe column for database table 'users'
    # save the customer ID in your database so you can use it later

    if @user.save
      then 
       true_json =  { :status => "okay"  }
        render(json: JSON.pretty_generate(true_json))
      else
         false_json = { :status => "fail."} 
        render(json: JSON.pretty_generate(false_json))
    end
  end


  def change_email 
    @user = User.where(:id => params[:user_id]).first
    false_json = { :status => "fail."} 
    render(json: JSON.pretty_generate(false_json)) if @user.empty?

    old_email = @user.email 
    @user.email = params[:new_email]
    @user.save  
    
    # UPDATE USER'S EMAIL ON STRIPE TOO:
    Stripe.api_key = @stripe_api_key
    unless @user.customer_id.nil?
      cu = Stripe::Customer.retrieve(@user.customer_id) 
      cu.email = @user.email
      cu.save
    end
      
    true_json =  { :status => "okay"  }
    render(json: JSON.pretty_generate(true_json))  
  end
 
  def append_text_field 
    @user = User.where(:id => params[:user_id]).first 

    if @user 
      then 
      @user.num_of_texts_sent += 1 
      @user.save 
      true_json =  { :status => "okay"  }
      render(json: JSON.pretty_generate(true_json))
      else 
      false_json = { :status => "fail."} 
      render(json: JSON.pretty_generate(false_json))
    end 
  end 

  def push_registration 
    @user = User.where(:id => params[:user_id]).first
    registration_id = params[:registration_id] 

    if registration_id != nil
=begin  if params[:device_type] == "iPhone"
      @user.device_type = "iPhone"
      @user.iphone_device_token = registration_id
      @user.save
      true_json =  { :status => "okay"  }
      render(json: JSON.pretty_generate(true_json))
    elsif params[:device_type] == "Android"
=end  @user.device_type = "Android"
      @user.gcm_registration_id =  registration_id
      @user.save 
      true_json =  { :status => "okay"  }
      render(json: JSON.pretty_generate(true_json))
    else
     false_json = { :status => "fail."} 
     render(json: JSON.pretty_generate(false_json))
    end 
  end

  def push_disable
    @user = User.where(:id => params[:user_id]).first

    if @user 
      then 
      @user.enable_notifications = "FALSE"
      @user.save
      true_json =  { :status => "okay"  }
      render(json: JSON.pretty_generate(true_json))
      else 
      false_json = { :status => "fail."} #######ASK BRENT IF WE WANT RENDER FALSE FOR THIS 
      render(json: JSON.pretty_generate(false_json))
    end 
  end 

  def push_enable
    @user = User.where(:id => params[:user_id]).first

    if @user 
      then 
      @user.enable_notifications = "TRUE"
      @user.save
      true_json =  { :status => "okay"  }
      render(json: JSON.pretty_generate(true_json))
      else 
      false_json = { :status => "fail."} #######ASK BRENT IF WE WANT RENDER FALSE FOR THIS 
      render(json: JSON.pretty_generate(false_json))
    end 
  end  

  def upload_profile_picture
   #######################

      true_json =  { :status => "okay"  }
      render(json: JSON.pretty_generate(true_json))
   
   end

   def user_deletion
    @user = User.where(:id => params[:user_id]).first

    unless @user.requested_deletion
      sess = Session.new
      sess.user_id = @user.id
      date = Time.now.to_date
      sess.request_month = date.month
      sess.request_day = date.day
      sess.request_year = date.year
      sess.save
      Notifier.user_deletion(@user_id)
      true_json =  { :status => "okay"  }
      render(json: JSON.pretty_generate(true_json))
    else
      error_string = "Request has been sent"
      false_json = { :status => "fail.", :error => error_string} 
      render(json: JSON.pretty_generate(false_json))
    end
  end


  def createUser
    @user = User.new
    @user.first_name = params[:first_name]
    @user.last_name = params[:last_name]
    @user.email = params[:email]
    @user.password = params[:password]
    @user.email = @user.email.downcase
    @user.save

    stat = Stat.new(:winners_id => @user.id )
    stat.save

    respond_to do |format|
      if @user.save
        @user.email = @user.email.downcase
        today = Time.now.to_date
        @user.signup_day = today.day.to_i
        @user.signup_month = today.month.to_i
        @user.signup_year = today.year.to_i
        @user.save

        auto_login(@user)
        true_json =  { :status => "okay" ,  :id => @user.id,  :first_name => @user.first_name, :last_name => @user.last_name, 
          :email => @user.email }
        Notifier.welcome_email(@user)
        format.json { render json: JSON.pretty_generate(true_json) }
        format.html { redirect_to root_url, notice: 'User was successfully created.' }  
      else
        false_json = { :status => "fail.", :errors => @user.errors } 
        format.json { render json: JSON.pretty_generate(false_json) }
        format.html { render action: "new" }
      end
    end
  end


  def checkUserDeviceRegistration
    user = User.where(:id => params[:user_id]).first

    if user
      unless user.device_registered
        user.gcm_registration_id = params[:android_id]
        user.save
      end
        true_json =  { :status => "okay"  }
        render(json: JSON.pretty_generate(true_json))
    else
      false_json = { :status => "fail."} 
      render(json: JSON.pretty_generate(false_json))
    end
  end
  
end




