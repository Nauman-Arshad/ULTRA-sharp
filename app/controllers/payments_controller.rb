# frozen_string_literal: true

class PaymentsController < ApplicationController
  before_action :set_payment, only: %i[show edit update destroy]

  def index
    redirect_to root_path(tab: "payments")
  end

  def show
  end

  def new
    @payment = Payment.new(payment_date: Date.current)
    @parties = Party.for_user(Current.user).order(:party_name)
  end

  def create
    @payment = Payment.new(payment_params)
    if @payment.save
      redirect_to @payment, notice: "Payment was successfully created."
    else
      @parties = Party.for_user(Current.user).order(:party_name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @parties = Party.for_user(Current.user).order(:party_name)
  end

  def update
    if @payment.update(payment_params)
      redirect_to @payment, notice: "Payment was successfully updated."
    else
      @parties = Party.for_user(Current.user).order(:party_name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @payment.destroy
    redirect_to root_path(tab: "payments"), notice: "Payment was successfully removed.", status: :see_other
  end

  private

  def set_payment
    @payment = Payment.for_user(Current.user).find(params[:id])
  end

  def payment_params
    permitted = params.require(:payment).permit(:party_id, :amount, :payment_date)
    allowed_party_ids = Party.for_user(Current.user).pluck(:id)
    permitted[:party_id] = nil unless permitted[:party_id].to_s.in?(allowed_party_ids.map(&:to_s))
    permitted
  end
end
