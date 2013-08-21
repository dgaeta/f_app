class RemarksController < ApplicationController
  before_filter :load_remarkable
  
  def index
    @remarks = @remarkable.remarks
  end

  def new
    @remark = @remarkable.remarks.new
  end

  def create
    @remark = @remarkable.remarks.new(params[:remark])
    if @remark.save
      redirect_to @remarkable, notice: "remark created."
    else
      render :new
    end
  end

private

  def load_remarkable
    resource, id = request.path.split('/')[1, 2]
    @remarkable = resource.singularize.classify.constantize.find(id)
  end

  # alternative option:
  # def load_commentable
  #   klass = [Article, Photo, Event].detect { |c| params["#{c.name.underscore}_id"] }
  #   @commentable = klass.find(params["#{klass.name.underscore}_id"])
  # end
end