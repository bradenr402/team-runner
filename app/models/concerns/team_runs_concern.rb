module TeamRunsConcern
  extend ActiveSupport::Concern

  def long_run_distance_for_user(user)
    return long_run_distance_neutral unless require_gender?

    user.male? ? long_run_distance_male : long_run_distance_female
  end

  def streak_distance_for_user(user)
    return streak_distance_neutral unless require_gender?

    user.male? ? streak_distance_male : streak_distance_female
  end

  def recent_runs
    Run
      .includes(:user)
      .where(users: { id: members.pluck(:id) })
      .order(date: :desc)
      .first(15)
  end

  def recent_long_runs
    Run
      .includes(:user)
      .where(users: { id: members.pluck(:id) })
      .where(
        'distance >= CASE
        WHEN users.gender = ? THEN ?
        WHEN users.gender = ? THEN ?
        ELSE ? END',
        'male',
        long_run_distance_male,
        'female',
        long_run_distance_female,
        long_run_distance_neutral
      )
      .order(date: :desc)
      .first(15)
  end

  def streak_runs
    Run
      .includes(:user)
      .where(users: { id: members.pluck(:id) })
      .where('date >= ?', Date.current.yesterday)
      .where(
        'distance >= CASE
        WHEN users.gender = ? THEN ?
        WHEN users.gender = ? THEN ?
        ELSE ? END',
        'male',
        streak_distance_male,
        'female',
        streak_distance_female,
        streak_distance_neutral
      )
      .order(date: :desc)
  end

  def featured_runs = (recent_long_runs | streak_runs).sort_by(&:date).reverse

  def long_runs_in_date_range(range)
    Run
      .includes(:user)
      .where(users: { id: members.pluck(:id) })
      .in_date_range(range)
      .where(
        'distance >= CASE
        WHEN users.gender = ? THEN ?
        WHEN users.gender = ? THEN ?
        ELSE ? END',
        'male',
        long_run_distance_male,
        'female',
        long_run_distance_female,
        long_run_distance_neutral
      )
  end
end