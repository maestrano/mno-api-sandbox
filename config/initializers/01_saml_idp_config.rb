x509_cert_path = "#{Rails.root}/vendor/idp-certs/rsacert.pem"
cert_priv_key_path = "#{Rails.root}/vendor/idp-certs/rsaprivkey.pem"

# Check existence of certificate and private key
# If found then load them in SamlIdp (use default otherwise)
if File.file?(x509_cert_path) && File.file?(cert_priv_key_path)
  SamlIdp.config.x509_certificate = File.read(x509_cert_path).gsub("-----BEGIN CERTIFICATE-----","").gsub("-----END CERTIFICATE-----","").strip
  SamlIdp.config.secret_key = File.read(cert_priv_key_path)
end
