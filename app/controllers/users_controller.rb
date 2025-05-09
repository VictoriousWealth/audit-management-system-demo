# Controller for managing user-related actions.
#
# This controller is responsible for displaying the details of the currently authenticated user.
# It includes authentication to ensure that only logged in users can access the show (since only they have ids) action.
#
# Before actions:
# - authenticate_user!: ensures that only authenticated users can access the actions in this controller.
class UsersController < ApplicationController
  before_action :authenticate_user!

  # Displays the profile page of the currently authenticated user.
  #
  # The current logged in user is assigned to the @user instance variable. This variable can be used
  # in the view to render the user's info.
  #
  # @return [void] renders the show view with the current user's details.
  def show
    @user = current_user
  end

end
