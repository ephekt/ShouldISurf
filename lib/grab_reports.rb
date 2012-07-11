## GrabReports -- Surfline Parser
%w(rubygems bundler open-uri).each { |resource| require resource }
Bundler.require

## SAVE FOR LATER
# santa cruz: http://www.surfline.com/surf-forecasts/central-california/santa-cruz_2958
# http://www.surfshot.com/
# http://forecasts.swellwatch.com/#place=36.910372213522535_-122.02446000000002_11_1534_height_SurfSpot_Sat_-1

##  DATABASE SETUP

puts "Loaded report grabber"

DB = SQLite3::Database.new( "surf_reports.db" )

DB.execute("CREATE TABLE IF NOT EXISTS `surf_reports` (
    `location` varchar(128) NOT NULL,
    `height` varchar(256) NOT NULL,
    `tide` varchar(256) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )")

## SOME HELPER METHODS

def puts msg
  super("#{Time.now.strftime('%Y-%m-%d %l %p')} :: #{msg}")
end

def grab_page url
  raise unless url
  Typhoeus::Request.get(url).body
end

def text noko, matcher
  val = noko.xpath(matcher).first.inner_text rescue ''
  
  if val.empty?
    nil
  else
    val.gsub("'","''")
  end
end

## SURF SPOTS

surf_spots = {
  "Capitola" => "10763",
  "Pleasure Point" => "4190",
  "38th Ave" => "4191",
  "Steamer Lane" => "4188" ,
  "Cowells" => "4189",
  "Ocean Beach (SF)" => "4127",
  "S. Ocean Beach (SF)" => "4128"
}

## FETCHER

surf_spots.each do |spot,spot_id|
  begin
    url = "http://www.surfline.com/widgets2/widget_camera_mods.cfm?id=#{spot_id}&mdl=0111&ftr=&units=e&lan=en"
    n = Nokogiri::HTML(grab_page(url))

    height = text(n,"//span[@style='font-size:21px;font-weight:bold']") ||
          text(n,"//div[@style='font-size:12px;padding-left:10px;margin-bottom:7px;']") ||
          "Report Not Available"
    
    tides = n.xpath("//div//small[contains(text(),'TIDES')]").first.parent
    tide = tides.text.gsub("\u00A0\u00A0\u00A0"," ").scan(/\d(.*?)\n/).join(",")
  rescue Exception => e
    puts "Tried to parse & grab report for #{spot} but failed -- #{e}"
    next
  end
  
  q = "insert into `surf_reports` (location,height,tide) VALUES ('#{spot}','#{height}','#{tide}');"
  puts q
  begin
    DB.execute q
  rescue Exception => e
    puts e.inspect
  end
end

puts "FIN"

