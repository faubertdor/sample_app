module SessionsHelper
  
  # Logs in the given user
  def log_in(user)
    session[:user_id] = user.id
  end
  
  # Remembers a user in a persistent session
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end
  
  # Returns the user corresponding to the cookies
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if (user && user.authenticated?(:remember, cookies[:remember_token]))
        log_in(user)
        @current_user = user
      end
    end
  end
  
  # Returns true if a user is logged in otherwise false
  def logged_in?
    !current_user.nil?
  end
  
  # Forget a user session with cookies (persistent)
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
  
  # Ends the user session
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
  
  # Returns true if user is the current_user
  def current_user?(user)
    user == current_user
  end
  
  # Stores the url that the user is trying to access
  def store_location
    session[:forwarding_url] = request.url if request.get?
  end
  
  # Redirects to the stored url or default
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end
end