# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @tab = %w[dashboard parties products orders payments].include?(params[:tab]) ? params[:tab] : "dashboard"
    @query = params[:query].to_s.strip

    @parties = Party.order(created_at: :desc)
    @payments = Payment.includes(:party, :order).order(payment_date: :desc, created_at: :desc)
    @orders = Order.includes(:party, :order_items).order(order_date: :desc, created_at: :desc)
    @products = Product.order(:name)

    if @query.present?
      q = "%#{Party.sanitize_sql_like(@query)}%"
      @parties = @parties.where("party_name ILIKE :q OR phone ILIKE :q OR address ILIKE :q", q: q)
      @payments = @payments.joins(:party).where("parties.party_name ILIKE :q OR parties.phone ILIKE :q", q: q)
      @orders = @orders.joins(:party).where("orders.order_number ILIKE :q OR orders.product_name ILIKE :q OR parties.party_name ILIKE :q", q: q)
    end

    @parties_count = Party.count
    @payments_total = Payment.sum(:amount)
    @payments_count = Payment.count
    @orders_count = Order.count
    @orders_pending = Order.where(payment_status: "pending").count
    @outstanding_balance = Party.where("account_balance > 0").sum(:account_balance)

    # Latest records combined in one list (for dashboard tab)
    latest_parties = Party.order(created_at: :desc).limit(10).map { |p| { type: "Party", record: p, created_at: p.created_at } }
    latest_orders = Order.includes(:party).order(created_at: :desc).limit(10).map { |o| { type: "Order", record: o, created_at: o.created_at } }
    latest_payments = Payment.includes(:party, :order).order(created_at: :desc).limit(10).map { |p| { type: "Payment", record: p, created_at: p.created_at } }
    @latest_records = (latest_parties + latest_orders + latest_payments).sort_by { |h| -h[:created_at].to_i }.first(20)
  end
end
