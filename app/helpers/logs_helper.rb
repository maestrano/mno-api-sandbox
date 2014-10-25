module LogsHelper
  
  def parse_log_line(line)
    line
      .gsub(/^\s*CACHE\s+\(.*\n/,"")
      .gsub(/^.*SELECT\s+.*\n/,"")
      .gsub(/^\s*SQL\s+\(.*\n/,"")
      .gsub("\n","<br/>")
      .gsub(/\[\d+m/,'')
      .gsub(/^(\s)+/,"&nbsp;&nbsp;nbsp;nbsp;nbsp;nbsp;")
      .gsub(/(Started\s+\w+)/,"<span class='text-warning'><b>\\1</b></span>")
      .gsub("ERROR:","<br/><span class='text-error'><b>ERROR:&nbsp;</b></span>")
      .gsub("INSPECT:","<br/><span class='text-info'><b>INSPECT:&nbsp;</b></span>")
      .gsub(/(Completed\s+20\d\s+OK)/,"<br/><span class='text-success'><b>\\1</b></span>")
      .gsub(/(Completed\s+40\d\s+\w+)/,"<br/><span class='text-error'><b>\\1</b></span>")
      
  end
end