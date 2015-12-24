class User < ActiveRecord::Base
  attr_accessor :remember_token
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                                    format: { with: VALID_EMAIL_REGEX },
                                    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }, allow_nil: true
  has_secure_password
  
  # Returns the hash digest of a given string
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  
  # Returns a random token
  def self.new_token
    SecureRandom.urlsafe_base64
  end
  
  # Remembers a user in the database for use in persistent sessions
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # Forget a user by setting the remember_digest to nil
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  # Returns true if the given token matches the digest
  def authenticated?(token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest) == token
  end
end