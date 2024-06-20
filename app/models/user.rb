class User < ApplicationRecord
  has_many :runs, dependent: :destroy

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
              with: /\A[a-z0-9_.]{3,}\z/,
              message:
                'can only contain lowercase letters, numbers, underscores, and periods and must be at least 3 characters long'
            }

  def login
    @login || username || email
  end

  def self.find_for_database_authentication(warden_conditions)
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

  def total_miles
    runs.sum(:distance)
  end

  def total_duration
    runs.sum(:duration)
  end

  def total_km
    (total_miles * 1.609344).round(3)
  end

  def runs_between(start_date, end_date)
    runs.where(date: start_date..end_date).order(date: :desc)
  end

  def runs_in_range(range)
    runs.where(date: range).order(date: :desc)
  end
end
