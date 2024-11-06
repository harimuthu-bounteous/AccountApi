class UserService
  include CustomErrors

  def self.register_user(user_params)
    user = User.new(user_params)
    if user.save
      token = JwtService.encode({ user_id: user.id })
      { user: user, token: token }
    else
      raise ActiveRecord::RecordInvalid.new(user)
    end
  end

  def self.register_admin(user_params)
    user = User.new(user_params.merge(role: "admin"))
    if user.save
      token = JwtService.encode({ user_id: user.id })
      { user: user, token: token }
    else
      raise ActiveRecord::RecordInvalid.new(user)
    end
  end

  def self.login(email, password)
    user = User.find_by(email: email)
    if user&.authenticate(password)
      token = JwtService.encode({ user_id: user.id })
      {
        user: {
          id: user.id,
          username: user.username,
          email: user.email,
          role: user.role
        },
        token: token
      }
    else
      raise InvalidCredentialsError, "Invalid email or password"
    end
  end
end
