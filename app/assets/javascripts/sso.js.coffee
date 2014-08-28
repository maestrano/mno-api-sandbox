# SSO Page 
jQuery ->
  
  # Copy master sso endpoint to forms
  $("#sso_init_endpoint_master").keyup(->
    $("input[name=sso_init_endpoint]").val($(this).val());
  )