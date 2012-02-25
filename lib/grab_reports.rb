%w(rubygems bundler open-uri).each { |resource| require resource }
Bundler.require

def puts msg
  super("#{Time.now.strftime('%Y-%m-%d %l %p')} :: #{msg}")
end

def grab_page url
  raise unless url
  Typhoeus::Request.get(url).body
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
  "Capitola" => "http://www.surfline.com/surf-report/capitola-central-california_10763",
  "Pleasure Point" => "http://www.surfline.com/surf-report/pleasure-point-central-california_4190",
  "38th Ave" => "http://www.surfline.com/surf-report/38th-ave-central-california_4191",
  "Steamer Lane" => "http://www.surfline.com/surf-report/steamer-lane-central-california_4188" ,
  "Cowells" => "http://www.surfline.com/surf-report/cowells-central-california_4189",
  "Ocean Beach (SF)" => "http://www.surfline.com/surf-report/ocean-beach-central-california_4127",
  "S. Ocean Beach (SF)" => "http://www.surfline.com/surf-report/south-ocean-beach-central-california_4128"
}

surf_spots.each do |spot,url|
  height = "Not Available or too low to quantify"
  begin
    page = grab_page(url)
    if page.include? "text-surfheight"
      elem = Nokogiri::HTML(page).search("//p[@id = 'text-surfheight']").first
      height = elem.inner_text.gsub("'","''")
      puts "Found height: #{height}, writing to DB"
    else
      puts "No height found in report page"
    end
  rescue Exception => e
    puts "Tried to parse & grab report for #{spot} but failed -- #{e}"
    next
  end
    
  q = "insert into `surf_reports` (location,height) VALUES ('#{spot}','#{height}');"
  puts q
  begin
    DB.execute q
  rescue Exception => e
    puts e.inspect
  end
end

puts "FIN"

