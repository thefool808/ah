class Scan < ActiveRecord::Base
  def running_time
    return 0 if self.finished_at.blank?
    self.finished_at - self.started_at
  end
end
