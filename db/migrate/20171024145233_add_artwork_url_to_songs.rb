class AddArtworkUrlToSongs < ActiveRecord::Migration[5.1]
  def change
    add_column :songs, :artwork_url, :string
  end
end
