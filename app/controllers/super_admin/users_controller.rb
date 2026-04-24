# frozen_string_literal: true

module SuperAdmin
  class UsersController < ApplicationController
    include SuperAdminAuthorization

    before_action :set_user, only: %i[edit update destroy]

    def index
      @users = User.order(:username)
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params_for_create)
      if @user.save
        redirect_to super_admin_users_path, notice: "User was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @user.update(user_params_for_update)
        redirect_to super_admin_users_path, notice: "User was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @user.id == Current.user.id
        redirect_to super_admin_users_path, alert: "You cannot delete your own account."
        return
      end
      if @user.superadmin? && User.superadmins.count <= 1
        redirect_to super_admin_users_path, alert: "Cannot delete the last user with superadmin role."
        return
      end
      @user.destroy
      redirect_to super_admin_users_path, notice: "User was successfully deleted."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params_for_create
      p = params.require(:user).permit(:username, :email_address, :password, :password_confirmation, roles: [])
      p[:roles] = Array(p[:roles]).reject(&:blank?).uniq
      p[:roles] = ["admin"] if p[:roles].blank?
      p[:roles] &= User::ROLES
      p
    end

    def user_params_for_update
      p = params.require(:user).permit(:username, :email_address, :password, :password_confirmation, roles: [])
      p.delete(:password) if p[:password].blank?
      p.delete(:password_confirmation) if p[:password_confirmation].blank?
      p[:roles] = Array(p[:roles]).reject(&:blank?).uniq
      p[:roles] &= User::ROLES
      # Prevent removing superadmin from the last user who has it
      if @user.superadmin? && User.superadmins.count <= 1 && !p[:roles].include?("superadmin")
        p[:roles] |= ["superadmin"]
      end
      p[:roles] = ["admin"] if p[:roles].blank?
      p
    end
  end
end
