module ApplicationHelper
  def number_to_wow_currency(num)
    return "nil" if num.blank?
    m = num.to_i
    gold = sprintf("%dg", m / 10000)
    silver = sprintf("%ds", (m / 100) % 100)
    copper = sprintf("%dc", m % 100)
    "#{gold} #{silver} #{copper}"
  end

  def datetime(date)
    return "n/a" if date.nil?
    date.strftime("%m/%d/%Y - %I:%M %p")
  end

  def time(float)
    min, sec = (float / 60).to_s.split(".")
    sprintf("%sm %ds", min, ("0.#{sec}".to_f * 60).round)
  end
end
