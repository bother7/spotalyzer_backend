class AddTracksUrlToPlaylists < ActiveRecord::Migration[5.1]
  def change
    add_column :playlists, :tracks_url, :string
  end
end
