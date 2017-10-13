class ApplicationController < ActionController::API

  def encode_token(payload)
    token = JWT.encode(payload, "taco")
  end

  def auth_header
    header = request.headers['Authorization']
  end

  def decoded_token
    if auth_header
      token = auth_header.split(" ")[1]
      begin
        JWT.decode(token, "taco", true, {algorithm: 'HS256'})
      rescue JWT::DecodeError
        [{}]
      end
    else
    end
  end

  def find_user_via_jwt
    @user = User.find_by(id: decoded_token[0]["user_id"]) if decoded_token[0]["user_id"]
  end

end
