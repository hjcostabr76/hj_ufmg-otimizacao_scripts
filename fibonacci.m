function fibonacci(f, interval, n, is_min)

    % Valida entrada
    if (n <= 2)
        fprintf('Ordem inválida! n deve ser >= 2')
        return
    end

    MAX_ITERATIONS = 10
    
    % Inicializa variaveis
    lower_bound = interval(1)
    upper_bound = interval(2)
    displacement = (upper_bound - lower_bound) * (get_fibonacci_number(n - 2) / get_fibonacci_number(n))
    
    middle_left = lower_bound + displacement
    middle_right = upper_bound - displacement
    
    history = zeros(MAX_ITERATIONS, 7) % j x a x1 x2 b f_x
    history(1, 1:size(history, 2)) = [1 middle_left lower_bound upper_bound middle_left middle_right f(middle_left)]
    history(2, 1:size(history, 2)) = [2 middle_right lower_bound upper_bound middle_left middle_right f(middle_right)]
    
    new_x = 0
    i = 1
    j = 2
    
    while (j < n)

        % Valida maximo de iteracoes
        if (i == MAX_ITERATIONS)
            fprintf('FALHA: Maximo de iterações (%d) atingido\n', MAX_ITERATIONS)
            return
        end

        fl = f(middle_left)
        fr = f(middle_right)
        
        % Atualiza intervalo: Direcao esquerda
        displacement = middle_right - middle_left
        
        if ((is_min && (fl < fr)) || (~is_min && (fl > fr)))
            
            upper_bound = middle_right
            new_x = lower_bound + displacement

            if (new_x < middle_left)
                aux = middle_left
                middle_left = new_x
                middle_right = aux
            else
                middle_right = new_x
            end
            
        % Atualiza intervalo: Direcao direita
        elseif ((is_min && (fl > fr)) || (~is_min && (fl < fr)))
            
            lower_bound = middle_left
            new_x = lower_bound + displacement

            if (new_x > middle_right)
                aux = middle_right
                middle_right = new_x
                middle_left = aux
            else
                middle_left = new_x
            end
            
        % Atualiza intervalo: Centro
        else
            
            lower_bound = middle_left
            upper_bound = middle_right
            displacement = (upper_bound - lower_bound) * (get_fibonacci_number(n - j) / get_fibonacci_number(n - (j - 2)))
            
            middle_left = lower_bound + displacement
            new_x = middle_left
            history(j, 1:size(history, 2)) = [j new_x lower_bound upper_bound middle_left middle_right f(new_x)]
            
            j = j + 1
            middle_right = upper_bound - displacement
            new_x = middle_right

        end

        % Prepara para proxima iteracao
        j = j + 1
        i = i + 1
        history(j, 1:size(history, 2)) = [j new_x lower_bound upper_bound middle_left middle_right f(new_x)]

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


function [fibonacci_number] = get_fibonacci_number(n)

    if (n < 0)
        fprintf('Índice inválido para sequência Fibonacci (%d)!\n', n)
        return

    elseif (n <= 1)
        fibonacci_number = 1
    else
        fibonacci_number = get_fibonacci_number(n - 1) + get_fibonacci_number(n - 2)
    end
    
end