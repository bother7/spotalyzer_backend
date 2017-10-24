class SongSerializer < ActiveModel::Serializer
  attributes :id, :title, :artist, :uri, :artwork_url


  def artist
    object.artist.name
  end

end
