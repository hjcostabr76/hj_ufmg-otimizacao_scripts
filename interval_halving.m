function interval_halving(f, interval, percentage_accuracy, is_min)

    MAX_ITERATIONS = 10
    
    lower_bound = interval(1)
    upper_bound = interval(2)
    
    initial_range = upper_bound - lower_bound
    max_range = 2 * initial_range * .01 * percentage_accuracy
    
    x1 = 0
    x0 = 0
    x2 = 0
    
    f1 = 0 
    f0 = 0 
    f2 = 0 
    
    history = zeros(MAX_ITERATIONS, 9)
    i = 0

    while (true)

        % Valida maximo de iteracoes
        if (i == MAX_ITERATIONS)
            fprintf('FALHA: Maximo de iterações (%d) atingido\n', MAX_ITERATIONS)
            return
        end
        
        % Computa valores para comparacao
        current_range = upper_bound - lower_bound
        quarter = current_range / 4
        
        x1 = lower_bound + quarter
        x0 = x1 + quarter
        x2 = x0 + quarter
        
        f1 = f(x1)
        f0 = f(x0)
        f2 = f(x2)
        
        i = i + 1
        history(i, 1:size(history, 2)) = [i lower_bound upper_bound x1 x0 x2 f1 f0 f2]
        
        % Verifica se ponto otimo foi encontrado
        if (current_range < max_range)
            break
        end
        
        % Atualiza intervalo
        if ((is_min && (f1 < f0) && (f0 < f2)) || (~is_min && (f1 > f0) && (f0 > f2)))
            upper_bound = x0

        elseif ((is_min && (f1 > f0) && (f0 > f2)) || (~is_min && (f1 < f0) && (f0 < f2)))
            lower_bound = x0
            
        elseif ((is_min && (f1 > f0) && (f0 < f2)) || (~is_min && (f1 < f0) && (f0 > f2)))
            upper_bound = x2
            lower_bound = x1
        else
            fprintf('FALHA: Erro ao avaliar limites\n')
            return
        end

    end

    % Determina ponto otimo
    optimun_x = (lower_bound + upper_bound) / 2
    optimun_f_x = (f1 + f2) / 2

    % Exibe resultado
    fprintf('Histórico: ')
    history

    fprintf('\nIterações: %d', i)
    fprintf('\nÓtimo: (%d, %d)', optimun_x, optimun_f_x)
    fprintf('\n-- FIM --\n')
end