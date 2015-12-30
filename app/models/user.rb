class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships #, source: :follower
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :downcase_email
  before_create :create_activation_digest
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
  def authenticated?(attribute, token)
    digest = self.send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest) == token
  end
  
  # Activate user upon confirmation
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
    #update_attribute(:activated,    true)
    #update_attribute(:activated_at, Time.zone.now)
  end
  
  # Send activation email :)
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
  
  # Sets attributes for password reset
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token),
                   reset_sent_at: Time.zone.now)
    #update_attribute(:reset_digest, User.digest(reset_token))
    #update_attribute(:reset_sent_at, Time.zone.now)
  end
  
  # Send password reset email
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end
  
  # Returns true if a password reset has expired
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end
  
  # Define Proto-feed method
  def feed
    Micropost.where("user_id = ?", id)
  end
  
  # Follow a user
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end
  
  # Unfollow a user
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end
  
  # True if the other_user is following user
  def following?(other_user)
    following.include?(other_user)
  end
  
  # Methods used inside the class only  
  private
    
    # Returns email downcase 
    def downcase_email
      self.email.downcase!
    end
    
    # Creates activation token and digest for a new user
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end   
end