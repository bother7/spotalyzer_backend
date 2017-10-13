class Api::V1::SongsController < ApplicationController
  before_action :find_user_via_jwt, only: [:search, :recent]

  def search
    @search = params[:search]
    filter = params[:searchFilter]
    authorization_header = { 'Authorization' => "Bearer #{@user.updated_token}" }
    response = RestClient.get("https://api.spotify.com/v1/search?q=#{@search}&type=#{filter}", authorization_header)
    new_resp = JSON.parse(response)
    array = new_resp["#{filter}s"]["items"].map do |song|
      {title: song["name"], uri: song["uri"], artist: song["artists"][0]["name"] }
    end
    render json: array
  end


  def recent
    array = @user.recent_plays
    render json: array
  end















end
