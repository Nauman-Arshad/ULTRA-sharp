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

    @outstanding_balance = Party.where("account_balance > 0").sum(:account_balance)

    if @tab == "dashboard"
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
      else # "7d" default
        @from_date = @to_date - 6.days
      end

      period = @from_date.beginning_of_day..@to_date.end_of_day

      @parties_total = Party.count
      @parties_new   = Party.where(created_at: period).count

      orders_in_period   = Order.where(order_date: @from_date..@to_date)
      payments_in_period = Payment.where(payment_date: @from_date..@to_date)

      @orders_in_period            = orders_in_period.count
      @orders_pending_in_period    = orders_in_period.where(payment_status: "pending").count
      @orders_in_progress_in_period = orders_in_period.where(order_status: %w[progress in_progress]).count

      @payments_amount_in_period = payments_in_period.sum(:amount)
      @payments_count_in_period  = payments_in_period.count
    end

    # Latest records combined in one list (for dashboard tab)
    latest_parties = Party.order(created_at: :desc).limit(10).map { |p| { type: "Party", record: p, created_at: p.created_at } }
    latest_orders = Order.includes(:party).order(created_at: :desc).limit(10).map { |o| { type: "Order", record: o, created_at: o.created_at } }
    latest_payments = Payment.includes(:party, :order).order(created_at: :desc).limit(10).map { |p| { type: "Payment", record: p, created_at: p.created_at } }
    @latest_records = (latest_parties + latest_orders + latest_payments).sort_by { |h| -h[:created_at].to_i }.first(20)
  end
end
