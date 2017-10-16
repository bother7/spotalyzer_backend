class AddUriToPlaylists < ActiveRecord::Migration[5.1]
  def change
    add_column :playlists, :uri, :string
  end
end
