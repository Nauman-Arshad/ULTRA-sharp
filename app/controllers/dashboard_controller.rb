# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @tab = %w[dashboard parties products orders payments].include?(params[:tab]) ? params[:tab] : "dashboard"
    @query = params[:query].to_s.strip
    user_scope = Current.user

    parties_scope  = Party.for_user(user_scope)
    payments_scope = Payment.for_user(user_scope).includes(:party, :order)
    orders_scope   = Order.for_user(user_scope).includes(:party, :order_items)
    products_scope = Product.for_user(user_scope)

    if @query.present?
      q = "%#{Party.sanitize_sql_like(@query)}%"
      parties_scope  = parties_scope.where("party_name ILIKE :q OR phone ILIKE :q OR address ILIKE :q", q: q)
      payments_scope = payments_scope.joins(:party).where("parties.party_name ILIKE :q OR parties.phone ILIKE :q", q: q)
      orders_scope   = orders_scope.joins(:party).where("orders.order_number ILIKE :q OR parties.party_name ILIKE :q", q: q)
      products_scope = products_scope.where("name ILIKE :q", q: q)
    end

    @outstanding_balance = parties_scope.where("account_balance > 0").sum(:account_balance)

    case @tab
    when "parties"
      @pagy_parties, @parties = pagy(parties_scope.order(created_at: :desc), items: 25)
    when "products"
      @pagy_products, @products = pagy(products_scope.order(:name), items: 25)
    when "orders"
      @overdue_filter = params[:overdue] == "1"
      filtered_orders = orders_scope.order(order_date: :desc, created_at: :desc)
      filtered_orders = filtered_orders.where("remaining_amount > 0 AND order_date <= ?", 30.days.ago.to_date) if @overdue_filter
      @pagy_orders, @orders = pagy(filtered_orders, items: 25)
    when "payments"
      @pagy_payments, @payments = pagy(payments_scope.order(payment_date: :desc, created_at: :desc), items: 25)
    when "dashboard"
      @range = params[:range].presence || "7d"
      @to_date = begin
        params[:to].present? ? Date.parse(params[:to]) : Date.current
      rescue ArgumentError
        Date.current
      end

      case @range
      when "30d"
        @from_date = @to_date - 29.days
      when "custom"
        @from_date = begin
          params[:from].present? ? Date.parse(params[:from]) : (@to_date - 6.days)
        rescue ArgumentError
          @to_date - 6.days
        end
      else
        @from_date = @to_date - 6.days
      end

      period = @from_date.beginning_of_day..@to_date.end_of_day

      @overdue_count  = Order.for_user(user_scope).where("remaining_amount > 0 AND order_date <= ?", 30.days.ago.to_date).count
      @overdue_amount = Order.for_user(user_scope).where("remaining_amount > 0 AND order_date <= ?", 30.days.ago.to_date).sum(:remaining_amount)

      @parties_total = parties_scope.count
      @parties_new   = parties_scope.where(created_at: period).count

      orders_in_period   = Order.for_user(user_scope).where(order_date: @from_date..@to_date)
      payments_in_period = Payment.for_user(user_scope).where(payment_date: @from_date..@to_date)

      @orders_in_period             = orders_in_period.count
      @orders_pending_in_period     = orders_in_period.where(payment_status: "pending").count
      @orders_in_progress_in_period = orders_in_period.where(order_status: %w[progress in_progress]).count

      @payments_amount_in_period = payments_in_period.sum(:amount)
      @payments_count_in_period  = payments_in_period.count

      latest_parties  = parties_scope.order(created_at: :desc).limit(10).map { |p| { type: "Party",   record: p, created_at: p.created_at } }
      latest_orders   = orders_scope.order(order_date: :desc, created_at: :desc).limit(10).map { |o| { type: "Order",   record: o, created_at: o.created_at } }
      latest_payments = payments_scope.order(payment_date: :desc, created_at: :desc).limit(10).map { |p| { type: "Payment", record: p, created_at: p.created_at } }
      @latest_records = (latest_parties + latest_orders + latest_payments).sort_by { |h| -h[:created_at].to_i }.first(20)
    end
  end
end
