class User < ApplicationRecord
  has_many :user_songs
  has_many :songs, through: :user_songs
  has_many :user_playlists
  has_many :playlists, through: :user_playlists
  has_secure_password

# sorta useless, not as good as initial main spotify auth or reauthorize
  def authorize
    @client_id, @client_secret = ENV['CLIENT_ID'], ENV['CLIENT_SECRET']
    request_body = { grant_type: 'client_credentials' }
    response = RestClient.post('https://accounts.spotify.com/api/token', request_body, auth_header)
    self.access_token = JSON.parse(response)['access_token']
    self.save
  end

  def auth_header
    authorization = Base64.strict_encode64 "#{@client_id}:#{@client_secret}"
    { 'Authorization' => "Basic #{authorization}", :content_type => 'application/x-www-form-urlencoded' }
  end

  def reauthorize
    @client_id, @client_secret = ENV['CLIENT_ID'], ENV['CLIENT_SECRET']
    request_body = { grant_type: 'refresh_token', refresh_token: "#{self.refresh_token}" }
    response = RestClient.post('https://accounts.spotify.com/api/token', request_body, auth_header)
    self.access_token = JSON.parse(response)['access_token']
    self.save
  end

  def mainspotifyauth (code)
    @client_id, @client_secret = ENV['CLIENT_ID'], ENV['CLIENT_SECRET']
    request_body = {grant_type: 'authorization_code', code: code, redirect_uri: 'http://localhost:3000/callback'}
    response = RestClient.post('https://accounts.spotify.com/api/token', request_body, auth_header)
    resp = JSON.parse(response)
    self.access_token = resp['access_token']
    self.refresh_token = resp['refresh_token']
    self.save
  end

  def updated_token
    self.reauthorize if ((Time.now - self.updated_at) > 3600)
    self.access_token
  end


  def recent_plays
    authorization_header = { 'Authorization' => "Bearer #{updated_token}" }
    response = RestClient.get("https://api.spotify.com/v1/me/player/recently-played", authorization_header)
    new_resp = JSON.parse(response)
    array = new_resp["items"].map do |song|
      {title: song["track"]["name"], uri: song["track"]["uri"], artist: song["track"]["artists"][0]["name"] }
    end
  end


end
