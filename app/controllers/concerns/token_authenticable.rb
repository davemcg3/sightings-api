class NotAuthorizedException < StandardError; end

module TokenAuthenticable
  extend ActiveSupport::Concern

  included do
    attr_reader :current_user

    before_action :authenticate_user

    rescue_from NotAuthorizedException, with: -> { render json: { error: 'Not Authorized' }, status: :unauthorized }
  end

  private

  def authenticate_user
    @current_user = DecodeAuthenticationCommand.call(request.headers).result

    # commented out following raise so we can allow current_user to be nil instead of rendering error
    # authenticate where needed with admin_authorizable::authorize!
    #
    # raise NotAuthorizedException unless @current_user
  end
end
