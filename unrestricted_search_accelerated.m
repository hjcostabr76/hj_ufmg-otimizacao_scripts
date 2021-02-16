function unrestricted_search_accelerated(f, start, initialStep, is_min)

    MAX_ITERATIONS = 25
    
    current_x = start
    current_f_x = f(current_x)
    
    previous_x = 0
    previous_f_x = 0
    
    next_x = 0
    next_f_x = 0
    
    f_x = zeros(MAX_ITERATIONS, 2)
    f_x(1, 1:size(f_x, 2)) = [current_x current_f_x]
    
    step = initialStep
    i = 0
    
    while (true)
        
        % Valida maximo de iteracoes
        i = i + 1
        if (i == MAX_ITERATIONS)
            fprintf('FALHA: Maximo de iterações (%d) atingido\n', MAX_ITERATIONS)
            return
        end

        % Verifica se ótimo foi encontrado
        next_x = current_x + step
        next_f_x = f(next_x)
        
        if ((is_min && (next_f_x > current_f_x)) || ((~is_min) && (next_f_x < current_f_x)))
            break 
        end
        
        % Preparar para nova iteracao
        f_x(i, 1:size(f_x, 2)) = [next_x next_f_x]
        step = (2 * step)

        previous_x = current_x
        previous_f_x = current_x
         
        current_x = next_x
        current_f_x = next_f_x

    end

    % Determina ponto otimo
    optimun_x = (previous_x + next_x) / 2
    optimun_f_x = (previous_f_x + next_f_x) / 2

    % Exibe resultado
    fprintf('Histórico: ')
    f_x

    fprintf('\nIterações: %d', i)
    fprintf('\nÓtimo: (%d, %d)', optimun_x, optimun_f_x)
    fprintf('\n-- FIM --\n')
end