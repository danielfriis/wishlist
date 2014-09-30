module SessionsHelper

  include Analyzable

  def sign_in(user)
    cookies.permanent[:remember_token_new] = user.remember_token
    if user.fb_auth
      cookies[:remember_token_new] = { value: user.remember_token, expires: user.fb_auth.oauth_expires_at }
    end
    self.current_user = user
    tracker.track(user.id, 'Sign in')
    tracker.increment(user.id, {'Logins' => 1})
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= User.find_by_remember_token(cookies[:remember_token_new])
  end

  def current_user?(user)
    user == current_user
  end

  def signed_in_user
    if !signed_in?
      store_location
      redirect_to signin_url, notice: "Please sign in."
    end
  end

  def deauthorized?
    if session[:deauthorized] == "true"
      return true
    end
  end

  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token_new)
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url
  end

end
