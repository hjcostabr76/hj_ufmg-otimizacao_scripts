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