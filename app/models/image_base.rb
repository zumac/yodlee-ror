class ImageBase
  class FilelessIO < StringIO
    attr_accessor :original_filename
  end

  def decode_and_set_picture(encoded_pic)
    decoded = FilelessIO.new(Base64.decode64(encoded_pic))
    decoded.original_filename = "Temp_#{Time.now}.jpg"
    self.image = decoded
  end


  def to_map
    map = super
    map[:url] = self.image.url
    map[:url_m] = self.image.m.url
    map[:url_s] = self.image.s.url
    map
  end
  private

  def update_image_attributes
    if image.present?
      width, height = `identify -format "%wx%h" #{image.file.path}`.split(/x/)
      self.aspect_ratio = width.to_i/ height.to_i
      self.height = height
    end
  end

end
