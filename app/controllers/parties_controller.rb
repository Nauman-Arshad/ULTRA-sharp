# frozen_string_literal: true

class PartiesController < ApplicationController
  before_action :set_party, only: %i[show edit update destroy]

  def index
    redirect_to root_path(tab: "parties")
  end

  def show
    orders   = @party.orders.order(order_date: :asc, created_at: :asc)
    payments = @party.payments.order(payment_date: :asc, created_at: :asc)

    orders_total   = orders.sum(:total_amount).to_d
    payments_total = payments.sum(:amount).to_d

    opening_balance = @party.account_balance.to_d - (orders_total - payments_total)

    history = []

    if opening_balance != 0
      history << {
        kind: "Opening",
        date: @party.created_at,
        description: "Opening balance",
        amount: opening_balance.abs,
        delta: opening_balance
      }
    end

    orders.each do |order|
      history << {
        kind: "Order",
        date: order.order_date || order.created_at,
        description: order.display_number,
        amount: order.total_amount.to_d,
        delta: order.total_amount.to_d,
        record: order
      }
    end

    payments.each do |payment|
      history << {
        kind: "Payment",
        date: payment.payment_date || payment.created_at.to_date,
        description: "Payment",
        amount: payment.amount.to_d,
        delta: -payment.amount.to_d,
        record: payment
      }
    end

    history.sort_by! { |h| h[:date] || Time.current }

    running = 0.to_d
    history.each do |h|
      running += h[:delta]
      h[:balance] = running
    end

    @history_items = history
  end

  def new
    @party = Party.new
  end

  def create
    @party = Party.new(party_params)
    if @party.save
      redirect_to @party, notice: "Party was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @party.update(party_params)
      redirect_to @party, notice: "Party was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @party.destroy
    redirect_to root_path(tab: "parties"), notice: "Party was successfully removed.", status: :see_other
  end

  private

  def set_party
    @party = Party.find(params[:id])
  end

  def party_params
    params.require(:party).permit(:party_name, :phone, :address, :status, :account_balance)
  end
end
