require 'jwt'

class JwtService
  ALGO = 'RS256'.freeze
  ACCESS_EXP = 15.minutes
  REFRESH_EXP = 30.days

  def self.private_key
    #@private_key ||= OpenSSL::PKey::RSA.new(ENV.fetch('JWT_PRIVATE_KEY'))
    @private_key ||= begin
      path = Rails.root.join('jwt_private.pem')
      OpenSSL::PKey::RSA.new(File.read(path))
    end
  end

  def self.public_key
    #@public_key ||= OpenSSL::PKey::RSA.new(ENV.fetch('JWT_PUBLIC_KEY'))
    @public_key ||= begin
      path = Rails.root.join('jwt_public.pem')
      OpenSSL::PKey::RSA.new(File.read(path))
    end
  end

  def self.issue_access_token(user, extra = {})
    now = Time.now.to_i
    payload = {
      iss: "your-auth-service",
      sub: user.id.to_s,
      iat: now,
      exp: (now + ACCESS_EXP.to_i),
      role: user.role,
      name: user.name || user.email
    }.merge(extra)

    token = JWT.encode(payload, private_key, ALGO)
    { token: token, exp: payload[:exp] }
  end

  # verify returns decoded payload or raises
  def self.decode_access_token(token)
    decoded, _ = JWT.decode(token, public_key, true, { algorithm: ALGO })
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError => e
    raise e
  end
end