# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :party
  has_many :order_items, dependent: :destroy
  has_many :payments, dependent: :destroy

  accepts_nested_attributes_for :order_items, allow_destroy: true, reject_if: proc { |a| a[:product_id].blank? && a[:quantity].to_s.blank? }

  before_save :calculate_totals
  after_create :add_order_total_to_party_balance
  after_update :adjust_party_balance_for_order_change
  after_destroy :subtract_order_total_from_party_balance
  after_create :create_advance_payment

  validates :party_id, presence: true
  validate :must_have_at_least_one_item

  ORDER_STATUSES = %w[pending progress confirmed in_progress delivered cancelled].freeze
  DEFAULT_ORDER_STATUS = "progress"

  def display_number
    order_number.presence || "##{id}"
  end

  def products_summary
    return "—" if order_items.empty?
    return order_items.first.product_name if order_items.size == 1
    "#{order_items.size} items"
  end

  def calculate_totals
    self.advance_payment = (advance_payment || 0).to_d
    self.total_amount = order_items.reject(&:marked_for_destruction?).sum { |i| (i.quantity || 0).to_d * (i.unit_price || 0).to_d }
    self.remaining_amount = total_amount - self.advance_payment

    if self.advance_payment == 0
      self.payment_status = "pending"
    elsif self.advance_payment < total_amount
      self.payment_status = "partial"
    else
      self.payment_status = "paid"
    end
  end

  def create_advance_payment
    return unless (advance_payment || 0) > 0
    payments.create!(
      party: party,
      order: self,
      amount: advance_payment,
      payment_date: Date.current
    )
  end

  private

  def add_order_total_to_party_balance
    party.increment!(:account_balance, total_amount.to_d)
  end

  def adjust_party_balance_for_order_change
    return unless saved_change_to_total_amount?
    old_total = total_amount_before_last_save.to_d
    party.increment!(:account_balance, total_amount.to_d - old_total)
  end

  def subtract_order_total_from_party_balance
    party.decrement!(:account_balance, total_amount.to_d)
  end

  def must_have_at_least_one_item
    items = order_items.reject(&:marked_for_destruction?)
    return if items.any? { |i| i.product_name.present? && i.quantity.to_d.positive? }
    errors.add(:base, "Order must have at least one product with quantity")
  end
end
