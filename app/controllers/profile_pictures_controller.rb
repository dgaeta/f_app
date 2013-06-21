class ProfilePicturesController < ApplicationController
  # GET /profile_pictures
  # GET /profile_pictures.json
  def index
    @profile_pictures = ProfilePicture.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @profile_pictures }
    end
  end

  # GET /profile_pictures/1
  # GET /profile_pictures/1.json
  def show
    @profile_picture = ProfilePicture.find(params[:id])
    @commentable = @profile_picture
    @comments = @commentable.comments
    @comment = Comment.new

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @profile_picture }
    end
  end

  # GET /profile_pictures/new
  # GET /profile_pictures/new.json
  def new
    @profile_picture = ProfilePicture.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @profile_picture }
    end
  end

  # GET /profile_pictures/1/edit
  def edit
    @profile_picture = ProfilePicture.find(params[:id])
  end

  # POST /profile_pictures
  # POST /profile_pictures.json
  def create
    @profile_picture = ProfilePicture.new(params[:profile_picture])
    @profile_picture.user_id = current_user.id

    respond_to do |format|
      if @profile_picture.save
        format.html { redirect_to @profile_picture, notice: 'Profile picture was successfully created.' }
        format.json { render json: @profile_picture, status: :created, location: @profile_picture }
      else
        format.html { render action: "new" }
        format.json { render json: @profile_picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /profile_pictures/1
  # PUT /profile_pictures/1.json
  def update
    @profile_picture = ProfilePicture.find(params[:id])

    respond_to do |format|
      if @profile_picture.update_attributes(params[:profile_picture])
        format.html { redirect_to @profile_picture, notice: 'Profile picture was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @profile_picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /profile_pictures/1
  # DELETE /profile_pictures/1.json
  def destroy
    @profile_picture = ProfilePicture.find(params[:id])
    @profile_picture.destroy

    respond_to do |format|
      format.html { redirect_to profile_pictures_url }
      format.json { head :no_content }
    end
  end
end
