class SongSerializer < ActiveModel::Serializer
  attributes :id, :title, :artist, :uri


  def artist
    object.artist.name
  end

end
