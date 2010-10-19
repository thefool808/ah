class AuctionHouse# < ActiveRecord::Base
  class LoginError < StandardError; end
  class ThrottleError < StandardError; end

  CONFIG_FILE = File.join(Rails.root.to_s, 'config', 'auction_house.yml')

  LOGIN_URL = '/login/en'
  AUTHENTICATOR_URL = '/login/en/authenticator'
  MAINTENANCE_URL = '/common/static/maintenance'

  SLEEP_TIME = 0.75

  class_attribute :config
  self.config = YAML.load(File.open(CONFIG_FILE))

  class_attribute :current_scan
  class_attribute :last_query_time

  attr :agent

  def login!
    agent.get(config["root"]) do |page|
      if page.uri.request_uri.match(MAINTENANCE_URL)
        raise LoginError, 'WowArmory is down for maitenance.  Is it Tuesday?'
      end
      login_result = page.form_with(:name => "loginForm") do |login|
        login.accountName = config["user"]
        login.password = config["pass"]
      end.submit

      new_url = login_result.uri.request_uri

      logger.info 'Login attempt result:'
      logger.info new_url

      if new_url.match(LOGIN_URL)
        raise LoginError, 'Could not login'
      elsif new_url.match(AUTHENTICATOR_URL) then
        @needs_auth = true
      end
    end
    self
  end

  # def authenticate!(code)
  #   form = agent.current_page.forms.first
  #   form['authValue'] = code
  #   form.submit
  #   puts agent.current_page.uri.request_uri
  #   if agent.current_page.uri.request_uri.match(config['root'])
  #     return self
  #   else
  #     raise LoginError, "Could not login (arrived at wrong auction house page)"
  #   end
  # end

  def needs_authenticator?
    !!@needs_auth
  end

  def search(query)
    start = 0
    count = 0
    while true do
      query.parameters['start'] = start

      begin
        auctions = do_query(query)
      rescue ThrottleError
        logger.info "Throttled!"
        # unless throttled?
          # @throttled = true
          sleep(SLEEP_TIME)
          retry
        # end
        # raise $!
      end

      break if auctions.empty?
      import_auctions(auctions)
      count += auctions.length

      start += 50
    end
    return count
  end

  def self.import_all
    new.login!.full_scan
  end

  def full_scan
    self.class.current_scan = Scan.create!(:started_at => Time.now())
    results = search(Query.everything)
    self.class.current_scan.finished_at = Time.now()
    self.class.current_scan.auction_count = results
    self.class.current_scan.save
  end

private
  def agent
    return @agent if @agent
    @agent = Mechanize.new {|agent| agent.user_agent = config['user_agent']}
    @agent.pre_connect_hooks << lambda {|params| params[:request]['Connection'] = 'keep-alive'}
    return @agent
  end

  def do_query(query)
    throttle
    url = config['query_url'] + query.to_s
    logger.info "Query: #{url}"
    result = agent.get(url)
    page = JSON::load(result.body)

    if page["auctionSearch"].nil? then
      raise ThrottleError, "Hit throttle! Skipping request..."
    end

    return page["auctionSearch"]["auctions"]
  end

  def throttle
    if self.class.last_query_time.blank?
      self.class.last_query_time = Time.now
    else
      diff = Time.now - self.class.last_query_time
      if diff < SLEEP_TIME
        sleep_time = SLEEP_TIME - diff
        logger.info "sleeping #{SLEEP_TIME} - #{diff} : #{sleep_time}"
        sleep(sleep_time)
      end
      self.class.last_query_time = Time.now
    end
  end

  def throttled?
    @throttled ||= false
  end

  def import_auctions(auctions)
    Auction.import(auctions)
  end
end
