class DecidedlocationsController < ApplicationController
  # GET /decidedlocations
  # GET /decidedlocations.json
  def index
    @decidedlocations = Decidedlocation.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @decidedlocations }
    end
  end

  # GET /decidedlocations/1
  # GET /decidedlocations/1.json
  def show
    @decidedlocation = Decidedlocation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @decidedlocation }
    end
  end

  # GET /decidedlocations/new
  # GET /decidedlocations/new.json
  def new
    @decidedlocation = Decidedlocation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @decidedlocation }
    end
  end

  # GET /decidedlocations/1/edit
  def edit
    @decidedlocation = Decidedlocation.find(params[:id])
  end

  # POST /decidedlocations
  # POST /decidedlocations.json
  def create
    @decidedlocation = Decidedlocation.new(params[:decidedlocation])

    respond_to do |format|
      if @decidedlocation.save
        format.html { redirect_to @decidedlocation, notice: 'Decidedlocation was successfully created.' }
        format.json { render json: @decidedlocation, status: :created, location: @decidedlocation }
      else
        format.html { render action: "new" }
        format.json { render json: @decidedlocation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /decidedlocations/1
  # PUT /decidedlocations/1.json
  def update
    @decidedlocation = Decidedlocation.find(params[:id])

    respond_to do |format|
      if @decidedlocation.update_attributes(params[:decidedlocation])
        format.html { redirect_to @decidedlocation, notice: 'Decidedlocation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @decidedlocation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /decidedlocations/1
  # DELETE /decidedlocations/1.json
  def destroy
    @decidedlocation = Decidedlocation.find(params[:id])
    @decidedlocation.destroy

    respond_to do |format|
      format.html { redirect_to decidedlocations_url }
      format.json { head :no_content }
    end
  end
end
