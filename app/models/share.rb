class Share < ApplicationRecord
  has_many_attached :files
  attr_accessor :has_files

  before_validation :generate_edit_token
  before_validation :generate_slug_if_blank
  before_validation :set_expires_at, on: :create

  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9\-]+\z/, message: "only allows lowercase letters, numbers and hyphens" }
  validates :edit_token, presence: true, uniqueness: true
  validate :must_have_content_or_files

  private

  def must_have_content_or_files
    if content.blank? && !has_files
      errors.add(:base, "Must have either content or files")
    end
  end

  def generate_edit_token
    return if edit_token.present?
    self.edit_token = SecureRandom.uuid
  end

  def generate_slug_if_blank
    return if slug.present?
    
    loop do
      random_slug = SecureRandom.urlsafe_base64(4).downcase
      break self.slug = random_slug unless Share.exists?(slug: random_slug)
    end
  end

  def set_expires_at
    self.expires_at = 30.days.from_now
  end
end
