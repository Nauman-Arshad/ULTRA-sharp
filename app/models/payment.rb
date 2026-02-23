class Payment < ApplicationRecord
  belongs_to :party
  belongs_to :order, optional: true

  validates :amount, numericality: { greater_than: 0 }, presence: true
  validates :payment_date, presence: true

  after_create :decrease_party_balance
  after_update :adjust_party_balance_after_update
  after_destroy :increase_party_balance

  private

  def decrease_party_balance
    party.decrement!(:account_balance, amount)
  end

  def adjust_party_balance_after_update
    return unless saved_change_to_amount?
    old_amount = amount_before_last_save
    party.increment!(:account_balance, old_amount)
    party.decrement!(:account_balance, amount)
  end

  def increase_party_balance
    party.increment!(:account_balance, amount)
  end
end