#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

 def get_db 
  return SQLite3::Database.new 'barbershop.db'
end

configure do
    db = get_db
    db.execute 'CREATE TABLE IF NOT EXISTS 
      "Users" 
      (
            "id" INTEGER PRIMARY KEY AUTOINCREMENT, 
            "username" TEXT, 
            "phone" TEXT, 
            "datestamp" TEXT, 
            "barber" TEXT, 
            "color" TEXT)'
  end

   


get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do
  @error = 'something wrong!!!'
  erb :about
end

get '/visit' do
  erb :visit
end

post '/visit' do
  # user_name, phone, date_time
  @username = params[:username]
  @phone = params[:phone]
  @date_time = params[:datetimepicker]
  @barber = params[:barber]
  @color = params[:color]

  hh = {:username => 'Введите имя', 
        :phone => 'Введите номер телефона', 
        :datetimepicker => 'Неправильная дата и время' }

@error = hh.select {|key,_| params[key] == ""}.values.join(", ")

  if @error != ''
    return erb :visit
  end


 db = get_db
 db.execute 'INSERT INTO Users (username, phone, datestamp, barber, color) 
 VALUES (?, ?, ?, ?, ?)', [@username, @phone, @date_time, @barber, @color]

  @title = "Спасибо!"
  @message = "Уважаемый #{@username}, мы ждём вас #{@date_time}. Ваша парикмахер #{@barber}, цвет окраски #{@color}"

  erb :message
end

get '/contacts' do
  erb :contacts
end

post '/contacts' do
  @email = params[:email]
  @userstext = params[:userstext]

  hh1 = {:email => 'Введите email', :userstext => 'Введите текст'}

  @error = hh1.select {|key,_| params[key] == ""}.values.join(", ")

  if @error != ''
    return erb :contacts
  end

  @title = "Спасибо!"
  @message = "Ваше сообщение принято"

  # запишем в файл то, что ввёл клиент
  f = File.open './public/contacts.txt', 'a'
  f.write "Email: #{@email}, сообщение: #{@userstext}\n"
  f.close
  erb :message

end

configure do
  enable :sessions
end

helpers do
  def login
    session[:identity] ? session[:identity] : 'Вход в систему'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb :login
  end
end

get '/' do
  erb 'Can you handle a <a href="/secure/place">пароль</a>?'
end

get '/admin' do
  erb :admin
end

post '/admin' do
  session[:identity] = params['login']
  session[:identity] = params['password']
    @login = params[:login]
	@password = params[:password]
	if @login == 'admin' && @password == "secret"
		 	 where_user_came_from = session[:previous_url] || '/'
 			 redirect to where_user_came_from
	else
		@report = '<p>Доступ запрещён! Неправильный логин или пароль.</p>'
		erb :admin
	end
 
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Вы вышли из системы</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end