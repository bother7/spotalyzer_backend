class Api::V1::SongsController < ApplicationController
  before_action :find_user_via_jwt, only: [:search, :recent]

  def search
    @search = params[:search]
    filter = params[:searchFilter]
    authorization_header = { 'Authorization' => "Bearer #{@user.updated_token}" }
    response = RestClient.get("https://api.spotify.com/v1/search?q=#{@search}&type=#{filter}", authorization_header)
    new_resp = JSON.parse(response)
    # only works for track right now, need to add artist and playlist
    mapTrack(filter, new_resp)
    render json: @songs
  end


  def recent
    @songs = @user.recent_plays
    render json: @songs
  end



  private

  def mapTrack (filter, new_resp)
    if filter == "track"
      @songs = new_resp["#{filter}s"]["items"].map do |song|
        @artist = Artist.find_or_create_by(name: song["artists"][0]["name"])
        Song.find_or_create_by({title: song["name"], uri: song["uri"], artist: @artist})
      end
    end
  end









end
