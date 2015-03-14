module ApplicationHelper
  
  def current_user
    @current_user ||= begin
      session[:current_user] = (params[:user_uid] || session[:current_user])
      User.find_by_uid(session[:current_user])
    end
  end

  def user_signed_in?
    !!current_user
  end
  
end
