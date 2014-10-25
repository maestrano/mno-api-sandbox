class LogsController < ApplicationController
  include LogsHelper
  
  before_filter do
    @section = 'logs'
  end
  
  # GET /logs
  def index
    @logs = []
    file = Rails.env.production? ? "tmp/#{Rails.env}.log" : "log/#{Rails.env}.log"
    if File.exist?(file)
      content = File.read(file).encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
      
      content.split(/(?=Started|Served|Connecting.*$)/).each do |line|
        next unless line =~ /\/api/i
        line.gsub!(/\n+$/,'')
        @logs.unshift(line)
      end
      @logs = @logs[0..100]
    end
  end
end
