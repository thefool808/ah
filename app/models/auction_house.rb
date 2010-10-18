class AuctionHouse# < ActiveRecord::Base
  class LoginError < StandardError; end
  class ThrottleError < StandardError; end

  CONFIG_FILE = File.join(Rails.root.to_s, 'config', 'auction_house.yml')

  LOGIN_URL = '/login/en'
  AUTHENTICATOR_URL = '/login/en/authenticator'

  SLEEP_TIME = 0.55

  class_attribute :config
  self.config = YAML.load(File.open(CONFIG_FILE))

  attr :agent

  def login!
    agent.get(config["root"]) do |page|
      login_result = page.form_with(:name => "loginForm") do |login|
        login.accountName = config["user"]
        login.password = config["pass"]
      end.submit

      new_url = login_result.uri.request_uri

      logger.info 'Login attempt result:'
      logger.info new_url

      if new_url.match(LOGIN_URL)
        raise LoginError, 'Could not login'
      elsif new_url.match("/login/en/authenticator") then
        @needs_auth = true
      end
    end
    self
  end

  def authenticate!(code)
    form = agent.current_page.forms.first
    form['authValue'] = code
    form.submit
    puts agent.current_page.uri.request_uri
    if agent.current_page.uri.request_uri.match(config['root'])
      return self
    else
      raise LoginError, "Could not login (arrived at wrong auction house page)"
    end
  end

  def needs_authenticator?
    !!@needs_auth
  end

  # def cookies
  #   agent.cookies
  # end

  def search(query, scan = false)
    start = 0
    count = 0
    while true do
      query.parameters['start'] = start

      begin
        auctions = do_query(query)
      rescue ThrottleError
        logger.info "Throttled!"
        if !throttled?
          @throttled = true
          sleep(SLEEP_TIME)
          retry
        end
        raise $!
      end

      break if auctions.empty?

      count += auctions.length
      auctions.each{|auction| Auction.find_or_create_from_auction_hash(auction, scan)}

      sleep(SLEEP_TIME)
      start += 50
    end
    return count
  end

  def self.import_all
    ah = new
    ah.login!
    current_scan = Scan.create!(:started_at => Time.now())
    results = ah.search(Query.everything, current_scan)
    current_scan.finished_at = Time.now()
    current_scan.auction_count = results
    current_scan.save
  end

private
  def agent
    return @agent if @agent
    @agent = Mechanize.new {|agent| agent.user_agent = config['user_agent']}
    @agent.pre_connect_hooks << lambda {|params| params[:request]['Connection'] = 'keep-alive'}
    return @agent
  end

  def do_query(query)
    url = config['query_url'] + query.to_s
    logger.info "Query: #{url}"
    result = agent.get(url)
    page = JSON::load(result.body)

    if page["auctionSearch"].nil? then
      raise ThrottleError, "Hit throttle! Skipping request..."
    end

    return page["auctionSearch"]["auctions"]
  end

  def throttled?
    @throttled ||= false
  end
end
