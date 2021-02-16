
%{

SIMPLEX
Implementação completa do algoritmo Simplex para resolucao de Problemas de Otimizacao Linear

PARAMETROS
- A [matriz m x n]: Matriz A - Coeficientes das variaveis de decisao;
- b [matriz n x 1]: Vetor b - Vetor de Custos (restricoes);
- C [matriz 1 x ?]: Vetor C - Coeficientes da Função Objetivo;
- columnsBase [Matriz 1 x n] - Indices das colunas da Base otima inicial;

-- Onde m = Numero de restricoes; n = Numero de variaveis de decisao --

RESULTADO
O resultado eh printado na janela de comando
- Numero de Iteracoes;
- Valor Otimo;
- Historico de valores da Funcao Objetivo;
- Historico de valores das variaveis de decisao (Valor Final == ultima linha);

%}
function simplexComplete(A, b, C, columnsBase)

    maxIterations = 50
    varsCount = size(A, 2)

    targets = zeros(2 * maxIterations, 1)
    variables = zeros(2 * maxIterations, varsCount)
    
    i = 0
    j = 0

    while (true)

        % Previnir loop infinito
        i = i + 1
        if (i > maxIterations)
            clc
            fprintf('Falha:: Limite de iterações atingido [%d]\n', maxIterations)
            break
        end

        % Definir Particao
        columnsNotBase = getColumnsNotBase(columnsBase, varsCount)
        B = A(:, columnsBase)
        N = A(:, columnsNotBase)
        
        % Definir variaveis de decisao
        xB = B \ b % 'matrix left division' == inv(B) * b
        if (i == 1)
            xN = zeros(length(columnsNotBase), 1)
        end

        % Checar se solucao basica eh factivel
        j = j + 1
        x = getX(columnsBase, columnsNotBase, xB, xN)
        variables(j, :) = x'
        
        negativeBaseVars = length(find(xB < 0))
        if (negativeBaseVars > 0)
            clc
            fprintf('Falha:: Base atual não é factível!\n')
            pause
            columnsBase
            break
        end

        % Registrar progresso
        targets(j) = transpose(C) * x

        % Definir Vetor multiplicador [lambda] (transposto)
        lambdaT = C(columnsBase)' / B % 'matrix right division' == C(baseColumns) * inv(B)

        % Definir Custos relativos
        c = C(columnsNotBase)' - lambdaT * N

        % Verificar se chegamos na solucao otima
        negativeCostsCount = length(find(c < 0))
        if (negativeCostsCount == 0)
            clc
            fprintf('Sucesso:: Solução Ótima encontrada!\n')
            break
        end

        % Definir Vetor Direcao
        [aux, minCostIdx] = min(c)
        aNk = N(:, minCostIdx)
        gamma = B \ aNk % 'matrix left division' == inv(B) * aNk

        % Verificar se problema tem solucao otima ilimitada
        positiveLinesCount = length(find(gamma > 0))
        if (positiveLinesCount == 0)
            clc
            fprintf('Atenção:: Este problema não possui solução ótima (apenas solução ótima ilimitada)!\n')
            break
        end

        % Determinar passo otimo
        [bestEpsilonIdx, epsilon] = getOptimumStep(gamma, xB)

        % Preparar para prox iteracao
        xB = xB - (gamma * epsilon)
        xN = zeros(length(columnsNotBase), 1)
        xN(minCostIdx) = epsilon

        columnsBase(bestEpsilonIdx) = columnsNotBase(minCostIdx)

        % Registrar progresso
        j = j + 1
        x = getX(columnsBase, columnsNotBase, xB, xN)
        variables(j, :) = x'
        targets(j) = transpose(C) * x

    end

    % Exibir resultado
    fprintf('Iterações: %d\n', i)
    fprintf('Valor Ótimo: %d\n', targets(j))

    fprintf('Histórico da Função Objetivo:\n')
    pause
    targets(1:j)

    fprintf('Histórico das Variáveis de Decisão:\n')
    pause
    variables(1:i, :)
    
    fprintf('-- FIM --\n')
    pause

end

%{

Calcula & retorna passo otimo (epsilon chapeu) para atualizacao das variaveis de decisao.

PARAMETROS
- gamma [matriz n x 1]: Direcao Simplex
- xB [Matriz m x 1] - Valor atual das Variaveis Basicas;

-- Onde m = Numero de restricoes; n = Numero de variaveis de decisao --

RESULTADO
- bestIdx, epsilonHat [matrix 1 x 2]: Posicao & valor do passo otimo dentro do vetor de passos [epsilon];

%}
function [bestIdx, epsilonHat] = getOptimumStep(gamma, xB)

    bestIdx = 1
    epsilon = zeros(length(xB), 1)

    for i = 1:length(xB)
        
        if gamma(i) > 0
            epsilon(i) = xB(i) / gamma(i)
        else
            epsilon(i) = inf
        end
        
        if ((i > 1) && (epsilon(i) < epsilon(bestIdx)))
            bestIdx = i
        end
    end

    epsilonHat = min(epsilon)
end


%{

Calcula & retorna vetor 'x' (valores atualizados das variaveis de decisao).

PARAMETROS
- columnsBase [matriz 1 x m]: Indices de colunas da Matriz A que compoem a Matriz Basica;
- columnsNotBase [matriz 1 x (n - m)]: Indices de colunas da Matriz A que compoem a Matriz NAO Basica;
- xB [Matriz m x 1] - Valor atual das Variaveis Basicas;
- xN [Matriz (m - n) x 1] - Valor atual das Variaveis NAO Basicas;

-- Onde m = Numero de restricoes; n = Numero de variaveis de decisao --

RESULTADO
- x [matrix n x 1]

%}
function [x] = getX(columnsBase, columnsNotBase, xB, xN)

    rowsCount = size([xB; xN], 1)
    x = zeros(rowsCount, 1)

    for i = 1:length(columnsBase)
        idx = columnsBase(i)
        x(idx) = xB(i)
    end

    for i = 1:length(columnsNotBase)
        idx = columnsNotBase(i)
        x(idx) = xN(i)
    end
end

%{

Calcula & retorna indices de colunas da Matriz A que compoem a Matriz NAO Basica;

PARAMETROS
- columnsBase [matriz 1 x m]: Indices de colunas da Matriz A que compoem a Matriz Basica;
- varsCount [int]: Quantidade de Variaveis de Decisao do problema;

-- Onde m = Numero de restricoes; n = Numero de variaveis de decisao --

RESULTADO
- columnsNotBase [matrix 1 x (m - n)]

%}
function [columnsNotBase] = getColumnsNotBase(columnsBase, varsCount)
    aux = ones(1, varsCount)
    aux(columnsBase) = 0
    columnsNotBase = find(aux)
end
