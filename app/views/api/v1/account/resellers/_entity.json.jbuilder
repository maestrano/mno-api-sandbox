if entity
  json.object 'account_reseller'
  json.id entity.uid
  json.created_at entity.created_at
  json.updated_at entity.updated_at
  json.name entity.name
  json.code entity.code
  json.country entity.country
end
