include Warden::Test::Helpers

module SignInHelpers
  def sign_in(user)
    login_as user, scope: :user
  end

  def sign_out
    logout(:user)
  end
end

RSpec.configure do |config|
  config.include SignInHelpers
end
