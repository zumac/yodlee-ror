class UserImageUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url
    ActionController::Base.helpers.asset_path('default/default_user.jpg')
  end

  version :m do
    process :resize_to_fit => [600, 10000]
  end

  version :s, :from_version => :m do
    process :resize_to_fit => [300, 10000]
    process :quality => 80
  end

end
