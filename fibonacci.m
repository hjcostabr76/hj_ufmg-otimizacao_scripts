function [optimun_x optimun_f i test_points bounds_history history] = fibonacci(f, initial_bounds, n, is_min, display_result, displacement)

    % Valida entrada
    if (n <= 2)
        fprintf('Ordem inválida! n deve ser > 2')
        return
    end

    history = zeros(n - 2, 7) % j a b x1 x2 f1 f2
    
    % Inicializa variaveis
    interval_length = 0
    is_long_displacement = false

    x1 = 0
    x2 = 0
    
    f1 = 0
    f2 = 0

    a = initial_bounds(1)
    b = initial_bounds(2)

    i = 1
    j = 2

    % Determina deslocamento inicial (se necessario)
    if ~exist('displacement','var')
        displacement = get_displacement(n, j, b - a)
    end
    
    while (j < n)

        % Determina pontos para analisar
        interval_length = b - a
        is_long_displacement = displacement > (interval_length / 2)

        if (is_long_displacement)
            x1 = b - displacement
            x2 = a + displacement
        else
            x1 = a + displacement
            x2 = b - displacement
        end

        % Atualiza intervalo de incerteza
        f1 = f(x1)
        f2 = f(x2)

        history(i, 1:size(history, 2)) = [j a b x1 x2 f1 f2]

        if (f1 == f2)
            
            a = x1
            b = x2
            displacement = get_displacement(n, j, b - a)
            j = j + 1

        else

            if ((is_min && (f1 < f2)) || (~is_min && (f1 > f2)))
                b = x2
            else
                a = x1
            end

            displacement = get_displacement(n, j, interval_length)

        end

        j = j + 1
        i = i + 1

    end

    % Determina saida
    test_points = unique(reshape(history(:, 4), [1, n - 2]), 'stable')
    bounds_history = unique(reshape(history(:, 2:3), [1, 2 * (n - 2)]), 'stable')
    
    % Determina ponto otimo
    optimun_x = (a + b) / 2
    optimun_f = f(optimun_x)

    % Exibe resultado
    if (~exist('display_result','var') || display_result)
        
        fprintf('Histórico: ')
        history

        fprintf('\nIterações: %d', i)
        fprintf('\nÓtimo: (%d, %d)', optimun_x, optimun_f)
        fprintf('\n-- FIM --\n')

    end

end

function [displacement] = get_displacement(n, j, interval_length)
    displacement = interval_length * get_fibonacci_number(n - j) / get_fibonacci_number(n -(j - 2))
end
