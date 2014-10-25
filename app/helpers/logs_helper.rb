module LogsHelper
  
  def parse_log_line(line)
    line.gsub("\n","<br/>").gsub(/\[\d+m/,'').gsub(/\s/,"&nbsp;&nbsp;")
  end
end