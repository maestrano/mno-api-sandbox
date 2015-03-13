class Api::Openid::UsersController < Api::Openid::BaseController
  before_filter :detect_xrds, only: :show

  def show
    @user = User.find_by_uid(params[:id])
    
    unless @user
      render json: "Not found", status: :not_found
      return
    end

    respond_to do |format|
      format.html do
        response.headers['X-XRDS-Location'] = openid_identifier(@user, format: :xrds)
        render text: openid_identifier(@user, format: :xrds)
      end
      format.xrds
    end
    
  end
  
  #====================================================================
  # Protected
  #====================================================================
  protected
    def detect_xrds
      if params[:id] =~ /\A(.+)\.xrds\z/
        request.format = :xrds
        params[:id] = $1
      end
    end
end
