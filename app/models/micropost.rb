class Micropost < ActiveRecord::Base
  belongs_to :user
  default_scope -> { order('created_at DESC')}
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate :picture_size
  
  private
    
    # Makes sure the picture size is less than 5Mb
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5 Mb")
      end
    end
end