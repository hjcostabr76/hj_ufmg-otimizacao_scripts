function dichotomous_search(f, interval, percentage_accuracy, delta, is_min)

    MAX_ITERATIONS = 10
    
    half_delta = delta / 2
    interval_lower_bound = interval(1)
    interval_upper_bound = interval(2)
    initial_range = interval_upper_bound - interval_lower_bound

    lower_bound = interval_lower_bound
    upper_bound = interval_upper_bound

    max_range = 2 * initial_range * .01 * percentage_accuracy
    
    left_f_x = 0
    right_f_x = 0
    
    history = zeros(MAX_ITERATIONS, 5)
    i = 0

    while (true)

        % Valida maximo de iteracoes
        if (i == MAX_ITERATIONS)
            fprintf('FALHA: Maximo de iterações (%d) atingido\n', MAX_ITERATIONS)
            return
        end

        % Verifica se ponto otimo foi encontrado
        i = i + 1
        history(i, 1:size(history, 2)) = [i lower_bound upper_bound left_f_x right_f_x]

        current_range = upper_bound - lower_bound
        if (current_range <= max_range)
            break
        end

        % Determina pontos a serem testados
        center = lower_bound + (current_range / 2)
        center_left = center - half_delta
        if (center_left < interval_lower_bound)
            center_left = interval_lower_bound
        end
        
        center_right = center + half_delta
        if (center_right > interval_upper_bound)
            center_right = interval_upper_bound
        end
        
        % Atualiza limites
        left_f_x = f(center_left)
        right_f_x = f(center_right)

        % Esquerda
        if ((is_min && (left_f_x < right_f_x)) || (~is_min && (left_f_x > right_f_x)))
            center = upper_bound
            upper_bound = center_right
            if (upper_bound > interval_upper_bound)
                upper_bound = interval_upper_bound
            end
            
        % Direta
        else
            center = lower_bound
            lower_bound = center_left
            if (lower_bound < interval_lower_bound)
                lower_bound = interval_lower_bound
            end
        end
    
    end

    % Determina ponto otimo
    optimun_x = (lower_bound + upper_bound) / 2
    optimun_f_x = f(optimun_x)

    % Exibe resultado
    fprintf('Histórico: ')
    history

    fprintf('\nIterações: %d', i)
    fprintf('\nÓtimo: (%d, %d)', optimun_x, optimun_f_x)
    fprintf('\n-- FIM --\n')
end