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
n_timesteps = end_time/delta_t + 1;

%% Initialise
% Define dynamical model: random walk (can be made more complicated)
n_states = 1;              % Number of states of the dynamics model.
n_inp    = 1;              % Number of control inputs.
n_meas   = 1;              % Number of states of a measurement.
F = eye(n_states);
G = ones(n_states, n_inp);
H = eye(n_meas, n_states);

% Set values for JPDA parameters
R = 0.02*eye(n_states);
Q = 0.02*eye(n_meas);
P_D = 0.9;
P_FA = 0.1;

% Set the bounds of the map
map_size = 6;

% Number of targets
tau = 3;

% Initialise arrays to store each timestep for plotting
ground_truth = zeros(n_states,tau,n_timesteps);
mu = zeros(n_states,tau,n_timesteps);
sigma = zeros(n_states,n_states,tau,n_timesteps);
% Cell arrays can have variable lengths for each timestep
z = cell(n_timesteps,1); 
association_ground_truth = cell(n_timesteps,1);

% Set initial estimate of target states
mu(:,:,1) = map_size*(rand(n_states, tau)-0.5);

% Set initial estimate of covariances. Increase to start with less certainty
sigma(:,:,:,1) = repmat(1*R,[1,1,tau]);

% Sample a ground truth for each target
for t = 1:tau
    ground_truth(:,t,1) = mvnrnd(mu(:,t,1),sigma(:,:,t,1));
end

%% Run
for timestep = 2:n_timesteps
    % Retrieve u (just 0 for now)
    u = zeros(n_inp,tau);
    
    % Simulate dynamical model
    [ground_truth(:,:,timestep)] = simulate_dynamics(ground_truth(:,:,timestep-1), u);

    % Simulate measurements
    [z{timestep}, association_ground_truth{timestep}] = simulate_measurements(ground_truth(:,:,timestep));
    
    % Do an iteration of JPDA Filter
    [mu(:,:,timestep), sigma(:,:,:,timestep)] = iterate(mu(:,:,timestep-1), sigma(:,:,:,timestep-1), u, z{timestep});

    % Store data for visualization purposes
    %timestep_store(timestep) = timestep*delta_t;
    %ground_truth_store(:,:,timestep) = ground_truth;
    %mu_store(:,:,timestep) = mu;
end

%% Visualize results
timesteps = 0:delta_t:end_time;

figure(1), clf(1), hold on
legendstrings = [];
for t = 1:tau
    plot(timesteps,squeeze(ground_truth(1,t,:)))
    plot(timesteps,squeeze(mu(1,t,:)))
    legendstrings = [legendstrings, "ground truth target " + num2str(t), "estimate target" + num2str(t)];
end
xlabel("Time (s)");
ylabel("x");
title("1D random walk with " + num2str(tau) + " targets");
legend(legendstrings)
hold off

