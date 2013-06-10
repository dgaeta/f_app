class PasswordResetsController < ApplicationController
  skip_before_filter :require_login

require 'bcrypt'
class PasswordResetsController < ApplicationController
include BCrypt

    
  # request password reset.
  # you get here when the user entered his email in the reset password form and submitted it.
  def create 
    @user = User.find_by_email(params[:email])
        
    # This line sends an email to the user with instructions on how to reset their password (a url with a random token)
    @user.deliver_reset_password_instructions! if @user
        
    # Tell the user instructions have been sent whether or not email was found.
    # This is to not leak information to attackers about which emails exist in the system.
    redirect_to(root_path, :notice => 'Instructions have been sent to your email.')
    @user = User.where(:email => params[:email].downcase).first
        
    if @user == nil 
        false_json = { :status => "fail."} 
        render(json: JSON.pretty_generate(false_json) )
    else    
    # This line sends an email to the user with instructions on how to reset their password (a url with a random token)
    @user.deliver_reset_password_instructions! 
        
    # Tell the user instructions have been sent whether or not email was found.
    # This is to not leak information to attackers about which emails exist in the system.

    
        true_json =  { :status => "okay"}
        render(json: JSON.pretty_generate(true_json))
        
      end
  end
    
  # This is the reset password form.
  def edit
    @user = User.load_from_reset_password_token(params[:id])
    @token = params[:id]
    not_authenticated unless @user
  end
      
  # This action fires when the user has sent the reset password form.
  def update
    @token = params[:token]
    @user = User.load_from_reset_password_token(params[:token])
    not_authenticated unless @user
    # the next line makes the password confirmation validation work
    @user.password_confirmation = params[:user][:password_confirmation]
    # the next line clears the temporary token and updates the password
    if @user.change_password!(params[:user][:password])
      redirect_to(root_path, :notice => 'Password was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def change_password 
    @user = User.where(:id => params[:user_id]).first
    @email = @user.email
    @session = Session.new
    user = login( @email , params[:old_password], params[:remember_me])
    @new_password = params[:password]
    @new_password_confirmation = params[:password_confirmation]
   
  
    if user
      then 
       if @new_password == @new_password_confirmation
        then 
         @user.deliver_reset_password_instructions!
          @user.change_password!([@user.id][:password])
          @user.save
          true_json =  { :status => "okay"  }
          render(json: JSON.pretty_generate(true_json))
        else 
          @string = "passwords dont match"
          false_json = { :status => "fail.", :string => @string} 
          render(json: JSON.pretty_generate(false_json))
        end
      else 
          @string = "wrong user password"
          false_json = { :status => "fail.", :string => @string} 
          render(json: JSON.pretty_generate(false_json))
    end
  end

  def change_email 
    @user = User.where(:id => params[:user_id]).first
    @game_member = GameMember.where(:user_id => params[:user_id])

    if @user 
      then 
      @user.email = params[:new_email].downcase
      @user.save 
       unless @game_member[0] == nil 
           # UPDATE USER'S EMAIL ON STRIPE TOO:
          Stripe.api_key = @stripe_api_key
          unless @user.customer_id.nil?
            cu = Stripe::Customer.retrieve(@user.customer_id) 
            cu.email = @user.email
            cu.save
          end
          # END
        end

      true_json =  { :status => "okay"  }
      render(json: JSON.pretty_generate(true_json))
    else
       false_json = { :status => "fail."} 
          render(json: JSON.pretty_generate(false_json))
    end
  end

  def change_pw_request 
    @user = User.where(:email => params[:email]).first 
    
    if @user 
      then 
      true_json =  { :status => "okay"  }
      render(json: JSON.pretty_generate(true_json))
      @email = @user.email
      @first_name = @user.first_name
      @token = rand.to_s[2..7] #=> 7 digit long random number
      @token = @token.to_i
      @user.token = @token
      @user.save
      Notifier.change_pw_request(@first_name, @email, @token)
    else 
       false_json = { :status => "fail."} 
       render(json: JSON.pretty_generate(false_json))
    end 
  end 

  def update_password 
    @user = User.where(:email => params[:email]).first 
    @token = params[:token]
  
    if @user then 
      if @user.token == @token 
      then 
       @new_password = params[:new_password]
       @new_password_confirmation = params[:new_password_confirmation]
        if @new_password == @new_password_confirmation
        then 
          @user.change_password!(params[:user][:new_password])
          @user.save
          true_json =  { :status => "okay"  }
          render(json: JSON.pretty_generate(true_json))
        else 
          @string = "passwords dont match"
          false_json = { :status => "fail.", :string => @string} 
          render(json: JSON.pretty_generate(false_json))
        end 
      else 
        @string = "token does not match"
          false_json = { :status => "fail.", :string => @string} 
          render(json: JSON.pretty_generate(false_json))
      end
    else 
        @string = "email not found"
          false_json = { :status => "fail.", :string => @string} 
          render(json: JSON.pretty_generate(false_json))
    end 
  end

  def update_email 
    user = User.where(:id => params[:user_id]).first

    old_email = user.email 
    user.email = params[:new_email].downcase
    user.save

    if user.save 
      then 
      gb = Gibbon.new
      gb.list_unsubscribe(:id => "3c9272b951", :email_address => old_email, :delete_member => true, 
      :send_goodbye => false, :send_notify => false)
      gb.list_subscribe(:id => "3c9272b951", :email_address => user.email, :merge_vars => {'fname' => user.first_name, 
      'lname' => user.last_name }, :email_type => "html",  :double_optin => false, :send_welcome => false)
      #gb.listUpdateMember(:id => list_id, :email_address => old_email,:merge_vars => [:email_address => user.email])
      # UPDATE USER'S EMAIL ON STRIPE TOO:
      Stripe.api_key = @stripe_api_key
      unless user.customer_id.nil?
       cu = Stripe::Customer.retrieve(user.customer_id) 
        cu.email = user.email
        cu.save
      end
      # END
       true_json =  { :status => "okay"  }
        render(json: JSON.pretty_generate(true_json))
    else
         false_json = { :status => "fail."} 
        render(json: JSON.pretty_generate(false_json))
    end
  end
  end

end