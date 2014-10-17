class ApplicationController < ActionController::Base
  include SimonSays::Authorizer

  self.default_authorization_scope = :current_user

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # This would be provided by some authentication
  # system, such as Devise.
  attr_accessor :current_user, :current_admin

  def authenticate_admin!
  end # dummy method

  def authenticate_user!
  end # dummy method
end
