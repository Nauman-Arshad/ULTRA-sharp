class Party < ApplicationRecord
  has_many :orders, dependent: :destroy
  has_many :payments, dependent: :destroy

  validates :party_name, presence: true

  # Positive = amount due (party owes us). Negative = advance/credit.
  def balance
    account_balance
  end
end