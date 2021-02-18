function fibonacci_test(higher_n)

    sequence = zeros(higher_n, 6)

    previous_1 = 0
    previous_2 = 0

    for n = 1:higher_n

        fibonacci_number = get_fibonacci_number(n)
        
        if (n < 3)
            sequence(n, 1:2) = [n fibonacci_number]
        else
            ratio1 = (fibonacci_number / previous_1)
            ratio2 = (fibonacci_number / previous_2)
            sequence(n, :) = [n fibonacci_number ratio1 ratio2 (ratio1 / ratio2) (ratio2 / ratio1)]
        end

        previous_2 = previous_1
        previous_1 = fibonacci_number

    end

    clc
    sequence

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