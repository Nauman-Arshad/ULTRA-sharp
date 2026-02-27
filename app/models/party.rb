class Party < ApplicationRecord
  has_many :orders, dependent: :destroy
  has_many :payments, dependent: :destroy

  validates :party_name, presence: true
  validates :phone, uniqueness: true, allow_blank: true

  before_validation :ensure_default_status

  # Positive = amount due (party owes us). Negative = advance/credit.
  def balance
    account_balance
  end

  private

  def ensure_default_status
    self.status = "active" if status.blank?
  end
end