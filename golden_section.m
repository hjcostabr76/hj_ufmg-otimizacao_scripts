function [optimun_x optimun_f iterations test_points bounds_history history] = golden_section(f, initial_bounds, percentage_accuracy, is_min, display_result)

    GAMMA = 1 / .618 % Proporcao aurea

    L0 = initial_bounds(2) - initial_bounds(1) % Incerteza incial
    Lk = 2 * L0 * .01 * percentage_accuracy % inceteza maxima

    k = round(1 - (log(Lk / L0) / log(GAMMA))) % Qtd de experimentos necessarios
    initial_displacement = (1 / GAMMA) * L0 % Deslocamento inicial padrao

    [optimun_x optimun_f iterations test_points bounds_history history] = fibonacci(f, initial_bounds, k, is_min, initial_displacement, false)

    if (~exist('display_result','var') || display_result)
        
        fprintf('Histórico: ')
        history

        fprintf('\nIterações: %d', iterations)
        fprintf('\nÓtimo: (%d, %d)', optimun_x, optimun_f)
        fprintf('\n-- FIM --\n')

    end

end