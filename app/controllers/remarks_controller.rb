class RemarksController < ApplicationController
  #before_filter :load_remarkable
  
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

  def create_remark
	  	remark  = Remark.create_remark_for_client(params[:content], params[:message], params[:from_user_id], params[:comment_id])

	  	if remark 
		  	success_json = { :status => "created"} 
	        render(json: JSON.pretty_generate(success_json) )
   	    else 
	    	failed_json = { :status => "failure"} 
	        render(json: JSON.pretty_generate(failed_json) )
	   end
  end

  def get_remarks

      comment = Comment.where(:id => params[:comment_id]).first
      remarks = comment.remarks
      remarks = remarks.map do |remark|
      {:remark_id => remark.id, 
      :content => remark.content,
      :message => remark.message, 
      :from_user_id => remark.from_user_id,
      :from_user_fullname => User.get_full_name(remark.from_user_id),
      :commentable_id => remark.remarkable_id
      #:profile_picture_status_hash => User.deliver_profile_picture(remark.from_user_id)
       }
    end

      if comment 
        success_json = { :status => "okay", :remarks => remarks} 
          render(json: JSON.pretty_generate(success_json) )
        else 
        failed_json = { :status => "failure"} 
          render(json: JSON.pretty_generate(failed_json) )
     end
  end

  def delete
    @remark = Remark.where(:id => params[:remark]).first

    if @remark
      @remark.delete
      success_json = { :status => "okay"} 
      render(json: JSON.pretty_generate(success_json) )
    else
      failed_json = { :status => "failure"} 
      render(json: JSON.pretty_generate(failed_json) )
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