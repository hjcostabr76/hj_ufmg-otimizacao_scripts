
FILE_EQUIPMENT = './files/EquipDB.csv';
FILE_CLUSTER = './files/ClusterDB.csv';
FILE_M_PLAN = './files/MPDB.csv';

COLUMN_EQUIPMENT_ID = 1;
COLUMN_EQUIPMENT_T0 = 2;
COLUMN_EQUIPMENT_CLUSTER = 3;
COLUMN_EQUIPMENT_COST_FAILURE = 4;

COLUMN_CLUSTER_ID = 1;
COLUMN_CLUSTER_ETA = 2;
COLUMN_CLUSTER_BETA = 3;

COLUMN_M_PLAN_ID = 1;
COLUMN_M_PLAN_K = 2;
COLUMN_M_PLAN_COST = 3;

DELTA_T = 5;

% ---------------------------------------------------
% == Inicio =========================================
% ---------------------------------------------------

% Le arquivos
equipments = readtable(FILE_EQUIPMENT);
clusters = readtable(FILE_CLUSTER);
plans = readtable(FILE_M_PLAN);

equipments = equipments{:, :};
clusters = clusters{:, :};
plans = plans{:, :};

plans_count = size(plans, 1);
equipments_count = size(equipments, 1);

% Monta matriz de probabilidades de falha
failure_probabilities = zeros(equipments_count, plans_count);
equipment_zero_column = zeros(equipments_count, 1);

get_eta = @(cluster_id) clusters(cluster_id, COLUMN_CLUSTER_ETA);
get_beta = @(cluster_id) clusters(cluster_id, COLUMN_CLUSTER_BETA);

for j = 1:plans_count
    
    % Definir parametros para calculo das probabilidades
    k = plans(j, COLUMN_M_PLAN_K);
    column_k = equipment_zero_column;
    column_k(:) = k;
    
    column_t = equipment_zero_column;
    column_t(:) = k*DELTA_T;
    column_t0 = equipments(:, COLUMN_EQUIPMENT_T0);

    column_cluster = equipments(:, COLUMN_EQUIPMENT_CLUSTER);
    column_eta = arrayfun(get_eta, column_cluster);
    column_beta = arrayfun(get_beta, column_cluster);

    % Calcular probabilidades
    failure_probabilities(:, j) = arrayfun(@get_failure_probability, column_k, column_t, column_t0, column_eta, column_beta);
    
end

% Define o modelo
sparse(failure_probabilities)
% model.A = sparse(get_failure_probabilities(equipments, plans));
% model.modelsense = 'max';
% model.vtype = 'B';

% model.obj = [1 1 2];
% model.rhs = [4; 1];
% model.sense = '<>';

% names = {'x'; 'y'; 'z'};
% model.varnames = names;

% % Resolve o problema
% params.outputflag = false;
% result = gurobi(model, params);

% % Exibe o resultado
% disp(result);

% for v=1:length(names)
%     fprintf('%s %d\n', names{v}, result.x(v));
% end

% fprintf('Obj: %e\n', result.objval);



function [probability] = get_failure_probability(k, t, t0, eta, beta)
    f_t = get_weibull(t, eta, beta);
    f_t0 = get_weibull(t0, eta, beta);
    probability = (f_t - f_t0 ) / (1 - f_t0);

end

function [weibull] = get_weibull(t, eta, beta)
    weibull = 1 - exp( -(t / eta)^beta );
end

% function [cf] = objective_function(x)

%     for i = 1:length(equipments)
%         for j = 1:length(plans)

%             if (x(i, j) == 0)
%                 break
%             end

%             % Captura variaveis: Plano
%             k = plans(j, COLUMN_M_PLAN_K);
            
%             % Captura variaveis: Equipamento
%             t0 = equipments(i, COLUMN_EQUIPMENT_T0);
%             t0_2 = t0 + k*DELTA_T;
            
%             % Captura variaveis: Cluster
%             cluster_id = equipments(i, COLUMN_EQUIPMENT_CLUSTER);
%             eta = clusters(cluster_id, COLUMN_CLUSTER_ETA);
%             beta = clusters(cluster_id, COLUMN_CLUSTER_BETA);
            
%             % Calcular: F_i
%             f_t0_2 = 1 - exp( -(t0_2 / eta)^beta );
%             f_t0 = 1 - exp( -(t0 / eta)^beta );

%             % Calcular: CF_i * p_ij
%             p_ij = (f_t0_2 - f_t0 ) / (1 - f_t0);
%             cf_ij = cf_i * p_ij;

%             % Atualiza objetivo
%             cf = cf + cf_ij;

%         end
%     end
% end
