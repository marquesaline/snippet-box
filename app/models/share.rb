class Share < ApplicationRecord
  has_many_attached :files
  attr_accessor :has_files, :expiry_option

  EXPIRY_OPTIONS = {
    "1h"  => 1.hour,
    "1d"  => 1.day,
    "7d"  => 7.days,
    "30d" => 30.days,
    "never" => nil
  }.freeze

  before_validation :generate_edit_token
  before_validation :generate_slug_if_blank
  before_validation :set_expires_at, on: :create

  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9\-]+\z/, message: "only allows lowercase letters, numbers and hyphens" }
  validates :edit_token, presence: true, uniqueness: true
  validate :must_have_content_or_files
  validate :maximum_files_attached
  validate :acceptable_file_size

  def to_param
    slug
  end

  def detected_languages
    return [] if content.blank?
    content.scan(/```(\w+)/).flatten.map(&:downcase).uniq.reject(&:blank?)
  end

  def expiry_label
    return "Never expires" if expires_at.nil?
    "Expires #{expires_at.strftime("%b %d, %Y")}"
  end

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
      random_slug = SecureRandom.hex(3)
      break self.slug = random_slug unless Share.exists?(slug: random_slug)
    end
  end

  def set_expires_at
    duration = EXPIRY_OPTIONS.fetch(expiry_option || "30d", 30.days)
    self.expires_at = duration ? duration.from_now : nil
  end

  def maximum_files_attached
    return unless files.attached? && files.count > 5
    errors.add(:files, "can't exceed 5 files")
  end

  def acceptable_file_size
    return unless files.attached?

    files.each do |file|
      if file.byte_size > 5.megabytes
        errors.add(:files, "#{file.filename} is too large (max 5MB)")
      end
    end
  end
end
