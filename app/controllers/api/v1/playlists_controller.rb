class Api::V1::PlaylistsController < ApplicationController
  before_action :find_user_via_jwt, except: []

  def update
    @playlist = Playlist.find_or_create_by({id: params[:id]})
    playlist_array = params[:song_array].map do |song|
      Song.find(song["id"])
    end
    if @playlist.songs.all? { |i| playlist_array.include?(i) } && @playlist.songs.length == playlist_array.length
      update_playlist(playlist_array)
    else
      add_song = playlist_array - @playlist.songs
      remove_song = @playlist.songs - playlist_array
      if add_song.length > 0
        add_song_to_playlist(add_song)
      elsif remove_song.length > 0
        remove_song_from_playlist(remove_song)
      else
      end
    end
  end

  def recent
    if ((Time.now - @user.updated_at < 300) && (@user.playlists.length > 3))
      render json: @user.playlists.where({display: true})
    else
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
  end

  def show
    @playlist = Playlist.find_by({id: params[:id]})
    playlist_tracks
  end

  def showsaved
    @playlist = @user.playlists.where(name: "InternalSavedPlaylist")[0]
    render json: @playlist.songs
  end

  def editsaved
    @playlist = @user.playlists.where(name: "InternalSavedPlaylist")[0]
    tracks = params[:song_array].map do |object|
      song = Song.find_by(id: object["id"])
    end
    @playlist.songs = tracks
    if @playlist.save
      render json: {status: "success"}
    else
      render json: {status: "error"}
    end
  end


  def create
    @playlist = Playlist.new({name: params[:name]})
    @user.playlists << @playlist
    authorization_header = { 'Authorization' => "Bearer #{@user.updated_token}", 'Content-Type' => 'application/json' }
    request_body = {name: @playlist.name}.to_json
    response = RestClient.post("https://api.spotify.com/v1/users/#{@user.spotify_id}/playlists", request_body, authorization_header)
    new_resp = JSON.parse(response)
    if response
      @playlist.uri = new_resp["uri"]
      @playlist.tracks_url = new_resp["tracks"]["href"]
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
          artist = Artist.find_or_create_by(name: song["track"]["artists"][0]["name"])
          thisSong = Song.find_or_create_by({title: song["track"]["name"], spotify_id: song["track"]["id"], artist: artist})
          @playlist.songs << thisSong
        end
        @user.playlists << @playlist if !@user.playlists.include?(@playlist)
        render json: @playlist.songs
      else
        render json: {status: 418, message: "no songs"}
      end
  end

  def update_playlist(playlist_array)
    authorization_header = { 'Authorization' => "Bearer #{@user.updated_token}", 'Content-Type' => 'application/json' }
    if @playlist.tracks_url.include?(@user.spotify_id)
      url = "https://api.spotify.com/v1/users/#{@user.spotify_id}/playlists/#{@playlist.spotify_id}/tracks"
      playlist_uri_array = playlist_array.map {|playlist| playlist.uri}
      request_body = {uris: playlist_uri_array}.to_json
      response = RestClient.put("#{url}", request_body, authorization_header)
      new_resp = JSON.parse(response)
        if new_resp["snapshot_id"]
          @playlist.songs = playlist_array
          render json: {snapshot_id: new_resp["snapshot_id"]}
        else
          render json: {status: 418}
        end
    else
      render json: {status: 412, message: "cannot edit this playlist"}
    end
  end

  def remove_song_from_playlist(song_array)
    authorization_header = { 'Authorization' => "Bearer #{@user.updated_token}",  'Content-Type' => 'application/json'}
    if @playlist.tracks_url.include?(@user.spotify_id)
      url = "https://api.spotify.com/v1/users/#{@user.spotify_id}/playlists/#{@playlist.spotify_id}/tracks"
      playlist_uri_array = song_array.map {|playlist| {"uri": playlist.uri, "position": [@playlist.songs.find_index(playlist)]}}
      request_body = {tracks: playlist_uri_array}.to_json
      response = RestClient::Request.execute(method: :delete, url: "#{url}", payload: request_body, headers: authorization_header)
      new_resp = JSON.parse(response)
        if new_resp["snapshot_id"]
          @playlist.songs = @playlist.songs - song_array
          render json: {snapshot_id: new_resp["snapshot_id"]}
        else
          render json: {status: 418}
        end
    else
      render json: {status: 412, message: "cannot edit this playlist"}
    end
  end

  def add_song_to_playlist(song_array)
    authorization_header = { 'Authorization' => "Bearer #{@user.updated_token}",'Content-Type' => 'application/json' }
    if @playlist.tracks_url.include?(@user.spotify_id)
      url = "https://api.spotify.com/v1/users/#{@user.spotify_id}/playlists/#{@playlist.spotify_id}/tracks"
      playlist_uri_array = song_array.map {|playlist| playlist.uri}
      request_body = {uris: playlist_uri_array}.to_json
      response = RestClient.post("#{url}", request_body, authorization_header)
      new_resp = JSON.parse(response)
        if new_resp["snapshot_id"]
          @playlist.songs = [*@playlist.songs, *song_array]
          render json: {snapshot_id: new_resp["snapshot_id"]}
        else
          render json: {status: 418}
        end
    else
      render json: {status: 412, message: "cannot edit this playlist"}
    end
  end

end
