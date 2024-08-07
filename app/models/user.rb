class User < ApplicationRecord
  include UserCalculations
  include UserSettings

  USERNAME_FORMAT = /\A[a-z0-9_.]{3,}\z/
  PHONE_NUMBER_FORMAT = /\A\+?\d{10,15}\z/

  has_many :runs, dependent: :destroy
  has_many :team_memberships, dependent: :destroy
  has_many :teams, through: :team_memberships
  has_many :owned_teams,
           class_name: 'Team',
           foreign_key: 'owner_id',
           dependent: :destroy
  has_many :join_requests, foreign_key: 'user_id', class_name: 'TeamJoinRequest'
  has_one_attached :avatar

  attr_accessor :remove_avatar

  before_save :purge_avatar, if: -> { remove_avatar == '1' }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         authentication_keys: [:login]

  attr_writer :login

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username,
            presence: true,
            uniqueness: {
              case_sensitive: false
            },
            format: {
              with: USERNAME_FORMAT,
              message:
                'can only contain lowercase letters, numbers, underscores, and periods' \
                  'and must be at least 3 characters long'
            }
  validate :password_complexity
  validates :display_name, length: { maximum: 100 }, allow_blank: true
  validates :phone_number,
            uniqueness: true,
            allow_blank: true,
            format: {
              with: PHONE_NUMBER_FORMAT,
              message: 'is not a valid phone number'
            }

  enum gender: { male: 'male', female: 'female' }
  validates :gender, inclusion: { in: genders.keys }, if: -> { gender.present? }

  def login = @login || username || email

  def runs_in_date_range(range) = runs.in_date_range(range)

  def runs_today = runs.today

  def member_of?(team) = teams.include?(team)

  def membered_teams = teams.where.not(owner_id: id)

  def default_name = display_name.present? ? display_name : username

  def other_teams =
    Team.not_included_in(teams.pluck(:id) + owned_teams.pluck(:id))

  def owns?(team) = self == team.owner

  def meets_requirements?(team)
    return { allowed?: false, message: 'Team not found.' } if team.nil?

    if team.settings(:join_requirements).require_gender && gender.blank?
      return(
        {
          allowed?: false,
          message: 'You must specify your gender to join this team.'
        }
      )
    end

    { allowed?: true, message: 'You meet the requirements to join this team.' }
  end

  private

  def password_complexity
    return if password.blank?

    password_regex = /(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[#?!@$%^&*-])/

    unless password =~ password_regex
      errors.add :password,
                 'Complexity requirement not met. Password must include at least ' \
                   '1 uppercase letter, 1 lowercase letter, 1 digit, and 1 special character (#?!@$%^&*-)'
    end
  end

  def purge_avatar = avatar.purge_later

  class << self
    def find_for_database_authentication(warden_conditions)
      conditions = warden_conditions.dup
      if (login = conditions.delete(:login))
        where(conditions.to_h).where(
          [
            'lower(username) = :value OR lower(email) = :value',
            { value: login.strip.downcase }
          ]
        ).first
      elsif conditions.key?(:username) || conditions.key?(:email)
        where(conditions.to_h).first
      end
    end
  end
end
