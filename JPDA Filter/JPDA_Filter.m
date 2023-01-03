% This script performs the JPDA filter on 1D data.

% Each target has the same discrete dynamical model x_k+1 = Fx_k + Gu_k
% and the same measurement model z_k = Hx_k.

clear, clc

%% Parameters
global F            % F matrix of dynamical model
global G            % G matrix of dynamical model
global H            % H matrix of measurement model
global R            % Covariance matrix of motion model | dimStates X dimStates
global Q            % Covariance matrix of measurement model | dimStates X dimStates
global tau          % Number of targets (fixed for now, TODO: can be variable and estimated)
global P_D          % Probability of a detection
global P_FA         % Probability of a false alarm
global map_size     % size for the map, centered around the origin | scalar

delta_t = 0.1;      % [s] Time between simulation steps
end_time = 100;     % [s] Duration of simulation

%% Initialise
% Define dynamical model: 1D random walk
F = 1;
G = 1;
H = 1;

% Set values for JPDA parameters
dim_states = size(F,1);
R = 0.02*eye(dim_states);
Q = 0.02*eye(dim_states);
P_D = 0.9;
P_FA = 0.1;

% Set the bounds of the map
map_size = 6;

% Number of targets
tau = 2;

% Set initial estimate of target states
mu = zeros(dim_states,tau);
mu(:,1) = -1;
mu(:,2) = 2;

% Set initial estimate of covariances. Increase to start with less certainty
sigma = repmat(1*R,[1,1,tau]);

% Sample a ground truth for each target
ground_truth = zeros(dim_states,tau);
for t = 1:tau
    ground_truth(:,t) = mvnrnd(mu(:,t),sigma(:,:,t));
end

%% Run
for timestep = 1:(end_time/delta_t)
    % Retrieve u (just 0 for now)
    u = zeros(1,tau);
    
    % Simulate dynamical model
    [ground_truth] = simulate_dynamics(ground_truth, u);

    % Simulate measurements
    [z, association_ground_truth] = simulate_measurements(ground_truth);
    
    % Do an iteration of JPDA Filter
    [mu, sigma] = iterate(mu, sigma, u, z);
end

%% Visualize results
% TODO: visualise results