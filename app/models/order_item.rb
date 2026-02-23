# frozen_string_literal: true

class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product, optional: true

  before_validation :set_product_details_from_product
  before_save :calculate_line_total

  validates :product_name, presence: true
  validates :quantity, numericality: { greater_than: 0 }, presence: true
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }, presence: true

  def set_product_details_from_product
    return unless product_id.present? && product.present?
    self.product_name = product.name
    self.unit_price = product.unit_price
  end

  def calculate_line_total
    self.line_total = (quantity || 0).to_d * (unit_price || 0).to_d
  end
end
