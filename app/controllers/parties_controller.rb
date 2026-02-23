# frozen_string_literal: true

class PartiesController < ApplicationController
  before_action :set_party, only: %i[show edit update destroy]

  def index
    redirect_to root_path(tab: "parties")
  end

  def show
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
