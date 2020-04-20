require 'selenium-webdriver'
require 'yaml'

module TwoPines
module AppDriver
module Driver

  def browser
    $browser
  end

  def browser_tools
    $browser_tools
  end

  def launch_title
    raise 'Not implemented'
  end

  def wait timeout
    Selenium::WebDriver::Wait.new :timeout=>timeout
  end

  def check_node
    raise 'Not implemented'
  end

  def go_to_node
    raise 'Not implemented'
  end

end # module
end # module
end # module
