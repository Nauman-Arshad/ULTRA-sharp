# frozen_string_literal: true

module SuperAdminAuthorization
  extend ActiveSupport::Concern

  included do
    before_action :require_superadmin
  end

  private

  def require_superadmin
    return if Current.user&.superadmin?

    redirect_to root_path, alert: "You are not authorized to access that page."
  end
end
