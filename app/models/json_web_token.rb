class JsonWebToken
  def self.encode(payload, duration = nil)
    duration ||= Rails.application.secrets.jwt_expiration_hours

    payload = payload.dup
    payload['exp'] = duration.to_f.hours.from_now.to_i

    JWT.encode(payload, Rails.application.secrets.secret_key_base)
  end

  def self.decode(token)
    JWT.decode(token, Rails.application.secrets.secret_key_base).first
  end
end