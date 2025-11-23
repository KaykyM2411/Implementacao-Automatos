puts("Informe o conjunto de estados (separados por vírgula): ")
estados = gets.chomp.split(",").map(&:strip)

puts("Informe o conjunto de símbolos do alfabeto (separados por vírgula): ")
simbolos = gets.chomp.split(",").map(&:strip)

puts("Informe o estado inicial: ")
estado_inicial = gets.chomp.strip

puts("Informe o conjunto de estados finais (separados por vírgula): ")
estados_finais = gets.chomp.split(",").map(&:strip)

puts("Informe as funções de transição: ")

func_transicao = {}

simbolos.each do |simbolo|
  func_transicao[simbolo] = {}
  estados.each do |estado|
    puts("De #{estado} com símbolo #{simbolo}, vá para qual estado?")
    proximo_estado = gets.chomp.strip
    
    if proximo_estado == "."
      func_transicao[simbolo][estado] = nil
    else
      func_transicao[simbolo][estado] = proximo_estado
    end
  end
end

puts("Informe a cadeia de entrada: ")
cadeia_entrada = gets.chomp.strip

estado_atual = estado_inicial

cadeia_entrada.chars.each do |simbolo|
  puts("Estado: #{estado_atual}, Símbolo lido: #{simbolo}")
  puts("Proximo estado: #{func_transicao[simbolo][estado_atual]}")

  estado_atual = func_transicao[simbolo][estado_atual]

  if estado_atual.nil?
    puts("O automato nao aceitou a cadeia.")
    break
  end
end

estados_finais.include?(estado_atual) ? puts("O automato aceitou a cadeia.") : puts("O automato nao aceitou a cadeia.")