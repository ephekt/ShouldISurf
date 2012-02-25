class Surf < Sinatra::Base
  DB = SQLite3::Database.new( "surf_reports.db" )
  set :erb, :format => :html5
  
  get "/" do
    q = "
      SELECT * FROM surf_reports 
      WHERE location IN ('Capitola','Pleasure Point', '38th Ave')
      GROUP BY location
      ORDER BY created_at DESC
    "
    @latest_reports = DB.execute q
    erb :index
  end
end