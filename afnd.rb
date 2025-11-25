def lambda_fecho(estados, func_transicao_lambda)
  fecho = estados.dup
  pilha = estados.dup

  until pilha.empty?
    estado = pilha.pop
    
    if func_transicao_lambda.key?(estado)
      func_transicao_lambda[estado].each do |proximo_estado|
        unless fecho.include?(proximo_estado)
          fecho << proximo_estado
          pilha << proximo_estado
        end
      end
    end
  end
  return fecho
end


puts("Informe o conjunto de estados (separados por vírgula): ")
estados = gets.chomp.split(",").map(&:strip)

puts("Informe o conjunto de símbolos do alfabeto (separados por vírgula): ")
simbolos = gets.chomp.split(",").map(&:strip)
simbolos_com_lambda = simbolos + ["lambda"] 

puts("Informe o estado inicial: ")
estado_inicial = gets.chomp.strip

puts("Informe o conjunto de estados finais (separados por vírgula): ")
estados_finais = gets.chomp.split(",").map(&:strip)

puts("Informe as funções de transição (use 'lambda' para transições vazias, e se houver múltiplos estados de destino, separe-os por vírgula): ")

func_transicao = {}

simbolos_com_lambda.each do |simbolo|
  func_transicao[simbolo] = {}
  
  estados.each do |estado|
    puts("De #{estado} com símbolo #{simbolo}, vá para qual(is) estado(s)? (Separe por vírgula ou deixe vazio/digite '.' se não houver transição)")
    proximos_estados_str = gets.chomp.strip
    
    if proximos_estados_str.empty? || proximos_estados_str == "."
      func_transicao[simbolo][estado] = [] # Nenhuma transição
    else
      func_transicao[simbolo][estado] = proximos_estados_str.split(",").map(&:strip).reject(&:empty?)
    end
  end
end

func_transicao_lambda = {}
func_transicao["lambda"]&.each do |estado, destinos|
  func_transicao_lambda[estado] = destinos unless destinos.empty?
end



puts("\nInforme a cadeia de entrada: ")
cadeia_entrada = gets.chomp.strip
puts("-" * 40)

estado_atual_conjunto = lambda_fecho([estado_inicial], func_transicao_lambda)
puts("Início: Lambda-fecho de {#{estado_inicial}} é {#{estado_atual_conjunto.join(', ')}}")

cadeia_entrada.chars.each do |simbolo|
  puts("\nProcessando Símbolo: **#{simbolo}**")
  
  proximo_conjunto_simbolo = []
  
  estado_atual_conjunto.each do |estado|
    if func_transicao.key?(simbolo) && func_transicao[simbolo].key?(estado)
      proximo_conjunto_simbolo.concat(func_transicao[simbolo][estado])
    end
  end
  
  proximo_conjunto_simbolo.uniq!

  if proximo_conjunto_simbolo.empty?
    puts("Estados intermediários: {} (Parada sem estados acessíveis)")
    estado_atual_conjunto = []
    break
  end
  
  estado_atual_conjunto = lambda_fecho(proximo_conjunto_simbolo, func_transicao_lambda)
  
  puts("Estados intermediários: {#{proximo_conjunto_simbolo.join(', ')}}")
  puts("Novo conjunto de estados (após λ-fecho): {#{estado_atual_conjunto.join(', ')}}")
end

puts("-" * 40)


aceitou = false
estado_atual_conjunto.each do |estado|
  if estados_finais.include?(estado)
    aceitou = true
    break
  end
end

if aceitou
  puts("O autômato aceitou a cadeia. (Conjunto final de estados contém um estado final: {#{estado_atual_conjunto.join(', ')}})")
else
  puts("O autômato não aceitou a cadeia. (Conjunto final de estados: {#{estado_atual_conjunto.join(', ')}} não contém nenhum estado final)")
end