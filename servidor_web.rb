require 'uri'

class ServidorWeb

  # Construtor da classe. Recebe como parâmetro o socket e a requisição
  def initialize(socket, requisicao)
    @socket = socket
    @requisicao = requisicao
  end

  RAIZ_WEB = './publico'

  # Hash que armazena os tipo de arquivos suportados pelo servidor
  TIPOS_CONTEUDO = {
    'html' => 'text/html',
    'txt' =>  'text/plain',
    'png' =>  'image/png',
    'jpg' =>  'image/jpeg'
  }

  TIPO_CONTEUDO_PADRAO = 'application/actet-stream' # Tipo binário

  # Retorna a extensão do arquivo sem o '.', exemplo: obter_tipo_conteudo('foto.jpg') => 'jpg'
  def obter_tipo_conteudo(caminho)
    extensao = File.extname(caminho).split(".")[1]
    TIPOS_CONTEUDO.fetch(extensao, TIPO_CONTEUDO_PADRAO)
  end

  # Retorno caminho completo do arquivo requisitado com a raiz do servidor, exemplo: ./publico/index.html
  def arquivo_requisitado(requisicao)
    uri_requisitada = requisicao.split(" ")[1]
    caminho = URI.unescape(URI(uri_requisitada).path)
    caminho_limpo = []

    # Mecanismo de seguraça para impedir acessar diretório acima do diretório público
    partes = caminho.split('/')

    partes.each do |parte| 
      next if parte.empty? || parte == '.'
      parte == '..' ? caminho_limpo.pop : caminho_limpo << parte
    end
    File.join(RAIZ_WEB, caminho_limpo)
  end

  # Método principal que faz toda a magia
  def servir
    @caminho = arquivo_requisitado(@requisicao) 
    @caminho = File.join(@caminho, 'index.html') if File.directory?(@caminho)

    if File.exists?(@caminho) && !File.directory?(@caminho)
      File.open(@caminho, "rb") do |arquivo| # Abre o arquivo @caminho e joga para variável arquivo(aberto)
        @socket.print "HTTP/1.1 200 OK\r\n"+ # Método print escreve no socket
                     "Server: MiniServidorWeb\r\n"+
                     "Content-Type: #{obter_tipo_conteudo(arquivo)}; charset=utf-8\r\n"+
                     "Content-Length: #{arquivo.size}\r\n"+
                     "Connection: close\r\n"    

        @socket.print "\r\n"
        IO.copy_stream(arquivo, @socket) # Copia os bytes do arquivo no socket
        arquivo.close # Fecha arquivo              
      end
    else # Caso não exista o arquivo retorna 404
      mensagem = "Arquivo não encontrado!(404 Not Found)\n"
      @socket.print "HTTP/1.1 404 Not Found\r\n"+
                   "Server: MiniServidorWeb\r\n"+
                   "Content-Type: text/plain; charset=utf-8\r\n"+
                   "Content-Length: #{mensagem.size}\r\n"
                   "Connection: close\r\n"

      @socket.print "\r\n"
      @socket.print mensagem
    end
    @socket.close # Fecha o socket
  end

end