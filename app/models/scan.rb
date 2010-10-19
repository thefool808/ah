class Scan < ActiveRecord::Base
  def running_time
    self.finished_at - self.started_at
  end
end
