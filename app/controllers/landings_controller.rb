class LandingsController < ApplicationController
  # GET /landings
  # GET /landings.json
  def index
    @landings = Landing.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @landings }
    end
  end

  # GET /landings/1
  # GET /landings/1.json
  def show
    @landing = Landing.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @landing }
    end
  end

  # GET /landings/new
  # GET /landings/new.json
  def new
    @landing = Landing.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @landing }
    end
  end

  # GET /landings/1/edit
  def edit
    @landing = Landing.find(params[:id])
  end

  # POST /landings
  # POST /landings.json
  def create
    @landing = Landing.new(params[:landing])

    respond_to do |format|
      if @landing.save
        format.html { redirect_to @landing, notice: 'Landing was successfully created.' }
        format.json { render json: @landing, status: :created, location: @landing }
      else
        format.html { render action: "new" }
        format.json { render json: @landing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /landings/1
  # PUT /landings/1.json
  def update
    @landing = Landing.find(params[:id])

    respond_to do |format|
      if @landing.update_attributes(params[:landing])
        format.html { redirect_to @landing, notice: 'Landing was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @landing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /landings/1
  # DELETE /landings/1.json
  def destroy
    @landing = Landing.find(params[:id])
    @landing.destroy

    respond_to do |format|
      format.html { redirect_to landings_url }
      format.json { head :no_content }
    end
  end
end
