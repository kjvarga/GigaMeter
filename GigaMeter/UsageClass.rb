#require 'rubygems'
#require 'mechanize'
#require 'nokogiri'

class Usage
  
  @@LOGIN_URL = "https://www.unwired.com.au/myaccount/login.php?ex=nx"
  @@IN_PEAK_USAGE_URL = "https://www.unwired.com.au/myaccount/usage.php?view=PEAK"
  @@OFF_PEAK_USAGE_URL = "https://www.unwired.com.au/myaccount/usage.php?view=OFF_PEAK"
  @@USAGE_TABLE_SELECTOR = "table.usageTable tbody tr td"
  @@DAYS_REMAINING_REGEX = /\s+(\d+)\s+/
  @@USAGE_REGEX = /\s*(\d+[.]?\d*)\s*GB/i
  @@COOKIE_FILE = 'cookies.txt'

  def self.doLogin(agent, login, password, path, login_page=nil)
    print "Logging in...\n"
    login_page = agent.get(@@LOGIN_URL) if login_page.nil?
    login_page.form_with(:name => "loginForm") do |login|
      login.login_name = login
      login.login_password = password
      login.password_fake = password
      login.checkboxes[0].checked = true
    end.submit
    agent.cookie_jar.save_as(File.join(path, @@COOKIE_FILE))
  end

  def self.getUsageData(login, password, path)
    ipusage = 0
    opusage = 0
    dr = 0
    agent = WWW::Mechanize.new 
    agent.cookie_jar.load(File.join(path, @@COOKIE_FILE)) if File.exists?(File.join(path, @@COOKIE_FILE))

    # Try to get the In Peak Usage page.  If we are sent to the login page
    # we need to login and update our cookies
    in_peak_page = agent.get(@@IN_PEAK_USAGE_URL)
    if !in_peak_page.forms.select { |form| form.name == 'loginForm' }.empty?
      doLogin(agent, in_peak_page)
      in_peak_page = agent.get(@@IN_PEAK_USAGE_URL)
    end

    in_peak = Nokogiri::HTML(in_peak_page.body)
    in_peak.css(@@USAGE_TABLE_SELECTOR).each do |text|
      if text.content.match(/upload and download data/i)
        ipusage = text.content.scan(@@USAGE_REGEX)[0][0]
      elsif text.content.match(/days remaining in period/i)
        dr = text.content.scan(@@DAYS_REMAINING_REGEX)[0][0]
      end
    end
    off_peak = Nokogiri::HTML(agent.get(@@OFF_PEAK_USAGE_URL).body)
    off_peak.css(@@USAGE_TABLE_SELECTOR).each do |text|
      if text.content.match(/upload and download data/i)
        opusage = text.content.scan(@@USAGE_REGEX)[0][0]
      end
    end
    puts "%.2f GB / %.2f GB / %d days" % [ipusage, opusage, dr]
    return [ipusage, opusage, dr]
  end
end
