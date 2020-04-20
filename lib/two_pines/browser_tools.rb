require 'zip'
require 'rest-client'

module TwoPines
class BrowserTools

  attr_accessor :browserDebugUrl, :apiPort, :browserToolsPid, :sniff_threads
  
  def initialize browserDebugUrl="http://localhost:9000", apiPort=9901
    @apiPort = apiPort
    init_js
    @browserToolsPid = fork do
      exec "npm --prefix js/browser_tools start -- --port=#{apiPort} --browserDebugUrl=#{browserDebugUrl}"
    end
    puts "Browser Tools Thread PID: #{browserToolsPid}"
    @sniff_threads = Hash.new
  end

  def kill
    Process.kill "SIGHUP", @browserToolsPid
  end

  def save_screenshot filename
    begin
      base64 = RestClient.get "http://localhost:#{@apiPort}/screenshot"
      File.open(filename, 'wb') do |f|
        f.write(Base64.decode64(base64))
      end
    rescue
    end
  end

  def set_sniff sniffPath
    sniff_thread = Hash.new
    sniff_thread['thread'] = Thread.new do
      sniff_thread['response'] = RestClient.post("http://localhost:#{@apiPort}/sniff", {"url":sniffPath}.to_json, {content_type: :json}).body
    end
    @sniff_threads[sniffPath] = sniff_thread
  end

  def get_sniff sniffPath
    if @sniff_threads[sniffPath]['thread'].status == false
      return @sniff_threads[sniffPath]['response']
    end
    false
  end

  def init_js
    puts "Setting up browser tools"
    FileUtils.rm_rf("./js", secure: true)
    FileUtils.mkdir_p "./js"
    Zip::File.open __dir__ + "/js/browser_tools.zip" do |zip_file|
      zip_file.each do |f|
        begin
          zip_file.extract f, "./js/#{f.name}"
        rescue Zip::DestinationFileExistsError
        end
      end
    end
    system "npm --prefix js/browser_tools install"
    puts "done."
  end

end # class
end # module
