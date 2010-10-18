module ApplicationHelper
  def raw_to_wow(raw)
    return "nil" if raw.blank?
    m = raw.to_i
    gold = sprintf("%dg", m / 10000)
    silver = sprintf("%ds", (m / 100) % 100)
    copper = sprintf("%dc", m % 100)
    "#{gold} #{silver} #{copper}"
  end

  def datetime(date)
    return "n/a" if date.nil?
    date.strftime("%m/%d/%Y - %I:%M %p")
  end
end
