# !pip install cplex
# !pip install docplex

import numpy as np
import math
from docplex.mp.model import Model
import cplex

# = = = = = = = = = = = = = = = = = = = = = = = = 
# - - Parametrizaco - - - - - - - - - - - - - - -
# = = = = = = = = = = = = = = = = = = = = = = = = 

# FILE_NAME_EQUIPMENT = '/content/files-input/EquipDB.csv';
# FILE_NAME_CLUSTER = '/content/files-input/ClusterDB.csv';
# FILE_NAME_M_PLAN = '/content/files-input/MPDB.csv';

FILE_NAME_EQUIPMENT = 'EquipDB.csv';
FILE_NAME_CLUSTER = 'ClusterDB.csv';
FILE_NAME_M_PLAN = '/content/files-input/MPDB.csv';

FILE_NAME_RESULT = 'HebertCosta.csv'
FILE_DELIMITER = ','

COLUMN_EQUIPMENT_ID = 0;
COLUMN_EQUIPMENT_T0 = 1;
COLUMN_EQUIPMENT_CLUSTER = 2;
COLUMN_EQUIPMENT_COST_FAILURE = 3;

COLUMN_CLUSTER_ID = 0;
COLUMN_CLUSTER_ETA = 1;
COLUMN_CLUSTER_BETA = 2;

COLUMN_M_PLAN_ID = 0;
COLUMN_M_PLAN_K = 1;
COLUMN_M_PLAN_COST = 2;

DELTA_T = 5;
MODEL_NAME = 'Plano de Manutenção'
COST_MAX_UPPER_BOUNDARY = 1000
STEP_PERCENTAGE = .001


# = = = = = = = = = = = = = = = = = = = = = = = = 
# - - Ler arquivos de entrada - - - - - - - - - -
# = = = = = = = = = = = = = = = = = = = = = = = =

clusters = np.genfromtxt(FILE_NAME_CLUSTER, delimiter=FILE_DELIMITER);
equipments = np.genfromtxt(FILE_NAME_EQUIPMENT, delimiter=FILE_DELIMITER);
m_plans = np.genfromtxt(FILE_NAME_M_PLAN, delimiter=FILE_DELIMITER);

# = = = = = = = = = = = = = = = = = = = = = = = = 
# - - Definir funções auxiliares - - - - - - - - 
# = = = = = = = = = = = = = = = = = = = = = = = =

def get_weibull(t, eta, beta):
  return 1 - np.exp(-(t / eta)**beta)

def get_failure_probability(t, t0, eta, beta):
  f_1 = get_weibull(t + t0, eta, beta);
  f_2 = get_weibull(t0, eta, beta);
  return (f_1 - f_2 ) / (1 - f_2);

def get_eta(cluster_id):
  return clusters[cluster_id - 1, [COLUMN_CLUSTER_ETA]];

def get_beta(cluster_id):
  return clusters[cluster_id - 1, [COLUMN_CLUSTER_BETA]];

# = = = = = = = = = = = = = = = = = = = = = = = = 
# - - Montar matriz de custo de falha - - - - - - 
# = = = = = = = = = = = = = = = = = = = = = = = =

plans_count = len(m_plans);
equipments_count = len(equipments);

costs_failure = np.zeros( (equipments_count, plans_count) );
probabilities_failure = np.zeros( (equipments_count, plans_count) );

column_t0 = equipments[:, [COLUMN_EQUIPMENT_T0]];
column_cluster = equipments[:, [COLUMN_EQUIPMENT_CLUSTER]];
column_eta = get_column_eta(column_cluster.astype(int));
column_beta = get_column_beta(column_cluster.astype(int));

for j in range(0, plans_count):
    
  k = m_plans[j, COLUMN_M_PLAN_K];
  column_t = np.ones( (equipments_count, 1) ) * k*DELTA_T;

  column_probabilities_failure = get_failure_probability(column_t, column_t0, column_eta, column_beta)
  column_cost_failure = equipments[:, [COLUMN_EQUIPMENT_COST_FAILURE]];
  costs_failure[:, [j]] = column_cost_failure * column_probabilities_failure

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
# - - Definir funcao objetivo 01: Minimzar custo de falha - -
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 

def objective_01_cost_failure(X):

  is_dictionary = type(X) == dict
  cost_failure_total = 0

  for i in range(0, equipments_count):
    for j in range(0, plans_count):

      if is_dictionary:
        decision_var = X[ (i, j) ]
      else:
        decision_var = X[i, j]

      cost_failure_total = cost_failure_total + costs_failure[i, j] * decision_var

  return cost_failure_total


# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# - - Definir funcao objetivo 02: Minimzar custo de manutencao - -
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 


def objective_02_cost_maintenance(X):
  
  is_dictionary = type(X) == dict
  cost_maintenance_total = 0

  for i in range(0, equipments_count):
    for j in range(0, plans_count):
      
      if is_dictionary:
        decision_var = X[ (i, j) ]
      else:
        decision_var = X[i, j]

      cost_maintenance_total = cost_maintenance_total + (m_plans[j, COLUMN_M_PLAN_COST] * decision_var)

  return cost_maintenance_total

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# - - Determinar minimo otimo - - - - - - - - - - - - - - - - - -
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 

solutions = []
pareto_pairs = []

iterations = math.ceil(COST_MAX_UPPER_BOUNDARY / (STEP_PERCENTAGE * COST_MAX_UPPER_BOUNDARY))

for iteration in range(0, iterations):

  # Instanciar modelo
  model = Model(name=MODEL_NAME)
  X = model.binary_var_matrix(equipments_count, plans_count)

  # Add restricoes
  cost_max = math.ceil((iteration / iterations) * COST_MAX_UPPER_BOUNDARY)
  model.add_constraint(objective_02_cost_maintenance(X) <= cost_max)

  for i in range(0, equipments_count):
    model.add_constraint(X[ (i, 0) ] + X[ (i, 1) ] + X[ (i, 2) ] == 1)

  # Resolve
  model.minimize(objective_01_cost_failure(X))
  result = model.solve()

  # Guarda resultado parcial
  result_x_solver = result.get_all_values()
  result_x = np.array(result_x_solver).reshape(equipments_count, plans_count)

  objective_01 = objective_01_cost_failure(result_x)
  objective_02 = objective_02_cost_maintenance(result_x)
  # print(iteration + 1, "| objetivos:", objective_01, ",", objective_02, "(", cost_max, "/", COST_MAX_UPPER_BOUNDARY, ")")
  
  pareto_pairs.append( np.array([objective_01, objective_02]) )
  solutions.append(result_x)

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# - - Exportar resultado - - - - - - - - - - - - - - - - - - - -
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 

final_result = np.zeros( (len(solutions), equipments_count) )

for i in range(0, len(solutions)):
  for j in range(0, len(solutions[i])):
    final_result[i, j] = 1 + np.argmax(solutions[i][j,:], axis=0)
        
np.savetxt(FILE_NAME_M_PLAN, final_result, delimiter=FILE_DELIMITER)
