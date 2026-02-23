# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :set_order, only: %i[show edit update destroy]

  def index
    redirect_to root_path(tab: "orders")
  end

  def show
  end

  def new
    @order = Order.new(order_date: Date.current)
    @order.order_items.build
    @parties = Party.order(:party_name)
    @products = Product.order(:name)
  end

  def create
    @order = Order.new(order_params)
    @order.order_number = "ORD-#{Time.current.to_i}" if @order.order_number.blank?
    @order.order_status = Order::DEFAULT_ORDER_STATUS if @order.order_status.blank?
    if @order.save
      redirect_to @order, notice: "Order was successfully created."
    else
      @parties = Party.order(:party_name)
      @products = Product.order(:name)
      @order.order_items.build if @order.order_items.empty?
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @parties = Party.order(:party_name)
    @products = Product.order(:name)
    @order.order_items.build if @order.order_items.empty?
  end

  def update
    if @order.update(order_params)
      redirect_to @order, notice: "Order was successfully updated."
    else
      @parties = Party.order(:party_name)
      @products = Product.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @order.destroy
    redirect_to root_path(tab: "orders"), notice: "Order was successfully removed.", status: :see_other
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(
      :party_id, :advance_payment, :order_date, :order_status, :order_number,
      order_items_attributes: %i[id product_id product_name quantity unit_price _destroy]
    )
  end
end
