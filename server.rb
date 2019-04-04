require 'sinatra'
require 'twilio-ruby'
require 'faraday'

MY_NUMBER = 'whatsapp:+14155238886'

get '/' do
  send_file 'index.html'
end

post '/' do
  conversation = Conversation.new(params[:From])
  
  unless params[:Body].match(/^[a-z0-9]+$/i)
    conversation.send_message('👌🏼')
    return
  end

  response = Api.get "/v1/properties/code/#{params[:Body]}"

  if response.success?
    conversation.send_message('¡Hola! A continuación te enviamos la información del apartamento que buscas')
    
    data = JSON.parse(response.body)
    conversation.send_message("https://app.holaemma.co/properties/#{data['id']}")

    conversation.send_message('Déjanos tus datos si deseas agendar una cita')
  end
end

class Conversation
  @@client = Twilio::REST::Client.new(ENV.fetch('ACCOUNT_SID'), ENV.fetch('AUTH_TOKEN'))

  def initialize(to)
    @to = to
  end

  def send_message(body)
    @@client.messages.create(
      from: MY_NUMBER,
      body: body,
      to: @to
    )
  end
end

class Api
  @@conn = Faraday.new(url: 'https://api.holaemma.co')

  def self.get(*args)
    @@conn.get(*args)
  end
end
