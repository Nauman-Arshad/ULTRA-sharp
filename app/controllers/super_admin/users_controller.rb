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
        redirect_to super_admin_users_path, alert: "Cannot delete the last superadmin."
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
      p = params.require(:user).permit(:username, :email_address, :password, :password_confirmation, :role)
      p[:role] = "admin" unless User::ROLES.include?(p[:role])
      p
    end

    def user_params_for_update
      p = params.require(:user).permit(:username, :email_address, :password, :password_confirmation, :role)
      p.delete(:password) if p[:password].blank?
      p.delete(:password_confirmation) if p[:password_confirmation].blank?
      if @user.superadmin? && User.superadmins.count <= 1 && p[:role] != "superadmin"
        p[:role] = "superadmin" # prevent demoting last superadmin
      end
      p[:role] = "admin" unless User::ROLES.include?(p[:role])
      p
    end
  end
end
