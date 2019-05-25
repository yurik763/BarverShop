#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'


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
  @barber = params[:baber]
  @username = params[:username]
  @phone = params[:phone]
  @date_time = params[:date_time]
  @color = params[:color]

  hh = {:username => 'Введите имя', 
        :phone => 'Введите номер телефона', 
        :date_time => 'Неправильная дата и время' }

  #для каждой пыры ключ-значение
 # hh.each do |key,value|
 #     if params[key] == ''
        # переменной error присвоить value из хеша hh
        # (а value из хеша присовить сообщение об ошибке)
#        @error = hh[key]
        #вернуть предтавление visit
#        return erb :visit
#      end
#  end

@error = hh.select {|key,_| params[key] == ""}.values.join(", ")

  if @error != ''
    return erb :visit
  end


  @title = "Спасибо!"
  @message = "Уважаемый #{@username}, мы ждём вас #{@date_time}. Ваша парикмахер #{@barber}, цвет окраски #{@color}"

  # запишем в файл то, что ввёл клиент
  f = File.open './public/users.txt', 'a'
  f.write "Имя: #{@username}, телефон: #{@phone}, дата и время: #{@date_time}. Парикмахер: #{@barber}, цвет окраски #{@color}\n"
  f.close

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