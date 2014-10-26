# ActiveRecord extension
module WithParamFilters
  
  # Mapping of tail commands => operator
  WITH_PARAMS_MAPPING = {
    '_before' => '<=',
    '_strictly_before' => '<',
    '_after' => '>=',
    '_strictly_after' => '>',
    '_greater_than' => '>=',
    '_strictly_greater_than' => '>',
    '_lower_than' => '<=',
    '_strictly_lower_than' => '<'
  }
  
  # Apply params filter on an active record relation
  # Automatically convert *__before, *__after
  # *__greater_than, *__lower_than keywords placed after
  # params to comparison operator
  #
  # Calling with_param_filter(created_at__after: Time.now)
  # is equivalent to where("created_at > ?", Time.now)
  #
  # Useful for autofiltering results from url parameters
  #
  # Take in argument a hash of params and an optional whitelist 
  # of allowed attributes
  #
  # If one of the attributes is absent from the whitelist or
  # the list of columns then an empty resultset is returned
  #
  def with_param_filters(params = {}, whitelist = nil)
    return where(nil) unless params.any?
    
    # Populate whitelist
    params = params.stringify_keys
    tbl = self.klass.table_name
    cols = self.klass.column_names
    whitelist = self.klass.column_names unless whitelist
    
    # Go through each param and get the real
    # operator. Keep if an actual column and part
    # of the whitelist
    sql_chain = []
    sql_values = []
    params.each do |param,value|
      # Skip param if hash
      next if value.kind_of?(Hash)
      
      real_param = param.dup
      real_str_op = "="
      
      # Sort to get longest string first
      WITH_PARAMS_MAPPING.keys.sort { |a,b| b.length <=> a.length }.each do |str_op|
        if real_param.gsub!(str_op,'')
          real_str_op = WITH_PARAMS_MAPPING[str_op]
          break
        end
      end
      
      if whitelist.include?(real_param) && cols.include?(real_param)
        sql_chain.push("#{tbl}.#{real_param} #{real_str_op} ?")
        
        real_value = value
        # Automatically parse iso8601 dates
        if real_value =~ /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/
          real_value = Time.iso8601(value).utc
        end
        
        sql_values.push(real_value)
      else
        return where("1 = 2")
      end
    end
    
    if sql_chain.any?
      return where(sql_chain.join(" AND "), *sql_values)
    else
      return where(nil)
    end
  end
end

ActiveRecord::Relation.send(:include, WithParamFilters)