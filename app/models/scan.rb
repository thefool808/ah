class Scan < ActiveRecord::Base
  def self.latest_scan_id
    return @latest_scan_id ||= find(:last).id
  end

  def running_time
    return 0 if self.finished_at.blank?
    self.finished_at - self.started_at
  end
end
