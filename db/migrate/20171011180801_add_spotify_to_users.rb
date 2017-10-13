class AddSpotifyToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :access_token, :string
    add_column :users, :refresh_token, :string
    add_column :users, :jwt_token, :string
  end
end
