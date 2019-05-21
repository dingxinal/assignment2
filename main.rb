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
	erb :view
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

# add new student
post '/students' do
	@newstudent = Student.new(
      :firstname      => params[:firstname],
      :lastname       => params[:lastname],
      :birthday => params[:birthday],
	  :age => params[:age],
	  :address => params[:address]
    )
    # if not saved successfully, redirect to the original page
	if @newstudent.save
    	redirect "/students"
    else
    	redirect "/students/new"
  	end
end

# get students's information bu id
get '/students/:id' do
	@foos = Student.all(:id => params[:id]).first
	erb :show_student
end

# update student's information
put '/students/:id' do
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
	# make sure content part is not empty
	if params[:content] != ""
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
		session[:user] = params[:username]
		redirect '/'
	else
		redirect '/login'
	end
end

get '/logout' do
	session.clear
	erb :logout
end

not_found do 
	erb :notfound
end


