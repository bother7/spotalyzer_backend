class Api::V1::SongsController < ApplicationController

  def search
    @search = params[:search]
    @user = User.find_by(id: params[:user_id])
    filter = params[:searchFilter]
    auth_header = { 'Authorization' => "Bearer #{@user.updated_token}" }
    response = RestClient.get("https://api.spotify.com/v1/search?q=#{@search}&type=#{filter}", auth_header)
    new_resp = JSON.parse(response)
    array = new_resp["#{filter}s"]["items"].map do |song|
      {title: song["name"]}
    end
    byebug
    render json: array
  end















end
