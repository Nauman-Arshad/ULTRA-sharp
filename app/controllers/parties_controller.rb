require "csv"

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

  def import
  end

  def import_csv
    file = params[:file]

    if file.blank?
      redirect_to import_parties_path, alert: "Please choose a CSV file."
      return
    end

    created = 0
    skipped = 0

    CSV.foreach(file.path, headers: true) do |row|
      attrs = {
        party_name: row["party_name"].to_s.strip,
        phone: row["phone"].to_s.strip.presence,
        address: row["address"].to_s.strip.presence,
        status: (row["status"].presence || "active").downcase,
        account_balance: row["opening_balance"].presence ? row["opening_balance"].to_d : 0.to_d
      }

      if attrs[:party_name].blank?
        skipped += 1
        next
      end

      party = Party.new(attrs)
      if party.save
        created += 1
      else
        skipped += 1
      end
    end

    message = "Imported #{created} party#{'ies' if created != 1}."
    message += " Skipped #{skipped} row#{'s' if skipped != 1}." if skipped.positive?
    redirect_to root_path(tab: "parties"), notice: message
  end

  def template
    headers = %w[party_name phone address status opening_balance]

    csv = CSV.generate do |csv|
      csv << headers
      csv << ["Osaka Dealer", "+1 (234) 567-8900", "Multan Road", "active", "0"]
    end

    send_data csv, filename: "parties_template.csv"
  end

  private

  def set_party
    @party = Party.find(params[:id])
  end

  def party_params
    params.require(:party).permit(:party_name, :phone, :address, :status, :account_balance)
  end
end
