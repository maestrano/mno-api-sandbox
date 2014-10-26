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
      WITH_PARAMS_MAPPING.each do |str_op,math_op|
        real_param = param.dup
        if real_param.gsub!(str_op,'')
          if whitelist.include?(real_param) && cols.include?(real_param)
            sql_chain.push("#{tbl}.#{real_param} #{math_op} ?")
            sql_values.push(value)
          end
          break
        end
      end
      
      if whitelist.include?(param) && cols.include?(param)
        sql_chain.push("#{tbl}.#{param} = ?")
        sql_values.push(value)
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