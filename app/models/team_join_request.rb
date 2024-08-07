class TeamJoinRequest < ApplicationRecord
  belongs_to :user
  belongs_to :team

  enum :status, %i[pending approved rejected canceled]

  validates :status, inclusion: { in: TeamJoinRequest.statuses.keys }
  validates :user_id,
            uniqueness: {
              scope: :team_id,
              message: 'has already sent a join request'
            }

  def allowed? = request_number < team.settings(:join_requirements).max_allowed_requests
end
