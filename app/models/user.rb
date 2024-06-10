class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable

  attr_writer :login

  validates :username, presence: true, uniqueness: { case_sensitive: false }

  def login
    @login || username || email
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    where(conditions.to_o).where(
      [
        'lower(username) = :value OR lower(email) = :value',
        { value: login.strip.downcase }
      ]
    ).first
  end
end
