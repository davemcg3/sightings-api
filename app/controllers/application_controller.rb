class ApplicationController < ActionController::API
  include ActionController::Serialization
  include TokenAuthenticable
  include AdminAuthorizable
end
