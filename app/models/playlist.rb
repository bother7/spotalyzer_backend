class Playlist < ApplicationRecord
  has_many :song_playlists
  has_many :songs, through: :song_playlists
  has_many :user_playlists
  has_many :users, through: :user_playlists



  def spotify_id
    self.uri.split(":playlist:")[1]
  end


end
