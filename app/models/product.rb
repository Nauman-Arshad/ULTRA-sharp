# frozen_string_literal: true

class Product < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :nullify

  validates :name, presence: true
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }, presence: true

  scope :for_user, ->(u) { u&.superadmin? ? all : where(user_id: u&.id) }
end
