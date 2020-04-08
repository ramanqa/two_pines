require 'zip'
require 'two_pines/reporter'

module TwoPines
class Bot

  attr_accessor :app_driver_class, :app_driver, :browser, :source_table, :config, :node_ui_objects, :custom_reporter

  #
  # {
  #   :app_driver_class=>
  #   :source_data=>
  #   :node_object_map=>
  #   :custom_reporter=>
  def initialize config
    Reporter.init_reporter

    @node_objects = config[:node_object_map]
    @source_table = config[:source_data]
    @app_driver_class = config[:app_driver_class]
    @custom_reporter = config[:custom_reporter] if config.key? :custom_reporter
    @app_driver = @app_driver_class.new
    start
  end

  def start_browser
    @browser.quit if @browser
    #Selenium::WebDriver.logger.level = :debug
    $browser = Selenium::WebDriver.for :chrome
    @browser = $browser
    @browser.manage.timeouts.implicit_wait = 30
    @app_driver.launch_title
    sleep 2
  end

  def start
    level_bct = [0,0,0,0,0]
    parent = Array.new
    require 'pp'
    @source_table.each do |node_data|
      level_bct[node_data['level'].to_i-1] += 1
      parent[node_data['level'].to_i-1] = node_data

      if node_data['level'] == '1'
        level_bct[1] = 0
        level_bct[2] = 0
        level_bct[3] = 0
        level_bct[3] = 0
        level_bct[4] = 0
        start_browser
      end

      node = @node_objects['_DEFAULT_'].new node_data, level_bct, parent
      if @node_objects.key? node_data['display_type']
        node = @node_objects[node_data['display_type']].new node_data, level_bct, parent
      end
      node.assert_title
      node.assert_open
      if @custom_reporter
        node.finalize_report @custom_reporter
      else
        node.finalize_report
      end
    end
  end

end # class
end # module
