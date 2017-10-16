class AddDisplayToPlaylists < ActiveRecord::Migration[5.1]
  def change
    add_column :playlists, :display, :boolean, default: true
  end
end
