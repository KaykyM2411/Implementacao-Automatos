class Fita
  def initialize(cadeia_entrada = '', simbolo_branco = 'B')
    @simbolo_branco = simbolo_branco
    @dados = cadeia_entrada.chars
    @posicao = 0
    
    # Garante que há pelo menos um símbolo na fita
    @dados << @simbolo_branco if @dados.empty?
  end

  def ler
    @dados[@posicao] || @simbolo_branco
  end

  def escrever(simbolo)
    @dados[@posicao] = simbolo
  end

  def mover(direcao)
    case direcao
    when 'D', 'R' # Direita
      @posicao += 1
      # Expande a fita se necessário
      @dados << @simbolo_branco if @posicao >= @dados.length
    when 'E', 'L' # Esquerda
      if @posicao == 0
        # Expande a fita para esquerda
        @dados.unshift(@simbolo_branco)
      else
        @posicao -= 1
      end
    when 'S' # Parado (Stay)
      # Não move
    end
  end

  def posicao_atual
    @posicao
  end

  def to_s
    # Mostra a fita com destaque para a posição atual
    resultado = ""
    @dados.each_with_index do |simbolo, idx|
      if idx == @posicao
        resultado += "[#{simbolo}]"
      else
        resultado += " #{simbolo} "
      end
    end
    resultado
  end

  def conteudo
    @dados.join
  end

  def self.clone(fita_original)
    nova_fita = Fita.new
    nova_fita.instance_variable_set(:@dados, fita_original.instance_variable_get(:@dados).dup)
    nova_fita.instance_variable_set(:@posicao, fita_original.instance_variable_get(:@posicao))
    nova_fita.instance_variable_set(:@simbolo_branco, fita_original.instance_variable_get(:@simbolo_branco))
    nova_fita
  end
end

# Função para gerar um hash único para cada configuração (estado, fita)
def hash_configuracao(configuracao)
  fita_str = configuracao[:fita].conteudo
  posicao = configuracao[:fita].posicao_atual
  "#{configuracao[:estado]}::#{fita_str}::#{posicao}"
end


puts("Informe o conjunto de estados (separados por vírgula): ")
estados = gets.chomp.split(",").map(&:strip)

puts("Informe o alfabeto de entrada (separados por vírgula): ")
alfabeto_entrada = gets.chomp.split(",").map(&:strip)

puts("Informe o alfabeto da fita (separados por vírgula, inclua o símbolo branco): ")
alfabeto_fita = gets.chomp.split(",").map(&:strip)

puts("Informe o símbolo branco (padrão: B): ")
simbolo_branco = gets.chomp.strip
simbolo_branco = 'B' if simbolo_branco.empty?

puts("Informe o estado inicial: ")
estado_inicial = gets.chomp.strip

puts("Informe o estado de aceitação: ")
estado_aceitacao = gets.chomp.strip

puts("Informe o estado de rejeição: ")
estado_rejeicao = gets.chomp.strip

puts("Informe a cadeia de entrada: ")
cadeia_entrada = gets.chomp.strip

puts("\n--- Defina as Funções de Transição ---")
puts("Formato da Transição: (estado_origem, simbolo_lido) -> (estado_destino, simbolo_escrito, movimento)")
puts("Movimentos: D/direita, E/esquerda, S/parado")

func_transicao = {}

loop do
  puts("\nNova Transição (ou 'fim' para terminar):")
  origem = gets.chomp.strip
  break if origem.downcase == 'fim'

  puts("Símbolo a ser lido:")
  simbolo_lido = gets.chomp.strip

  puts("Estado de destino:")
  estado_destino = gets.chomp.strip

  puts("Símbolo a ser escrito:")
  simbolo_escrito = gets.chomp.strip

  puts("Movimento (D-direita, E-esquerda, S-parado):")
  movimento = gets.chomp.strip.upcase

  chave = [origem, simbolo_lido]
  func_transicao[chave] = [estado_destino, simbolo_escrito, movimento]
end


puts("\n" + "=" * 60)
puts("INÍCIO DA SIMULAÇÃO DA MÁQUINA DE TURING")
puts("=" * 60)

configuracao_inicial = {
  estado: estado_inicial,
  fita: Fita.new(cadeia_entrada, simbolo_branco)
}

configuracoes_ativas = [configuracao_inicial]
configuracoes_vistas = { hash_configuracao(configuracao_inicial) => true }

passo = 0
aceita = false
rejeita = false

loop do
  passo += 1
  puts("\n--- Passo #{passo} ---")
  
  # Verifica condições de parada
  configuracoes_ativas.each do |config|
    if config[:estado] == estado_aceitacao
      puts("ESTADO DE ACEITAÇÃO ALCANÇADO!")
      aceita = true
      break
    elsif config[:estado] == estado_rejeicao
      puts("ESTADO DE REJEIÇÃO ALCANÇADO!")
      rejeita = true
      break
    end
  end

  break if aceita || rejeita || configuracoes_ativas.empty?

  novas_configuracoes = []
  configuracoes_vistas = {}

  # Processa cada configuração ativa
  configuracoes_ativas.each_with_index do |config, i|
    simbolo_lido = config[:fita].ler
    estado_atual = config[:estado]
    
    puts("Configuração #{i+1}:")
    puts("  Estado: #{estado_atual}")
    puts("  Fita: #{config[:fita]}")
    puts("  Símbolo lido: #{simbolo_lido}")

    chave = [estado_atual, simbolo_lido]

    if func_transicao.key?(chave)
      estado_destino, simbolo_escrito, movimento = func_transicao[chave]
      
      puts("  Transição: (#{estado_atual}, #{simbolo_lido}) -> (#{estado_destino}, #{simbolo_escrito}, #{movimento})")

      nova_fita = Fita.clone(config[:fita])
      nova_fita.escrever(simbolo_escrito)
      nova_fita.mover(movimento)

      nova_configuracao = {
        estado: estado_destino,
        fita: nova_fita
      }

      h_novo = hash_configuracao(nova_configuracao)

      if !configuracoes_vistas.key?(h_novo)
        configuracoes_vistas[h_novo] = true
        novas_configuracoes << nova_configuracao
      end
    else
      puts(" SEM TRANSIÇÃO DEFINIDA. Configuração rejeitada.")  
      # Se não há transição, considera como rejeição
      if estado_atual != estado_rejeicao
        nova_configuracao = {
          estado: estado_rejeicao,
          fita: config[:fita]
        }
        novas_configuracoes << nova_configuracao
      end
    end
  end

  configuracoes_ativas = novas_configuracoes

  # Limite de passos para evitar loop infinito
  if passo > 1000
    puts("\n LIMITE DE PASSOS EXCEDIDO (1000 passos)")
    break
  end
end


puts("\n" + "=" * 60)
if aceita
  puts("RESULTADO FINAL: A CADEIA FOI ACEITA!")
  puts("Configuração final de aceitação:")
  config_aceita = configuracoes_ativas.find { |c| c[:estado] == estado_aceitacao }
  puts("  Estado: #{config_aceita[:estado]}")
  puts("  Fita: #{config_aceita[:fita]}")
elsif rejeita
  puts("RESULTADO FINAL: A CADEIA FOI REJEITADA!")
else
  puts("RESULTADO FINAL: MÁQUINA PAROU SEM DECISÃO")
end

# Mostra estatísticas finais
puts("\n--- ESTATÍSTICAS ---")
puts("Total de passos executados: #{passo}")
puts("Configurações distintas visitadas: #{configuracoes_vistas.size}")
puts("Conteúdo final da fita em todas as configurações:")
configuracoes_ativas.each_with_index do |config, i|
  puts("  Config #{i+1}: #{config[:fita]} (Estado: #{config[:estado]})")
end
puts("=" * 60)