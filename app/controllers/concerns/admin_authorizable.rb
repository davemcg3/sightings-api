class NotPermittedException < StandardError; end

module AdminAuthorizable
  extend ActiveSupport::Concern

  included do
    rescue_from NotPermittedException do
      render json: { error: I18n.t('admin_authorizable_concern.not_permitted') }, status: :forbidden
    end
  end

  def authorize!(action, object=nil)
    # ap action == :read
    # ap current_user&.admin?
    # ap object&.user == current_user
    raise NotPermittedException unless (action == :read) || (current_user && (current_user&.admin? || object&.user == current_user))
    true
  end
end
