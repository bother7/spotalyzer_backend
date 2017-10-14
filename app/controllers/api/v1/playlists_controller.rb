class Api::V1::PlaylistsController < ApplicationController
  before_action :find_user_via_jwt, only: [:recent, :create]




  def recent
    array = @user.my_playlists
    if array
    render json: array
    else
    render json: {status: error, code: 400}
    end
  end




  def create
    byebug
  end







end
