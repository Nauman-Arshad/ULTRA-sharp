# frozen_string_literal: true

class Product < ApplicationRecord
  has_many :orders, dependent: :nullify

  validates :name, presence: true
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }, presence: true
end
