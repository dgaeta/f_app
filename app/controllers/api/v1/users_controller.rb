module Api
  module V1
    class UsersController < ApplicationController
     
      respond_to :json

      def index
        @users = User.all
      end

      def show
        respond_with User.find(params[:id])
      end

      def create
        respond_with User.create(params[:product])
      end

      def update
        respond_with User.update(params[:id], params[:product])
      end

      def destroy
        respond_with User.destroy(params[:id])
      end
    end
  end
end