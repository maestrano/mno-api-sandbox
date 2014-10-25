class LogsController < ApplicationController
  include LogsHelper
  
  # GET /logs
  def index
    @logs = []
    content = File.read("log/#{Rails.env}.log").encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
    
    puts
    
    content.split(/\n{2,}/).each do |line|
      next unless line =~ /\/api/i
      
      @logs.unshift(line)
    end
    @logs = @logs[0..100]
  end
end
