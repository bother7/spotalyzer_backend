class Api::V1::SongsController < ApplicationController

  def search
    @search = params[:term]
    # User.find(session[:user_id])
    auth_header = { 'Authorization' => "Bearer #{User.first.access_token}" }
    response = RestClient.get("https://api.spotify.com/v1/search?q=#{@search}&type=track", auth_header)
    new_resp = JSON.parse(response)
    array = new_resp["tracks"]["items"].map do |song|
      {title: song["name"]}
    end
    render json: array
  end















end
