class User < ApplicationRecord
  has_many :user_songs
  has_many :songs, through: :user_songs
  has_many :user_playlists
  has_many :playlists, through: :user_playlists
  has_secure_password


  def authorize
    @client_id, @client_secret = ENV['CLIENT_ID'], ENV['CLIENT_SECRET']
    request_body = { grant_type: 'client_credentials' }
    response = RestClient.post('https://accounts.spotify.com/api/token', request_body, auth_header)
    @client_token = JSON.parse(response)['access_token']
    self.access_token = @client_token
    self.save
  end

  def auth_header
    authorization = Base64.strict_encode64 "#{@client_id}:#{@client_secret}"
    { 'Authorization' => "Basic #{authorization}" }
  end

  def reauthorize
  end

end
