require 'two_pines/reporter'
require 'yaml'

module TwoPines
module AppDriver
module Item
  include TwoPines::Reporter

  attr_accessor :data, :level_bct, :parent, :config

  def browser
    $browser
  end

  def item_index
    @level_bct[@data['level'].to_i-1]-1
  end

  def level
    @data['level'].to_i
  end

  def initialize node, level_bct, parent
    @config = YAML.load_file './config.yaml'
    @data = node
    @data['open'] = true
    @level_bct = level_bct
    @parent = parent.clone
    while @parent.size > @data['level'].to_i-1 do
      @parent.delete(@parent.last)
    end
    init_report @level_bct, @data
  end

  def wait timeout=@config['timeout']
    Selenium::WebDriver::Wait.new :timeout=>timeout
  end

  def method_missing method, *args, &block
    if method.to_s.start_with? "assert_"
      property = method.to_s.split('assert_')[1]
      begin
        if eval("self.class.method_defined? '#{property}_is?'")
          actual = eval "#{property}_is?('#{@data[property]}')"
        else
          actual = eval "#{property}()"
        end
      rescue NoMethodError => e
        actual = "NoMethodError"
      rescue Exception => e
        actual = "Exception: " + e.class.to_s # + "\\n" +  e.message.gsub!(/"/, "'").gsub!(/\n/, "\\n")
      end
      if [TrueClass, FalseClass].include?(actual.class)
        if actual
          log_success property, @data[property]
        else
          log_failure property, @data[property], actual
        end
      elsif actual == @data[property]
        log_success property, @data[property]
      elsif actual == "NoMethodError"
        log_skipped property, @data[property]
      else
        log_failure property, @data[property], actual
      end
    else
      super
    end
  end

end # module
end # module
end # module
