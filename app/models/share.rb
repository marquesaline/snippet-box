class Share < ApplicationRecord
  has_many_attached :files

  before_validation :generate_edit_token

  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9\-]+\z/, message: "only allows lowercase letters, numbers and hyphens" }
  validates :edit_token, presence: true, uniqueness: true
  validate :must_have_content_or_files

  private

  def must_have_content_or_files
    if content.blank? && !files.attached?
      errors.add(:base, "Must have either content or files")
    end
  end

  def generate_edit_token
    self.edit_token = SecureRandom.uuid
  end
end