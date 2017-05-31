module SignInHelper
  def sign_in_as(user)
    post login_path(email: user.account.email, password: user.account.password)
  end
end
