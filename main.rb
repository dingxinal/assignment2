require 'sinatra'
require 'sass'
require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/student.db")

class Student 
	include DataMapper::Resource
	property :id, Serial
	property :firstname, String
	property :lastname, String
	property :birthday, Date
	property :address, Text
	property :age, Integer
end

class Comment 
	include DataMapper::Resource
	property :id, Serial
	property :content, Text
	property :user, String
	property :created_at, DateTime
end

DataMapper.finalize
DataMapper.auto_upgrade!

configure do 
	enable :sessions
	set :username, "admin"
	set :password, "admin"

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
	if session[:admin]
		erb :new_student
	else
		redirect '/login'
	end
end

post '/students/new' do
	@newstudent = Student.new(
      :firstname      => params[:firstname],
      :lastname       => params[:lastname],
      :birthday => params[:birthday],
	  :age => params[:age],
	  :address => params[:address]
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
				 :lastname => params[:lastname],
				 :birthday => params[:birthday],
				 :age => params[:age],
				 :address => params[:address]
	redirect "/students/#{params[:id]}"
end

delete '/students/:id' do
	@foos = Student.all(:id => params[:id]).first
	@foos.destroy
	redirect "/students"
end

get '/students/:id/edit' do
	if session[:admin] 
		@foos = Student.all(:id => params[:id]).first
		erb :edit
	else 
		redirect '/login'
	end
end


get '/contact' do
	erb :contact
end

get '/video' do
	erb :video
end

get '/about' do
	erb :about
end

get '/comment' do
	@comments = Comment.all
	erb :comment
end

get '/comment/new' do
	erb :comment_new

end

post '/comment/new' do
	@comment = Comment.new(
		:content => params[:content],
		:user => (params[:user] ||session[:user]),
		:created_at => Time.now
		)
	if @comment.save
    redirect "/comment"
    else
    redirect "/comment/new"
  	end
end

get '/comment/:id' do
	@foos = Comment.all(:id => params[:id]).first
	erb :show_comment
end

get '/login' do
	erb :login
end

post '/login' do
	if params[:username] == settings.username &&
		params[:password] == settings.password
		session[:admin] = true
		#session[:user] = params[:username]
		redirect '/'
	else
		redirect '/login'
	end
end

get '/logout' do
	session.clear
	"logging out.."
	redirect '/'
end

helpers do 
	def message
		"hello #{session[:name]}, you have visited #{session[:visit]} times "

	end
end 

not_found do 
	erb :notfound, :layout=>false
end


