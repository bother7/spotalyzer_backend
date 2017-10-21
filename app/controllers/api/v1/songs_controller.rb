class Api::V1::SongsController < ApplicationController
  before_action :find_user_via_jwt, only: [:search, :recent, :show]

  def search
    @search = params[:search]
    filter = params[:searchFilter]
    authorization_header = { 'Authorization' => "Bearer #{@user.updated_token}" }
    response = RestClient.get("https://api.spotify.com/v1/search?q=#{@search}&type=#{filter}&limit=50", authorization_header)
    new_resp = JSON.parse(response)
    mapTrack(filter, new_resp)
  end

  def recent
    @playlist = @user.playlists.where(name: "InternalRecentPlaylist")[0]
    if ((Time.now - @playlist.updated_at) < 600 && @playlist.songs.length > 0)
      render json: @playlist.songs
    else
      @songs = @user.recent_plays(@playlist)
      render json: @songs
    end
  end


  def show
    song = Song.find_by(id: params[:id])
    song.analysis(@user)
    render json: song.data
  end


  private

  def mapTrack (filter, new_resp)
    if filter == "track"
      @songs = new_resp["#{filter}s"]["items"].map do |song|
        artist = Artist.find_or_create_by(name: song["artists"][0]["name"])
        Song.find_or_create_by({title: song["name"], spotify_id: song["id"], artist: artist})
      end
      render json: @songs
    elsif filter == "playlist"
      @playlists = new_resp["#{filter}s"]["items"].map do |playlist|
        Playlist.find_or_create_by({name: playlist["name"], uri: playlist["uri"], tracks_url: playlist["tracks"]["href"]})
      end
      render json: @playlists
    end

  end





end
