class Song < ApplicationRecord
  has_many :user_songs
  has_many :users, through: :user_songs
  belongs_to :artist
  has_many :song_playlists
  has_many :playlists, through: :song_playlists
  has_many :song_genres
  has_many :genres, through: :song_genres

  def uri
    if self.spotify_id
      "spotify:track:#{self.spotify_id}"
    else
      "song unavailable"
    end
  end

  def analysis(user)
    if !self.data
      authorization_header = { 'Authorization' => "Bearer #{user.updated_token}" }
      response = RestClient.get("https://api.spotify.com/v1/audio-analysis/#{self.spotify_id}", authorization_header)
      new_resp = JSON.parse(response)
      self.data = new_resp["segments"]
      self.save
    end
  end


  def self.play
    s = Spotilocal::Client.new port: 4382
    byebug
  end

end
