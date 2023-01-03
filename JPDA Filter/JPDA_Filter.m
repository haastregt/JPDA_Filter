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
n_states = 3;              % Number of states of the dynamics model.
n_inp    = 1;              % Number of control inputs.
n_meas   = 3;              % Number of states of a measurement.
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

% Set initial estimate of target states
mu = map_size*(rand(n_states, tau)-0.5);

% Set initial estimate of covariances. Increase to start with less certainty
sigma = repmat(1*R,[1,1,tau]);

% Sample a ground truth for each target
ground_truth = zeros(n_states,tau);
for t = 1:tau
    ground_truth(:,t) = mvnrnd(mu(:,t),sigma(:,:,t));
end

% Initialize storage variables (Used for visualization purposes)
timestep_store = zeros(end_time/delta_t,1);
ground_truth_store = zeros(n_states,tau,end_time/delta_t);
mu_store = zeros(n_states,tau,end_time/delta_t);

%% Run
for timestep = 1:(end_time/delta_t)
    % Retrieve u (just 0 for now)
    u = zeros(n_inp,tau);
    
    % Simulate dynamical model
    [ground_truth] = simulate_dynamics(ground_truth, u);

    % Simulate measurements
    [z, association_ground_truth] = simulate_measurements(ground_truth);
    
    % Do an iteration of JPDA Filter
    [mu, sigma] = iterate(mu, sigma, u, z);

    % Store data for visualization purposes
    timestep_store(timestep) = timestep*delta_t;
    ground_truth_store(:,:,timestep) = ground_truth;
    mu_store(:,:,timestep) = mu;
end
%% Visualize results
% Plot ground truth alongside estimated states
figure(1)
hold on
grid on

plot(timestep_store, squeeze( ground_truth_store(1,:,:) ))
plot(timestep_store, squeeze( mu_store(1,:,:) ))

title('Ground truth')
xlabel('Time [s]')
ylabel('Position [m]')
legend('Target 1','Target 2', 'Estimated Target 1', 'Estimated Target 2')

