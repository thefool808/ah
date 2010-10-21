module ApplicationHelper
  def number_to_wow_currency(num)
    return "nil" if num.blank?
    m = num.to_i
    gold = sprintf("%dg ", m / 10000)
    gold = '' if gold == '0g '
    silver = sprintf("%ds ", (m / 100) % 100)
    silver = '' if silver == '0s ' && gold == ''
    copper = sprintf("%dc", m % 100)
    "#{gold}#{silver}#{copper}"
  end

  def datetime(date)
    return "n/a" if date.nil?
    date.strftime("%m/%d/%Y - %I:%M %p")
  end

  def time(float)
    min, sec = (float / 60).to_s.split(".")
    sprintf("%sm %ds", min, ("0.#{sec}".to_f * 60).round)
  end

  def time_from_now(date)
    return distance_of_time_in_words(date.to_i, Time.now.to_i, true).gsub("about", "") + " ago"
  end
end
