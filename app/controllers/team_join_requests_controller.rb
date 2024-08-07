class TeamJoinRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_join_request, only: %i[update cancel approve reject]
  before_action :set_team, only: %i[cancel approve reject]
  before_action :authorize_owner!, only: %i[approve reject]

  def update
    requirement_check = current_user.meets_requirements?(@team)

    unless requirement_check[:allowed?]
      return(
        redirect_back fallback_location: teams_path,
                      alert: requirement_check[:message]
      )
    end

    unless @join_request.allowed?
      return(
        redirect_back fallback_location: teams_path,
                      error:
                        'Sorry, you cannot request to join this team again.'
      )
    end

    @join_request.pending!
    @join_request.request_number += 1

    if @join_request.save
      redirect_back fallback_location: teams_path,
                    success: 'Join request was successfully sent.'
    else
      redirect_back fallback_location: teams_path,
                    error: 'Unable to send join request.'
    end
  end

  def destroy
    if @join_request.destroy
      redirect_back fallback_location: @team,
                    success: 'Join request was successfully canceled.'
    else
      redirect_back fallback_location: @team,
                    error: 'Unable to cancel join request.'
    end
  end

  def approve
    if @join_request.approved!
      @team.team_memberships.create(user: @join_request.user)
      redirect_back fallback_location: @team, success: 'Join request approved.'
    else
      redirect_back fallback_location: @team,
                    alert: 'Unable to approve join request.'
    end
  end

  def reject
    if @join_request.rejected!
      redirect_back fallback_location: @team, success: 'Join request rejected.'
    else
      redirect_back fallback_location: @team,
                    alert: 'Unable to reject join request.'
    end
  end

  def cancel
    if @join_request.canceled!
      redirect_back fallback_location: @team,
                    success: 'Join request was successfully canceled.'
    else
      redirect_back fallback_location: @team,
                    error: 'Unable to cancel join request.'
    end
  end

  private

  def set_join_request = @join_request = TeamJoinRequest.find(params[:id])
  def set_team = @team = Team.find(@join_request.team_id)

  def authorize_owner!
    unless current_user.owns?(@team)
      redirect_to @team, alert: 'You are not authorized to perform this action.'
    end
  end
end
