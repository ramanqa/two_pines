require 'cgi'
require 'colorize'

module TwoPines
module Reporter

  def self.init_reporter
    puts "Setting up reports"
     FileUtils.rm_rf("./report/images", secure: true)
     FileUtils.mkdir_p "./report/images"
     Zip::File.open(__dir__ + '/assets/reveal.js.zip') do |zip_file|
      zip_file.each do |f|
        zip_file.extract(f, "./report/#{f.name}") unless File.exist? "./report/#{f.name}"
      end
     end
     File.delete("./report/slides.js") if File.exists?("./report/slides.js")
     FileUtils.cp __dir__ + '/assets/index.html', './report/index.html'
     FileUtils.cp __dir__ + '/assets/image.html', './report/image.html'
     puts "Done."
  end

  def init_report level_bct, node_data
   
    @item_report = Hash.new
    @item_report['item_data'] = node_data
    @item_report['results'] = Array.new

    # build section
    section = ""
    node_data['level'].to_i.times do |index|
      section += "#{level_bct[index]}."
    end
    section.delete_suffix! "."

    # print title with section
    File.open './report/slides.js', 'a' do |f|
      f.puts "e = document.createElement('section');"
      f.puts "html = \"<h3>#{CGI.escapeHTML(section.to_s)}:#{CGI.escapeHTML(node_data['title'].to_s)}</h3>\";"
      f.puts "html += \"<div style='height: 500px;overflow: auto;'>\";"
    end
  end

  def finalize_report custom_reporter=nil
    File.open './report/slides.js', 'a' do |f|
      f.puts "html += \"<div>\";"
      f.puts "e.innerHTML=html;"
      f.puts "document.querySelector('.slides').appendChild(e);"
    end
    if custom_reporter != nil
      custom_reporter.write_results @item_report
    end
  end

  def log_failure property, expected, actual, element=nil
    puts "Fail: #{property} | expected: #{expected} | actual: #{actual}".colorize(:red)
    result = Hash.new
    result['status'] = "FAIL"
    result['property'] = property
    result['expected'] = expected
    result['actual'] = actual
    @item_report['results'].push result
    file_name = "#{Time.now.to_f}.png"
    $browser.save_screenshot("./report/images/#{file_name}")
    if element
      h = element.size.height+20
      w = element.size.width+20
      x = element.location.x-10
      y = element.location.y-10
      image_page_href = "image.html?i=images/#{file_name}&h=#{h}&w=#{w}&x=#{x}&y=#{y}"
    end
    File.open './report/slides.js', 'a' do |f|
      f.puts "e.setAttribute('data-background','#ff9977');"
      f.puts "html += \"<div class='assertion fail' style='text-align:left;'>\";"
      f.puts "html += \"<img src='./reveal.js/fail.png' style='border:0;height:30px;margin:0;'/>\";"
      f.puts "html += \"<strong>#{CGI.escapeHTML(property.to_s)}:</strong>&nbsp;#{CGI.escapeHTML(expected.to_s).gsub(/\n/, '\n')}\";"
      if element
        f.puts "html += \"<a href='#{image_page_href}' target='_blank'><img src='images/#{file_name}' style='border:0;height:50px;margin:0;'/></a>\";"
      else
        f.puts "html += \"<a href='images/#{file_name}' target='_blank'><img src='images/#{file_name}' style='border:0;height:50px;margin:0;'/></a>\";"
      end
      f.puts "html += \"<pre style='font-size:0.3em;'><code>Expected: #{CGI.escapeHTML(expected.to_s).gsub(/\n/, '\n')}\\nActual: #{CGI.escapeHTML(actual.to_s).gsub(/\n/, '\n')}</code></pre>\";"
      f.puts "html += \"</div>\";"
    end
  end

  def log_skipped property, expected
    puts "Skipped: #{property} | expected: #{expected}".colorize(:yellow)
    result = Hash.new
    result['status'] = "SKIP"
    result['property'] = property
    result['expected'] = expected
    @item_report['results'].push result
    file_name = "#{Time.now.to_f}.png"
    $browser.save_screenshot("./report/images/#{file_name}")
    File.open './report/slides.js', 'a' do |f|
      f.puts "if(e.getAttribute('data-background') == null){"
      f.puts "  e.setAttribute('data-background','#ffdd77');"
      f.puts "}"
      f.puts "html += \"<div class='assertion fail' style='text-align:left;'>\";"
      f.puts "html += \"<img src='./reveal.js/skip.png' style='border:0;height:30px;margin:0;'/>\";"
      f.puts "html += \"<strong>#{CGI.escapeHTML(property.to_s).gsub(/\n/, '\n')}:</strong>&nbsp;#{CGI.escapeHTML(expected.to_s).gsub(/\n/, '\n')}\";"
      f.puts "html += \"<a href='images/#{file_name}' target='_blank'><img src='images/#{file_name}' style='border:0;height:50px;margin:0;'/></a>\";"
      f.puts "html += \"<pre style='font-size:0.3em;'><code>Expected: #{CGI.escapeHTML(expected.to_s).gsub(/\n/, '\n')}</code></pre>\";"
      f.puts "html += \"</div>\";"
    end
  end

  def log_success property, actual
    puts "Pass: #{property} | actual: #{actual}".colorize(:green)
    result = Hash.new
    result['status'] = "PASS"
    result['property'] = property
    result['expected'] = actual
    result['actual'] = actual
    @item_report['results'].push result

    File.open './report/slides.js', 'a' do |f|
      f.puts "html += \"<div class='assertion pass' style='text-align:left;'>\";"
      f.puts "html += \"<img src='./reveal.js/pass.png' style='border:0;height:30px;margin:0;'/>\";"
      f.puts "html += \"<strong>#{CGI.escapeHTML(property.to_s).gsub(/\n/, '\n')}:</strong>&nbsp; #{CGI.escapeHTML(actual.to_s).gsub(/\n/, '\n')}\";"
      f.puts "html += \"</div>\";"
    end
  end

end # module
end # module
