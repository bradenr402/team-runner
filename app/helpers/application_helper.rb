module ApplicationHelper
  def clock_time_display(duration)
    hours = duration / 3600
    minutes = (duration % 3600) / 60
    seconds = duration % 60

    if hours.positive?
      format(
        '%<hours>d:%<minutes>02d:%<seconds>02d',
        hours:,
        minutes:,
        seconds:
      )
    else
      format('%<minutes>d:%<seconds>02d', minutes:, seconds:)
    end
  end

  def pretty_date(date)
    today = Date.today
    return 'today' if date == today
    return 'yesterday' if date == today.yesterday

    days_difference = (today - date).to_i

    case days_difference
    when 0..6
      date.strftime('%A')
    when 7..365
      if date.year == today.year
        date.strftime('%A, %B %e')
      else
        date.strftime('%A, %B %e, %Y')
      end
    else
      date.strftime('%A, %B %e, %Y')
    end
  end

  def days_ago(date)
    days_difference = (Date.today - date.to_date).to_i

    case days_difference
    when 0
      'today'
    when 1
      'yesterday'
    else
      "#{days_difference} days ago"
    end
  end

  def precise_distance_of_time_in_words(from_time, options = {})
    options = {
      include_seconds: true,
      highest_measure_only: false,
      format: :long
    }.merge(options)

    to_time = 0

    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)

    distance = (to_time - from_time).abs
    parts = calculate_time_parts(distance, options)

    if parts.empty?
      options[:include_seconds] ? '0 seconds' : '0 minutes'
    elsif options[:format] == :short
      parts.join(' ')
    else
      parts.join(', ')
    end
  end

  def format_date(date) = date.strftime('%m/%d/%Y')

  private

  def calculate_time_parts(distance, options)
    parts = []

    short_formats = {
      'year' => 'y',
      'month' => 'mo',
      'week' => 'w',
      'day' => 'd',
      'hour' => 'h',
      'minute' => 'm',
      'second' => 's'
    }

    %w[year month week day hour minute second].each do |interval|
      break if distance.zero? && options[:highest_measure_only]

      next unless distance >= 1.send(interval)

      number = (distance / 1.send(interval)).floor
      distance -= number.send(interval)

      if options[:format] == :short
        parts << "#{number}#{short_formats[interval]}"
      else
        parts << pluralize(number, interval)
      end
    end

    parts
  end
end
