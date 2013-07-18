class AwsPicturesController < ApplicationController
  # GET /aws_pictures
  # GET /aws_pictures.json
  def index
    @aws_pictures = AwsPicture.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @aws_pictures }
    end
  end

  # GET /aws_pictures/1
  # GET /aws_pictures/1.json
  def show
    @aws_picture = AwsPicture.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @aws_picture }
    end
  end

  # GET /aws_pictures/new
  # GET /aws_pictures/new.json
  def new
    @aws_picture = AwsPicture.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @aws_picture }
    end
  end

  # GET /aws_pictures/1/edit
  def edit
    @aws_picture = AwsPicture.find(params[:id])
  end

  # POST /aws_pictures
  # POST /aws_pictures.json
  def create
    @aws_picture = AwsPicture.new(params[:aws_picture])

    respond_to do |format|
      if @aws_picture.save
        format.html { redirect_to @aws_picture, notice: 'Aws picture was successfully created.' }
        format.json { render json: @aws_picture, status: :created, location: @aws_picture }
      else
        format.html { render action: "new" }
        format.json { render json: @aws_picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /aws_pictures/1
  # PUT /aws_pictures/1.json
  def update
    @aws_picture = AwsPicture.find(params[:id])

    respond_to do |format|
      if @aws_picture.update_attributes(params[:aws_picture])
        format.html { redirect_to @aws_picture, notice: 'Aws picture was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @aws_picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /aws_pictures/1
  # DELETE /aws_pictures/1.json
  def destroy
    @aws_picture = AwsPicture.find(params[:id])
    @aws_picture.destroy

    respond_to do |format|
      format.html { redirect_to aws_pictures_url }
      format.json { head :no_content }
    end
  end
end
