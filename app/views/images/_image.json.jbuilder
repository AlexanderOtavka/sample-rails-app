json.extract! image, :id, :title, :url, :created_at, :updated_at
json.url image_url(image, format: :json)
