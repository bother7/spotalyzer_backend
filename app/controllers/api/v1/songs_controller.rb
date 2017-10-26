class Api::V1::SongsController < ApplicationController
  before_action :find_user_via_jwt

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
    if ((Time.now - @playlist.updated_at) < 300 && @playlist.songs.length > 0 && @user.playlists.length > 3)
      localSongs = @playlist.songs.order(updated_at: :desc)
      render json: localSongs
    else
      @songs = @user.recent_plays(@playlist)
      if @songs
        render json: @songs
      else
        render json: {status: "error"}
      end
    end
  end

  def recommendation
    @playlist = @user.playlists.where(name: "InternalRecommendedPlaylist")[0]
    playlist = @user.playlists.where(name: "InternalRecentPlaylist")[0]
    if playlist.songs.length == 0
      render json: {status: "error"}
    else
      if ((Time.now - @playlist.updated_at) < 180 && @playlist.songs.length > 0)
        render json: @playlist.songs
      else
        if playlist.songs.length > 5
          seeds = playlist.songs.order(updated_at: :desc).limit(5)
        else
          seeds = playlist.songs.order(updated_at: :desc)
        end
        seeds = seeds.map {|song| song.spotify_id}
        authorization_header = { 'Authorization' => "Bearer #{@user.updated_token}" }
        response = RestClient.get("https://api.spotify.com/v1/recommendations?seed_tracks=#{seeds.join(',')}&market=US&limit=10", authorization_header)
        new_resp = JSON.parse(response)
        @songs = new_resp["tracks"].map do |song|
          artist = Artist.find_or_create_by(name: song["artists"][0]["name"])
          newSong = Song.find_or_create_by({title: song["name"], spotify_id: song["id"], artist: artist})
          album = song["album"]["images"].find {|album| album["height"] == 64}
          if album && album["url"]
            newSong.artwork_url = album["url"]
          else
            newSong.artwork_url = nil
          end
          newSong.save
          newSong
        end
        @playlist.songs = []
        @playlist.songs = @songs
        render json: @songs
      end
    end
  end

  def show
    song = Song.find_by(id: params[:id])
    song.analysis(@user)
    render json: {data:song.data, uri:song.uri}
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
