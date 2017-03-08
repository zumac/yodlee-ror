class UserImage < ImageBase
  include Mongoid::Document
  include Mongoid::Timestamps
  before_save :update_image_attributes
  embedded_in :user

  mount_uploader :image, UserImageUploader
  field :ar, as: :aspect_ratio, type: Float
  field :hi, as: :height, type: Float

end
