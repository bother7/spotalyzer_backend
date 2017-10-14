class Api::V1::PlaylistsController < ApplicationController
  before_action :find_user_via_jwt, only: [:recent, :create]




  def recent
    array = @user.my_playlists
    if array == "0 Playlists"
      render json: {error: "No User Playlists Exist", status: 422}
    elsif array.size > 0
      @playlists = array
      render json: @playlists
    else
      render json: {status: 400}
    end
  end




  def create
    byebug
  end







end
