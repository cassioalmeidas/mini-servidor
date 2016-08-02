require 'socket' # Faz o 'import' dos módulos
require './servidor_web.rb'

HOST = 'localhost'
PORTA = 2323

# Cria um objeto TCPServer, que implementa sockets da classe Socket
servidor = TCPServer.new(HOST, PORTA)

# Apenas exibe no terminal
puts "Servidor rodando em http://#{HOST}:#{PORTA}"

loop do # loop infinito, ou seja, o servidor vai ficar rodando até o processor ser interrompido
  socket = servidor.accept # Fica esperando por uma requisição e retorna um objeto do tipo socket
  requisicao = socket.gets # Retorna as linha de requisição

  puts requisicao # Exibe no terminal a requisição feita
  puts Time.now # Exibe no terminal a data e hora atual

  # Criar thread em ruby(em modo usuário)
  Thread.start(socket, requisicao) do |s, r|
    ServidorWeb.new(s, r).servir # Instancia um objeto e chama o método servir()
  end
end