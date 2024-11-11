class JwtService
  # SECRET_KEY = Rails.application.credentials.secret_key_base
  SECRET_KEY = "oHDRpKZLkmqnwlgNvhifyWmMGGeYYRziaX4DIdZlIdjpYKeAJoEkSnnSffHcjXDChR8N0SjCxL8fPc8hlFH5Zf8aWcUwPnokIFyDWUBCzcM5kt6KPOa0ytbj95To6ZUh"

  def self.encode(payload)
    payload[:exp] = 1.day.from_now.to_i
    JWT.encode(payload, SECRET_KEY)
  rescue => e
    Rails.logger.error("JWT Encode Error: #{e.message}")
    nil
  end

  def self.decode(token)
    JWT.decode(token, SECRET_KEY)[0]
  rescue JWT::DecodeError => e
    Rails.logger.error("JWT Decode Error: #{e.message}")
    nil
  end
end
