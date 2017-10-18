class Song < ApplicationRecord
  has_many :user_songs
  has_many :users, through: :user_songs
  belongs_to :artist
  has_many :song_playlists
  has_many :playlists, through: :song_playlists
  has_many :song_genres
  has_many :genres, through: :song_genres

  def uri
    "spotify:track:#{self.spotify_id}"
  end


  def self.play
    s = Spotilocal::Client.new port: 4382
    byebug
  end

end
