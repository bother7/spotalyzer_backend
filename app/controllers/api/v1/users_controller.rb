class Api::V1::UsersController < ApplicationController
  before_action :find_user_via_jwt, only: [:persist, :isAuthorized?, :spotifyauth]

  def show
    
  end

  def isAuthorized?
    if @user.access_token && @user.refresh_token
      render json: {status: "success"}
    else
      render json: {status: "error"}
    end
  end

  def create
    @user = User.new(name: params[:name],username: params[:username], password: params[:password])
    if @user.save
      playlist = Playlist.create({name: "InternalSavedPlaylist", display: false})
      playlist1 = Playlist.create({name: "InternalRecentPlaylist", display: false})
      playlist2 = Playlist.create({name: "InternalRecommendedPlaylist", display: false})
      @user.playlists << playlist
      @user.playlists << playlist1
      @user.playlists << playlist2
      token = encode_token({user_id: @user.id})
      @user.jwt_token = token
      @user.save
      render json: @user
    end
  end

  def login
   @user = User.find_by(username: params[:username])
   if @user && @user.authenticate(params[:password])
     token = encode_token({user_id: @user.id})
     @user.jwt_token = token
     @user.save
     render json: @user
   else
     render json: {status: error, code: 401}
   end
 end

 def persist
   if @user
     render json: @user
   else
     render json: {status: error}
   end
 end

 def spotifyauth
   code = params[:code]
   if @user && @user.mainspotifyauth(code)
     render json: @user
   else
     render json: {status: error, code: 402}
   end
 end



end
