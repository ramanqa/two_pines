module TwoPines
module Reporter

  def self.init_reporter
     FileUtils.rm_rf("./report/images", secure: true)
     FileUtils.mkdir_p "./report/images"
     Zip::File.open(__dir__ + '/assets/reveal.js.zip') do |zip_file|
      zip_file.each do |f|
        zip_file.extract(f, "./report/#{f.name}") unless File.exist? "./report/#{f.name}"
      end
     end
     File.delete("./report/slides.js") if File.exists?("./report/slides.js")
     FileUtils.cp __dir__ + '/assets/index.html', './report/index.html'
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
      f.puts "\nhtml=\"<h3>#{section}:#{node_data['title']}</h3>\";"
    end
  end

  def finalize_report custom_reporter=nil
    File.open './report/slides.js', 'a' do |f|
      f.puts "e.innerHTML=html;"
      f.puts "document.querySelector('.slides').appendChild(e);"
    end
    if custom_reporter != nil
      custom_reporter.write_results @item_report
    end
  end

  def log_failure property, expected, actual
    puts "Fail: #{property} | expected: #{expected} | actual: #{actual}"
    result = Hash.new
    result['status'] = "FAIL"
    result['property'] = property
    result['expected'] = expected
    result['actual'] = actual
    @item_report['results'].push result
    file_name = "#{Time.now.to_f}.png"
    $browser.save_screenshot("./report/images/#{file_name}")
    File.open './report/slides.js', 'a' do |f|
      f.puts "e.setAttribute('data-background','#ff9977');"
      f.puts "html += \"<div class='assertion fail' style='text-align:left;'>\";"
      f.puts "html += \"<img src='./reveal.js/fail.png' style='border:0;height:30px;margin:0;'/>\";"
      f.puts "html += \"<strong>#{property}:</strong>&nbsp;#{expected}\";"
      f.puts "html += \"<a href='images/#{file_name}' target='_blank'><img src='images/#{file_name}' style='border:0;height:100px;margin:0;'/></a>\";"
      f.puts "html += \"<pre style='font-size:0.3em;'><code>Expected: #{expected}\\nActual: #{actual}</code></pre>\";"
      f.puts "html += \"</div>\";"
    end
  end


  def log_success property, actual
    puts "Pass: #{property} | actual: #{actual}"
    result = Hash.new
    result['status'] = "PASS"
    result['property'] = property
    result['expected'] = actual
    result['actual'] = actual
    @item_report['results'].push result

    File.open './report/slides.js', 'a' do |f|
      f.puts "html += \"<div class='assertion pass' style='text-align:left;'>\";"
      f.puts "html += \"<img src='./reveal.js/pass.png' style='border:0;height:30px;margin:0;'/>\";"
      f.puts "html += \"<strong>#{property}:</strong>&nbsp; #{actual}\";"
      f.puts "html += \"</div>\";"
    end
  end

end # module
end # module
