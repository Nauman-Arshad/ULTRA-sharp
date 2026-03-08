# frozen_string_literal: true

class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy]

  def index
    redirect_to root_path(tab: "products")
  end

  def show
  end

  def new
    @product = Product.new(user: Current.user)
  end

  def create
    @product = Product.new(product_params.merge(user: Current.user))
    if @product.save
      redirect_to @product, notice: "Product was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to @product, notice: "Product was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to root_path(tab: "products"), notice: "Product was successfully removed.", status: :see_other
  end

  private

  def set_product
    @product = Product.for_user(Current.user).find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :unit_price)
  end
end
