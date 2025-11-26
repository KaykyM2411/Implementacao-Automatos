def transicao_afn(conjunto_estados, simbolo, func_transicao_afn)
  proximos_estados = []

  conjunto_estados.each do |estado|
    if func_transicao_afn.key?(simbolo) && func_transicao_afn[simbolo].key?(estado)
      proximos_estados.concat(func_transicao_afn[simbolo][estado])
    end
  end

  return proximos_estados.uniq.sort
end

puts("Informe o conjunto de estados do AFN (separados por vírgula): ")
estados_afn = gets.chomp.split(",").map(&:strip)

puts("Informe o conjunto de símbolos do alfabeto (separados por vírgula): ")
simbolos = gets.chomp.split(",").map(&:strip)

puts("Informe o estado inicial do AFN: ")
estado_inicial_afn = gets.chomp.strip

puts("Informe o conjunto de estados finais do AFN (separados por vírgula): ")
estados_finais_afn = gets.chomp.split(",").map(&:strip)

puts("--- Defina as Funções de Transição do AFN ---")
func_transicao_afn = {}

simbolos.each do |simbolo|
  func_transicao_afn[simbolo] = {}
  estados_afn.each do |estado|
    puts("De #{estado} com símbolo #{simbolo}, vá para qual(is) estado(s)? (Separe por vírgula ou '.' se não houver transição)")
    proximos_estados_str = gets.chomp.strip

    if proximos_estados_str.empty? || proximos_estados_str == "."
      func_transicao_afn[simbolo][estado] = []
    else
      func_transicao_afn[simbolo][estado] = proximos_estados_str.split(",").map(&:strip).reject(&:empty?)
    end
  end
end

puts("\n" + "=" * 50)
puts("INÍCIO DA CONVERSÃO AFN -> AFD")
puts("=" * 50)

estado_inicial_afd = [estado_inicial_afn]
estados_nao_processados = [estado_inicial_afd]
estados_afd = []
func_transicao_afd = {}

while !estados_nao_processados.empty?
  estado_atual_conjunto = estados_nao_processados.shift

  estados_afd << estado_atual_conjunto unless estados_afd.include?(estado_atual_conjunto)

  func_transicao_afd[estado_atual_conjunto] = {}

  puts("\nProcessando o Novo Estado do AFD: {#{estado_atual_conjunto.join(', ')}}")

  simbolos.each do |simbolo|
    proximo_estado_conjunto = transicao_afn(estado_atual_conjunto, simbolo, func_transicao_afn)

    if proximo_estado_conjunto.empty?
        destino = []
    else
        destino = proximo_estado_conjunto
    end

    func_transicao_afd[estado_atual_conjunto][simbolo] = destino

    puts("  Lendo '#{simbolo}': Transiciona para {#{destino.join(', ')}}")

    if !destino.empty? && !estados_afd.include?(destino) && !estados_nao_processados.include?(destino)
      estados_nao_processados << destino
      puts("    -> Novo Estado Descoberto: {#{destino.join(', ')}} (Adicionado à Fila)")
    end
  end
end

estados_finais_afd = []
estados_afd.each do |estado_afd|
  if (estado_afd & estados_finais_afn).any?
    estados_finais_afd << estado_afd
  end
end

puts("\n" + "=" * 50)
puts("RESULTADO DA CONVERSÃO (AFD)")
puts("=" * 50)

mapeamento_estados = {}
estados_afd.each_with_index do |conjunto, i|
  nome_curto = "S#{i}"
  mapeamento_estados[conjunto] = nome_curto
  puts("* **#{nome_curto}** (AFN: {#{conjunto.join(', ')}})")
end

if func_transicao_afd.values.any? { |t| t.values.include?([]) }
    poco = "S_POCO"
    mapeamento_estados[[]] = poco
    puts("* **#{poco}** (Estado Morto/Poço)")
end

estado_inicial_afd_nome = mapeamento_estados[estado_inicial_afd]
puts("\n## Estado Inicial do AFD (q'0)")
puts("* **#{estado_inicial_afd_nome}** (AFN: {#{estado_inicial_afd.join(', ')}})")

puts("\n## Estados Finais do AFD (F')")
if estados_finais_afd.empty?
  puts("* Nenhum")
else
  estados_finais_afd.each do |conjunto|
    puts("* **#{mapeamento_estados[conjunto]}** (AFN: {#{conjunto.join(', ')}})")
  end
end

puts("\n## Tabela de Transição do AFD (δ')")
puts("| Estado | " + simbolos.map { |s| "δ'(q', #{s})" }.join(" | ") + " |")
puts("| :--- |" + " :---: |" * simbolos.size)

func_transicao_afd.each do |origem_conjunto, transicoes|
  origem_nome = mapeamento_estados[origem_conjunto]
  linha = "| **#{origem_nome}** "

  simbolos.each do |simbolo|
    destino_conjunto = transicoes[simbolo] || []
    destino_nome = mapeamento_estados[destino_conjunto] || mapeamento_estados[[]]
    linha += "| #{destino_nome} "
  end
  puts(linha + "|")
end

if mapeamento_estados.key?([])
    linha_poco = "| **#{mapeamento_estados[[]]}** "
    simbolos.each do |simbolo|
        linha_poco += "| #{mapeamento_estados[[]]} "
    end
    puts(linha_poco + "|")
end

puts("-" * 50)