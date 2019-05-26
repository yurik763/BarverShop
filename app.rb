#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def is_barber_exists? db, param #существует ли парикмахер
  db.execute('SELECT * FROM Barber_option WHERE option=?', [param]).length > 0
end

def seed_db base, barber_option
  barber_option.each do |barber|
    if !is_barber_exists? @db, barber #парикмахер не существует выполнить то что ниже
      db.execute 'INSERT INTO Barber_option (option) VALUES (?)', [barber] #вставляет парикмаера в нашу базу данных
    end
  end
end

def get_db 
  @db = SQLite3::Database.new 'barbershop.db'
  @db.results_as_hash = true
  return @db
end

configure do
    db = get_db
    @db.execute 'CREATE TABLE IF NOT EXISTS 
      "Users" 
      (
            "id" INTEGER PRIMARY KEY AUTOINCREMENT, 
            "username" TEXT, 
            "phone" TEXT, 
            "datestamp" TEXT, 
            "barber" TEXT, 
            "color" TEXT)'

    @db.execute 'CREATE TABLE IF NOT EXISTS "Barber_option"
    (
      "id" INTEGER PRIMARY KEY AUTOINCREMENT,
      "option" TEXT
    )'

      seed_db @db, ['Jassie Pinkman', 'Walter White', 'Gus Fring', 'Mike Ehrmantraut']
  @db.close
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
  @date_time = params[:date_time]
  @barber = params[:barber]
  @color = params[:color]

  hh = {:username => 'Введите имя', 
        :phone => 'Введите номер телефона', 
        :date_time => 'Неправильная дата и время' }

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

get '/showusers' do
  get_db
  @results = @db.execute 'SELECT * FROM Users ORDER BY id DESC' #выводит таблицу и записывет результат в result
  
  erb :showusers  
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