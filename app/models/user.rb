class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :parties, dependent: :destroy
  has_many :products, dependent: :destroy

  ROLES = %w[superadmin admin].freeze

  normalizes :email_address, with: ->(e) { e&.strip&.downcase }
  normalizes :username, with: ->(u) { u&.strip&.downcase }

  validates :username, presence: true, uniqueness: true
  validates :role, inclusion: { in: ROLES }

  def superadmin?
    role == "superadmin"
  end

  def admin?
    role == "admin"
  end

  scope :superadmins, -> { where(role: "superadmin") }
end
