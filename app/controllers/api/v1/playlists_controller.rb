class Api::V1::PlaylistsController < ApplicationController
  before_action :find_user_via_jwt, only: [:recent, :create, :destroy, :show, :my_playlists, :playlist_tracks]

  def recent
    array = my_playlists
    if array == "0 Playlists"
      render json: {status: 418, message: "No User Playlists Exist"}
    elsif array.size > 0
      @playlists = array
      render json: @playlists.where({display: true})
    else
      render json: {status: 400}
    end
  end

  def show
    @playlist = Playlist.find_by({id: params[:id]})
    playlist_tracks
  end


  def create
    @playlist = Playlist.new({name: params[:name]})
    @user.playlists << @playlist
    authorization_header = { 'Authorization' => "Bearer #{@user.updated_token}", 'Content-Type' => 'application/json' }
    request_body = {name: @playlist.name}.to_json
    response = RestClient.post("https://api.spotify.com/v1/me/playlists", request_body, authorization_header)
    new_resp = JSON.parse(response)
    if response
      @playlist.uri = new_resp["uri"]
      @playlist.save
      render json: @playlist
    else
      render json: {status: 418, message: "uh oh spaghettios"}
    end
  end

  def destroy
    @playlist = Playlist.find_or_create_by({id: params[:id]})
    @playlist.display = false
    @playlist.save
    @playlists = @user.playlists
    render json: @playlists.where({display: true})
  end

  def patch

  end

private

  def my_playlists
    authorization_header = { 'Authorization' => "Bearer #{@user.updated_token}" }
    response = RestClient.get("https://api.spotify.com/v1/me/playlists", authorization_header)
    new_resp = JSON.parse(response)
    if new_resp["items"].size == 0
      "0 Playlists"
    else
      arr = new_resp["items"].map do |playlist|
        @playlist = Playlist.find_or_create_by({uri: playlist["uri"], name: playlist["name"], tracks_url: playlist["tracks"]["href"]})
        if !@user.playlists.include?(@playlist)
          @user.playlists << @playlist
        end
      end
      @user.save
      @user.playlists
    end
  end

  def playlist_tracks
    authorization_header = { 'Authorization' => "Bearer #{@user.updated_token}" }
    url = @playlist.tracks_url || "https://api.spotify.com/v1/users/#{@user.spotify_id}/playlists/#{@playlist.spotify_id}/tracks"
    response = RestClient.get("#{url}", authorization_header)
    new_resp = JSON.parse(response)
      if new_resp["items"].length != 0
        @playlist.songs = []
        new_resp["items"].map do |song|
          @artist = Artist.find_or_create_by(name: song["track"]["artists"][0]["name"])
          song = Song.find_or_create_by({title: song["track"]["name"], uri: song["track"]["uri"], artist: @artist})
          @playlist.songs << song
        end
        render json: @playlist.songs
      else
        render json: {status: 418, message: "no songs"}
      end
  end


end
