%w(rubygems bundler open-uri).each { |resource| require resource }
Bundler.require

def puts msg
  super("#{Time.now.strftime('%Y-%m-%d %l %p')} :: #{msg}")
end

def grab_page url
  raise unless url
  Nokogiri::HTML(open(url))
end

puts "Loaded report grabber"

DB = SQLite3::Database.new( "surf_reports.db" )
DB.execute("CREATE TABLE IF NOT EXISTS `surf_reports` (
    `location` varchar(32) NOT NULL,
    `height` varchar(256) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )")

# santa cruz: http://www.surfline.com/surf-forecasts/central-california/santa-cruz_2958
surf_spots = {
  "Capitola" => "http://www.surfline.com/surf-report/capitola-central-california_10763"
}

surf_spots.each do |spot,url|
  begin
    elem = grab_page(url).search("//p[@id = 'text-surfheight']").first.inner_text
    height = if elem.empty?
      "Not Available or too low to quantify"
    else
      elem.gsub("'","''")
    end
  rescue Exception => e
    puts "Tried to parse & grab report for #{sport} but failed -- #{e}"
    next
  end
    
  puts "Found height: #{height}, writing to DB"
  q = "insert into `surf_reports` (location,height) VALUES ('#{spot}','#{height}');"
  puts q
  begin
    DB.execute q
  rescue Exception => e
    puts e.inspect
  end
end

puts "FIN"

