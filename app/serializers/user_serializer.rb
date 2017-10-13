class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :name, :jwt_token
end
