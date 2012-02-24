class Surf < Sinatra::Base
  DB = SQLite3::Database.new( "surf_reports.db" )
  set :erb, :format => :html5
  
  get "/" do
    @last_report = DB.execute("SELECT * FROM surf_reports ORDER BY created_at DESC LIMIT 1").first
    erb :index
  end
end