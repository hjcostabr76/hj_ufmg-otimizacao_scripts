%{
    @see: https://www.gurobi.com/documentation/9.1/refman/optimization_status_codes.html#sec:StatusCodes
    @see https://www.gurobi.com/documentation/9.1/refman/attributes.html#sec:Attributes
%}
function matlab_gurobi_test()
    
    % Copyright 2020, Gurobi Optimization, LLC
    % This example formulates and solves the following simple MIP model:
    %  maximize
    %        x +   y + 2 z
    %  subject to
    %        x + 2 y + 3 z <= 4
    %        x +   y       >= 1
    %        x, y, z binary
    

    % ---------------------------------------------------
    % == Constroi modelo ================================
    % ---------------------------------------------------

    %{
        Matriz A: Coeficientes das restricoes
        - Parametro obrigatorio;
        - DEVE ser matriz esparsa;
    %}
    model.A = sparse([1 2 3; 1 1 0]);

    %{
        Tipo de otimizacao (min / max)
        - Parametro opcional;
        - Padrao: min;
    %}
    model.modelsense = 'max';

    %{
        Tipo das variaveis
        @see https://www.gurobi.com/documentation/9.1/refman/vtype.html#attr:VType

        - Parametro opcional;
        - String com letras correspondentes ao tipo de cada variavel (01 por linha da matriz A);
        - Caso seja incluido apenas 01 letra a mesma sera aplicada a todas as variaveis;
        - Valores possiveis: B, C, I, S, N;
    %}
    model.vtype = 'B';


    %{
        Funcao objetivo (coeficientes)
        @see https://www.gurobi.com/documentation/9.1/refman/obj.html#attr:Obj

        - Este eh 01 jeito de especificar a funcao objetivo do problema (existem outros);
        TODO: Mapear outras formas de determinar a funcao objetivo
    %}
    model.obj = [1 1 2];

    model.rhs = [4; 1]; % Valor b (lado direito das restricoes)

    %{

        Sinais das restricoes
        @see https://www.gurobi.com/documentation/9.1/refman/sense.html#attr:Sense

        - String com 01 sinal pra cada linha de A;
        - Valores possiveis: >, <, =
    %}

    model.sense = '<>';
    
    names = {'x'; 'y'; 'z'}; % Nomenclatura das variaveis
    model.varnames = names;

    % ---------------------------------------------------
    % == Gera descricao do problema em formato lp =======
    % ---------------------------------------------------
    
    % gurobi_write(model, 'mip1.lp');
    params.resultfile = 'mip1.lp';
    

    % ---------------------------------------------------
    % == Resolve o problema =============================
    % ---------------------------------------------------

    params.outputflag = false; % Desabilita saida padrao do gurobi
    result = gurobi(model, params);

    % ---------------------------------------------------
    % == Exibe o resultado ==============================
    % ---------------------------------------------------

    disp(result);
    
    for v=1:length(names)
        fprintf('%s %d\n', names{v}, result.x(v));
    end
    
    fprintf('Obj: %e\n', result.objval);
end