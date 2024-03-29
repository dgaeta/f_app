class User < ActiveRecord::Base
  authenticates_with_sorcery!
  
  has_many :friendships
  has_many :friends, :through => :friendships
  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many :inverse_friends, :through => :inverse_friendships, :source => :user
  has_many :games, :class_name => "Game", :foreign_key => "creator_id", :dependent => :destroy 
  has_many :game_members,  :dependent => :destroy
  has_many :comments, :class_name => "Comment", :foreign_key => "from_user_id",:dependent => :destroy
  has_many :stats, :class_name => "Stat", :foreign_key => "winners_id",:dependent => :destroy 
  has_many :profile_pictures
  has_many :notifications, as: :notifiable
  
  attr_accessible :email, :first_name, :last_name, :password, :password_confirmation, :customer_id, :in_game, :twitter_username,
    :first_payment_date, :s3_profile_pic_name 

  #validates :password_confirmation, :presence => :true
  validates :password, :presence => :true, :length => { :minimum => 6 }, :on => :create, :confirmation => :true
  validates :email, :presence => :true, :uniqueness => true, :length => { :minimum => 6}, :format => {:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i}
  validates_presence_of :first_name
  validates_presence_of :last_name
 


   def self.terms(terms)
    return if terms.blank?
    composed_scope = scoped
    terms.split(' ').map { |term| "%#{term}%" }.each do |term|
      composed_scope = composed_scope.where('first_name ILIKE :term OR last_name ILIKE :term OR email ILIKE :term', { :term => term })
    end

    composed_scope
  end

  def self.get_full_name(n)
    user = User.find(n)

    full_name = user.first_name + " " + user.last_name
    return full_name
  end

  def self.deliver_profile_picture(user_id)
    @user = User.where(:id => user_id).first 
    s3 = AWS::S3.new
    bucket_for_prof_pics = s3.buckets['profilepics.fitsby.com']

    if @user.nil?
      status = "no user found"
      return status
    end 


    if @user.contains_profile_picture  
      status = "exists" 
      pic_url = (bucket_for_prof_pics.objects[@user.s3_profile_pic_name].url_for(:read, :expires => 10*60)) 
      array = Hash.new(:status => status, :pic_url => pic_url)
      return array
    else 
      return status = "does not exist"
    end   
  end
  
end