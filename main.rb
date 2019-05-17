require 'sinatra'
require 'sass'
require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/student.db")
set :port, 1111

class Student 
	include DataMapper::Resource
	property :id, Serial
	property :firstname, String
	property :lastname, String
	property :birthday, Date
	property :address, Text
	property :age, Integer
end

DataMapper.finalize
DataMapper.auto_upgrade!

configure do 
	enable :sessions
end

get'/styles.css' do
	scss :styles
end

get '/' do
	if session[:name] 
		erb :view
	else
		erb :view
	end
end


get '/students' do
	@students = Student.all
	erb :students
end

get '/students/new' do
	erb :new_student
end

post '/students/new' do
	@newstudent = Student.new(
      :firstname      => params[:firstname],
      :lastname       => params[:lastname]
  )
	if @newstudent.save
    redirect "/students"
    else
    redirect "/students/new"
  	end
	
end

get '/students/:id' do
	@foos = Student.all(:id => params[:id]).first
	erb :show_student
end

post '/students/:id' do
	@foos = Student.all(:id => params[:id]).first
	@foos.update :firstname => params[:firstname],
				 :lastname => params[:lastname]
	redirect "/students/#{params[:id]}"
end

delete '/students/:id' do
	@foos = Student.all(:id => params[:id]).first
	@foos.destroy
	redirect "/students"
end

get '/students/:id/edit' do 
	@foos = Student.all(:id => params[:id]).first
	erb :edit
end


get '/contact' do
	erb :contact
	
end


get '/logout' do
	session.clear
	"logging out.."
end

helpers do 
	def message
		"hello #{session[:name]}, you have visited #{session[:visit]} times "

	end
end 

not_found do 
	erb :notfound, :layout=>false
end


