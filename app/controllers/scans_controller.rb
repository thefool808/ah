class ScansController < ApplicationController
  def index
    @scans = Scan.find(:all, :order => 'started_at DESC')
  end
end
