class LogsController < ApplicationController
  include LogsHelper
  
  before_filter do
    @section = 'logs'
  end
  
  # GET /logs
  def index
    @logs = []
    if File.exist?("log/#{Rails.env}.log")
      content = File.read("log/#{Rails.env}.log").encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
    
      content.split(/\n{2,}/).each do |line|
        next unless line =~ /\/api/i
      
        @logs.unshift(line)
      end
      @logs = @logs[0..100]
    end
  end
end
