class MetadataController < ApplicationController
  before_filter :prepare_scope
  
  # GET /metadata
  def index
    @meta_url = (session[:metadata_url] || "http://example.com/maestrano/metadata")
    @app_id = session[:metadata_app_id]
    @api_key = session[:metadata_api_key]
  end
  
  # POST /metadata
  def create
    @apps = App.all
    
    @app_id = params[:app_id]
    @api_key = params[:api_key]
    @meta_url = params[:meta_url]
    
    if @api_key.blank? && params[:app]
      app = App.find_by_uid(params[:app])
      @app_id = app.uid
      @api_key = app.api_token if app
    end
    
    fetch_metadata(@app_id,@api_key,@meta_url)
    session[:metadata_url] = @meta_url unless @meta_url.blank?
    session[:metadata_app_id] = @app_id unless @app_id.blank?
    session[:metadata_api_key] = @api_key unless @api_key.blank?
    
    render 'index'
  end
  
  private
    def prepare_scope
      @apps = App.all
      @metadata = {}
      @errors = {}
    end
  
    def fetch_metadata(app_id,app_token,meta_url = nil)
      return nil if meta_url.blank?
      
      # Assign opts and fetch response
      opts = {basic_auth: {username: app_id, password: app_token}}
      resp = HTTParty.get(meta_url,opts)

      if resp.success?
        begin
          @raw_metadata = resp.body
          @metadata = JSON.parse(resp.body)
        rescue Exception => e
          logger.error e
          @errors[:description] = "Could not parse metadata json response"
          @errors[:details] = ["Response body: #{resp.body}"]
          return nil
        end
      else
        @errors[:description] = "Metadata could not be fetched"
        @errors[:details] = []
        @errors[:details] << "Response code: #{resp.code}"
        @errors[:details] << "Response body: #{resp.body}"
      end

      return nil
    end
end