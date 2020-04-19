require 'zip'
require 'two_pines/reporter'

module TwoPines
class Bot

  attr_accessor :app_driver_class, :app_driver, :browser, :source_table, :node_object_map, :config, :custom_reporter, :options

  #
  # {
  #   :app_driver_class=>
  #   :source_data=>
  #   :node_object_map=>
  #   :custom_reporter=>
  #   :options=> Hash
  def initialize config
    Reporter.init_reporter

    @node_object_map = config[:node_object_map]
    @source_table = config[:source_data]
    @app_driver_class = config[:app_driver_class]
    @custom_reporter = config[:custom_reporter] if config.key? :custom_reporter
    @options = Hash.new
    @options['RECYCLE_BROWSER_EACH_CHAPTER'] = false
    @options = config[:options] if config.key? :options
    @app_driver = @app_driver_class.new
    start
  end

  def start_browser
    @browser.quit if @browser
    #Selenium::WebDriver.logger.level = :info
    $browser = Selenium::WebDriver.for :chrome
    @browser = $browser
    #@browser.manage.timeouts.implicit_wait = 30
    @app_driver.launch_title
    sleep 2
  end

  def start
    start_browser
    level_bct = [0,0,0,0,0]
    parent = Array.new
    @source_table.each do |node_data|
      level_bct[node_data['level'].to_i-1] += 1
      for index in node_data['level'].to_i...level_bct.size do
        level_bct[index] = 0
      end

      parent[node_data['level'].to_i-1] = node_data

      if node_data['level'] == '1'
        if @options['RECYCLE_BROWSER_PER_CHAPTER']
          start_browser
        end
      end

      node = @node_object_map['node_objects']['_DEFAULT_'].new node_data, level_bct, parent
      if @node_object_map.key? 'node_column'
        if @node_object_map['node_objects'].key? node_data[@node_object_map['node_column']]
          node = @node_object_map['node_objects'][node_data[@node_object_map['node_column']]].new node_data, level_bct, parent
        end
      end

      node.data.each do |key, value|
        if !key.start_with? "__"
          node.send "assert_#{key}"
        end
      end

      if @custom_reporter
        node.finalize_report @custom_reporter
      else
        node.finalize_report
      end
    end
  end

end # class
end # module
