require 'uri'

class ServidorWeb

  def initialize(socket, requisicao)
    @socket = socket
    @requisicao = requisicao
  end

  RAIZ_WEB = './publico'

  TIPOS_CONTEUDO = {
    'html' => 'text/html',
    'txt' => 'text/plain',
    'png' => 'image/png',
    'jpg' =>'image/jpeg'
  }

  TIPO_CONTEUDO_PADRAO = 'application/actet-stream'

  def obter_tipo_conteudo(caminho)
    extensao = File.extname(caminho).split(".")[1]
    TIPOS_CONTEUDO.fetch(extensao, TIPO_CONTEUDO_PADRAO)
  end

  def arquivo_requisitado(requisicao)
    uri_requisitada = requisicao.split(" ")[1]
    caminho = URI.unescape(URI(uri_requisitada).path)
    caminho_limpo = []

    partes = caminho.split('/')

    partes.each do |parte| 
      next if parte.empty? || parte == '.'
      parte == '..' ? caminho_limpo.pop : caminho_limpo << parte
    end
    File.join(RAIZ_WEB, caminho_limpo)
  end

  def servir
    @caminho = arquivo_requisitado(@requisicao) 
    @caminho = File.join(@caminho, 'index.html') if File.directory?(@caminho)

    if File.exists?(@caminho) && !File.directory?(@caminho)
      File.open(@caminho, "rb") do |arquivo|
        @socket.print "HTTP/1.0 200 OK\r\n"+
                     "Content-Type: #{obter_tipo_conteudo(arquivo)}\r\n"+
                     "Content-Length: #{arquivo.size}\r\n"+
                     "Connection: close\r\n"    

        @socket.print "\r\n"
        IO.copy_stream(arquivo, @socket)
        arquivo.close                   
      end
    else
      mensagem = "Arquivo não encontrado!\n"
      @socket.print "HTTP/1.1 404 Not Found\r\n"+
                   "Content-Type: text/plain; charset=utf-8\r\n"+
                   "Content-Length: #{mensagem.size}\r\n"
                   "Connection: close\r\n"

      @socket.print "\r\n"
      @socket.print mensagem
    end
    @socket.close
  end

end