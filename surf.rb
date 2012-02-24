class Surf < Sinatra::Base
  DB = SQLite3::Database.new( "surf_reports.db" )
  set :erb, :format => :html5
  
  get "/" do
    last_report = DB.execute("SELECT * FROM surf_reports ORDER BY created_at DESC LIMIT 1").first
    @spot = last_report[0]
    @height = last_report[1]
    erb :index
  end
end