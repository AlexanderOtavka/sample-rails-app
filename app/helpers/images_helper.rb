module ImagesHelper
  def image_width(_image)
    300
  end

  def image_height(image)
    1.0 / image.aspect_ratio * image_width(image)
  end
end
