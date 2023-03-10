% Load video
video = VideoReader(append('Data/traffic_top.mp4'));

% Retrieve measurements. We can preload them all since the video is
% prerecorded, but this can of course also be done real-time!
% This step might take a while because all frames have to be processed.
global delta_t
[z, delta_t, bboxes] = car_measurements(video,[0,450]);
n_timesteps = length(z);

%% Parameters
global F            % F matrix of dynamical model
global G            % G matrix of dynamical model
global H            % H matrix of measurement model
global R            % Covariance matrix of motion model | dimStates X dimStates
global Q            % Covariance matrix of measurement model | dimStates X dimStates
global tau          % Number of targets
global P_D          % Probability of a detection
global P_FA         % Probability of a false alarm

% Variables for N/M heuristic
global N            % How many samples to take before evaluation
global M_P          % Treshold for promotion
global M_D          % Treshold for demotion
global DeltaMax     % Max distance between first and second measurement for track birth

%% Initialize video
createVid = false;

if createVid
    saveVideo = VideoWriter('CarTrackingResults'); %open video file
    saveVideo.FrameRate = 25;
    open(saveVideo)
end

% Number of targets
tau = 0; % Start with 0 tracked objects. Don't change this!

% Define dynamical model
n_states = 4;              % Number of states of the dynamics model.
n_inp    = 1;              % Number of control inputs.
n_meas   = 2;              % Number of states of a measurement.
F = eye(n_states);
F(1,3) = delta_t;
F(2,4) = delta_t;
G = ones(n_states, n_inp);
H = eye(n_meas, n_states);

% Set values for JPDA parameters
R = 50*eye(n_states); % Take into account our states are in pixels
R(1:2,1:2) = 0.2*R(1:2,1:2);
Q = 200*eye(n_meas);
P_D = 0.8;
P_FA = 0.5;

% Set values for M/N heuristic
N = 8;
M_P = floor(P_D*N);
M_D = N-6;
DeltaMax = 20; % Pixels

% Initialise arrays
mu = zeros(n_states, tau);
sigma = zeros(n_states, n_states, tau);
mu_tentative = zeros(n_states, tau);
sigma_tentative = zeros(n_states, n_states, tau);
mu_new = zeros(n_states, tau);
c_tracker = zeros(N+1,tau);
t_tracker = zeros(N+1,tau);
IDList = 0;
maxID = 0;

% Set position of video
video.CurrentTime = 0;

figure('units','normalized','outerposition',[0 0 1 1])
for timestep = 1:n_timesteps
    disp("Frame Number: " + timestep)
    % Do an iteration of JPDA Filter for confirmed tracks
    tau = size(mu,2);

    u = zeros(n_inp,tau);
    [mu, sigma, ~, beta_auxillary, z_nc] = iterate(mu, sigma, u, z{timestep});

    % Remove targets that have died
    [~, purge, c_tracker] = check_promotion(beta_auxillary, c_tracker);
    
    if ~isempty(purge)
        mu = mu(:,setdiff(1:end,purge));
        sigma = sigma(:,:,setdiff(1:end,purge));
        c_tracker = c_tracker(:,setdiff(1:end,purge));
        IDList = IDList(setdiff(1:end,purge+1));
    end

    % Do an iteration of JPDA Filter for tentative tracks
    tau = size(mu_tentative,2);
    u = zeros(n_inp,tau);
    [mu_tentative, sigma_tentative, ~, beta_auxillary, z_nt] = iterate(mu_tentative, sigma_tentative, u, z_nc);
    
    % Promote tentative tracks that meet M/N to confirmed, purge otherwise
    [promote, purge, t_tracker] = check_promotion(beta_auxillary, t_tracker);
    mu = cat(2, mu, mu_tentative(:,promote));
    sigma = cat(3, sigma, sigma_tentative(:,:,promote));
    c_tracker = cat(2, c_tracker, zeros(N+1,length(promote)));
    if ~isempty(promote)
        IDList = [IDList, (maxID+1):(maxID+length(promote))];
        IDList = [0 IDList(IDList ~= 0)];
        maxID = max(IDList);
    end

    if ~isempty([purge, promote])
        mu_tentative = mu_tentative(:,setdiff(1:end,[purge, promote]));
        sigma_tentative = sigma_tentative(:,:,setdiff(1:end,[purge, promote]));
        t_tracker = t_tracker(:,setdiff(1:end,[purge, promote]));
    end
    
    % Promote new tracks that meet second measurement
    [mu_promoted, z_nn] = check_promotion_new(mu_new,z_nt);
    
    mu_tentative = cat(2, mu_tentative, mu_promoted);
    sigma_tentative = cat(3, sigma_tentative, repmat(1*R,[1,1,size(mu_promoted,2)]));
    tracker_init = zeros(N+1,1);
    tracker_init(end) = -1;
    t_tracker = cat(2, t_tracker, repmat(tracker_init,[1,size(mu_promoted,2)]));

    % Residual measurements are turned into new tracks
    mu_new = z_nn;

    % Plot new frame
    frame = readFrame(video);
    %frame = insertShape(frame, 'Rectangle', bboxes{timestep}, 'Color', 'green');
    text_str = cell(length(IDList)-1,1);
    for ii=2:length(IDList)
        text_str{ii-1} = ['ID: ' num2str(IDList(ii))];
    end

    clf(), hold on
    set(gca, 'YDir','reverse')
    set(gca,'DataAspectRatio',[1 1 1])
    
    xlim([0, 1920])
    ylim([0, 1080])

    if ~isempty(mu)
        frame = insertText(frame, mu(1:2,:)', text_str, 'FontSize',36,'BoxColor',...
            'yellow','BoxOpacity',0.8,'TextColor','black');
        image(frame)
    else
        image(frame)
    end
    
    if ~isempty(z{timestep})
        z_plot = scatter(z{timestep}(1,:), z{timestep}(2,:),200,'.','green');
    end

    
    if ~isempty(mu)
        mu_plot = scatter(mu(1,:), mu(2,:),200,'x','red');

        XData = zeros(100,tau);
        YData = zeros(100,tau);
        for t = 1:size(mu,2)
            [XData(:,t), YData(:,t)] = plotErrorEllipse(mu(1:2,t), sigma(1:2,1:2,t),0.9);
        end
        plot(XData,YData,'LineWidth',2,'Color',[1, 0, 0])
    end
    if ~isempty(mu_tentative)
        mu_plot = scatter(mu_tentative(1,:), mu_tentative(2,:),200,'x','magenta');
    end
    if ~isempty(mu_new)
        mu_plot = scatter(mu_new(1,:), mu_new(2,:),200,'x','cyan');
    end
    drawnow
    
    if createVid
        frame = getframe(gcf); %get frame
        writeVideo(saveVideo, frame);
    end
end

if createVid
    close(saveVideo)
end