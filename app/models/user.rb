class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :parties, dependent: :destroy
  has_many :products, dependent: :destroy

  ROLES = %w[superadmin admin].freeze

  normalizes :email_address, with: ->(e) { e&.strip&.downcase }
  normalizes :username, with: ->(u) { u&.strip&.downcase }

  validates :username, presence: true, uniqueness: true
  validate :roles_must_be_allowed

  before_validation :normalize_roles

  def superadmin?
    roles.include?("superadmin")
  end

  def admin?
    roles.include?("admin")
  end

  scope :superadmins, -> { where("? = ANY(roles)", "superadmin") }

  private

  def normalize_roles
    self.roles = Array(roles).reject(&:blank?).uniq
  end

  def roles_must_be_allowed
    return if roles.blank?
    invalid = roles.reject { |r| ROLES.include?(r) }
    errors.add(:roles, "contains invalid role(s): #{invalid.uniq.join(", ")}") if invalid.any?
  end
end
