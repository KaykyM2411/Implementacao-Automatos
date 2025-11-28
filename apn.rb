class Pilha
  def initialize(simbolo_inicial = 'Z0')
    @dados = [simbolo_inicial]
  end

  def empilhar(simbolos_a_empilhar)
    simbolos_a_empilhar.reverse.each do |simbolo|
      @dados.push(simbolo) unless simbolo == 'epsilon'
    end
  end

  def desempilhar
    @dados.pop
  end

  def topo
    @dados.last
  end

  def vazia?
    # Considera vazia se restar apenas o símbolo inicial Z0
    @dados.size == 1 && @dados.first == 'Z0'
  end

  def to_s
    @dados.reverse.join(' | ')
  end

  def self.clone(pilha_original)
      Pilha.new.tap { |p| p.instance_variable_set(:@dados, pilha_original.instance_variable_get(:@dados).dup) }
  end
end

# Função para gerar um hash único para cada caminho (estado, fita, pilha), crucial para não-determinismo
def hash_caminho(caminho)
  pilha_data = caminho[:pilha].instance_variable_get(:@dados).join('|')
  fita_str = caminho[:fita].join
  "#{caminho[:estado]}::#{fita_str}::#{pilha_data}"
end

## --- ENTRADAS DO APN ---

puts("Informe o conjunto de estados (separados por vírgula): ")
estados = gets.chomp.split(",").map(&:strip)

puts("Informe o conjunto de símbolos de entrada (separados por vírgula): ")
simbolos_entrada = gets.chomp.split(",").map(&:strip)

puts("Informe o conjunto de símbolos da pilha (separados por vírgula): ")
simbolos_pilha = gets.chomp.split(",").map(&:strip)

puts("Informe o estado inicial: ")
estado_inicial = gets.chomp.strip

puts("Informe o símbolo inicial da pilha (Z0): ")
simbolo_inicial_pilha = gets.chomp.strip

puts("Informe o conjunto de estados finais (separados por vírgula): ")
estados_finais = gets.chomp.split(",").map(&:strip)

puts("Informe a cadeia de entrada: ")
cadeia_entrada = gets.chomp.strip

puts("\n--- Defina as Funções de Transição (Separe múltiplos destinos com ';') ---")
puts("Formato da Transição: (estado_origem, simbolo_entrada, topo_pilha) -> (estado_destino, string_a_empilhar)")
puts("Use 'lambda' para símbolo de entrada ou 'epsilon' para empilhamento/desempilhamento.")

func_transicao = {}

loop do
  puts("\nNova Transição (ou 'fim' para terminar):")
  origem = gets.chomp.strip
  break if origem.downcase == 'fim'

  puts("Simbolo de Entrada (a ou lambda):")
  simbolo_a = gets.chomp.strip

  puts("Símbolo do Topo da Pilha (Z):")
  simbolo_z = gets.chomp.strip

  puts("Estado(s) e Pilha(s) de Destino (Formato: p1,gamma1; p2,gamma2;... Use 'epsilon' para desempilhar/vazio):")
  destinos_str = gets.chomp.strip

  chave = [origem, simbolo_a, simbolo_z]

  destinos = destinos_str.split(';').map do |d|
    parts = d.split(',').map(&:strip)
    # Rejeita strings vazias para 'epsilon'
    [parts[0], parts[1].split('').reject(&:empty?)]
  end

  func_transicao[chave] = destinos
end

## --- INÍCIO DA SIMULAÇÃO ---

puts("\n" + "=" * 50)
puts("INÍCIO DA SIMULAÇÃO DO APN")
puts("=" * 50)

caminho_inicial = {
  estado: estado_inicial,
  fita: cadeia_entrada.chars,
  pilha: Pilha.new(simbolo_inicial_pilha)
}

caminhos_ativos = [caminho_inicial]
# Usado para rastrear caminhos no lambda-fecho e evitar ciclos
caminhos_vistos = { hash_caminho(caminho_inicial) => true }

loop do
  # 1. APLICAÇÃO DO LAMBDA-FECHO (Epsilon Closure)
  pilha_processamento = caminhos_ativos.dup
  caminhos_ativos = []

  while !pilha_processamento.empty?
    caminho_lambda = pilha_processamento.shift
    caminhos_ativos << caminho_lambda

    topo_pilha = caminho_lambda[:pilha].topo
    lambda_chave = [caminho_lambda[:estado], 'lambda', topo_pilha]

    if func_transicao.key?(lambda_chave)
      func_transicao[lambda_chave].each do |novo_estado, simbolos_a_empilhar|

        nova_pilha = Pilha.clone(caminho_lambda[:pilha])

        nova_pilha.desempilhar
        nova_pilha.empilhar(simbolos_a_empilhar)

        novo_caminho = {
          estado: novo_estado,
          fita: caminho_lambda[:fita].dup,
          pilha: nova_pilha
        }

        h_novo = hash_caminho(novo_caminho)

        if !caminhos_vistos.key?(h_novo)
          caminhos_vistos[h_novo] = true
          pilha_processamento << novo_caminho
        end
      end
    end
  end

  # 2. Verifica condição de parada
  if caminhos_ativos.empty?
    puts("\n❌ Todos os caminhos de execução pararam após o lambda-fecho.")
    break
  end

  # 3. Consome um símbolo de entrada (se houver)
  # O próximo símbolo é o mesmo para todos os caminhos, pois todos estão no mesmo ponto da fita
  proximo_simbolo = caminhos_ativos.first[:fita].first

  if proximo_simbolo.nil?
    puts("\n✅ Fim da Fita de Entrada. Verificando aceitação...")
    break
  end

  puts("\nProcessando Símbolo: **#{proximo_simbolo}**")

  novos_caminhos = []
  caminhos_vistos = {} # Reinicia o hash de vistos para a próxima fase

  # 4. PROCESSA O SÍMBOLO DE ENTRADA
  
  # Clonamos os caminhos para ler, permitindo a modificação (shift) da fita em cada um.
  caminhos_para_ler = caminhos_ativos.map { |c| 
    { estado: c[:estado], fita: c[:fita].dup, pilha: Pilha.clone(c[:pilha]) }
  }

  caminhos_para_ler.each_with_index do |caminho, i|
    simbolo_lido = caminho[:fita].shift # Consome o símbolo
    topo_pilha = caminho[:pilha].topo

    puts("  Caminho #{i+1}: Estado #{caminho[:estado]}, Topo #{topo_pilha}")

    chave = [caminho[:estado], simbolo_lido, topo_pilha]

    if func_transicao.key?(chave)
      func_transicao[chave].each do |novo_estado, simbolos_a_empilhar|

        nova_pilha = Pilha.clone(caminho[:pilha])

        nova_pilha.desempilhar # Pop
        nova_pilha.empilhar(simbolos_a_empilhar) # Push

        novo_caminho = {
          estado: novo_estado,
          fita: caminho[:fita].dup,
          pilha: nova_pilha
        }

        h_novo = hash_caminho(novo_caminho)

        if !caminhos_vistos.key?(h_novo)
          caminhos_vistos[h_novo] = true
          novos_caminhos << novo_caminho
          puts("    -> Destino: Estado #{novo_estado}, Pilha: #{simbolos_a_empilhar.empty? ? 'POP' : 'PUSH('+simbolos_a_empilhar.join('')+')'}")
        end
      end
    else
      puts("    -> SEM TRANSIÇÃO. Caminho morto.")
    end
  end

  caminhos_ativos = novos_caminhos
end

## --- VERIFICAÇÃO DE ACEITAÇÃO ---

aceitacao_final = false

caminhos_ativos.each do |caminho|
  # 1. Aceitação por Estado Final
  if caminho[:fita].empty? && estados_finais.include?(caminho[:estado])
    puts("\n  ACEITO (Estado Final): Fita vazia no estado **#{caminho[:estado]}**.")
    aceitacao_final = true
    break
  end

  # 2. Aceitação por Pilha Vazia
  if caminho[:fita].empty? && caminho[:pilha].vazia?
    puts("\n  ACEITO (Pilha Vazia): Fita vazia e pilha vazia.")
    aceitacao_final = true
    break
  end
end

puts("\n" + "=" * 50)
if aceitacao_final
  puts("A CADEIA FOI ACEITA pelo APN.")
else
  puts("A CADEIA NÃO FOI ACEITA pelo APN.")
end
puts("=" * 50)