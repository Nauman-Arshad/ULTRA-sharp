class ProfilesController < ApplicationController
  def edit
  end

  def update
    if params[:change] == "password"
      update_password
    else
      update_details
    end
  end

  private

  def update_password
    unless Current.user.authenticate(params[:current_password])
      flash.now[:alert] = "Current password is incorrect."
      render :edit, status: :unprocessable_entity and return
    end

    if params[:password] != params[:password_confirmation]
      flash.now[:alert] = "New passwords do not match."
      render :edit, status: :unprocessable_entity and return
    end

    if params[:password].blank?
      flash.now[:alert] = "New password cannot be blank."
      render :edit, status: :unprocessable_entity and return
    end

    Current.user.update!(password: params[:password])
    redirect_to edit_profile_path, notice: "Password updated successfully."
  end

  def update_details
    if Current.user.update(username: params[:username])
      redirect_to edit_profile_path, notice: "Profile updated successfully."
    else
      flash.now[:alert] = Current.user.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_entity
    end
  end
end
