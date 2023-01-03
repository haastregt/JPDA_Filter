function [z, association_ground_truth] = simulate_measurements(ground_truth)
    global H
    global Q
    global tau
    global map_size
    global P_FA
    global P_D
    
    association_ground_truth = [];
    z = zeros(size(H,1), 0);
    for t = 1:tau
        detected = false;
        while ~detected
            if rand(1) < P_FA
                % False detections are simulated to be uniformly distributed within the map bounds
                false_detection = map_size*(rand(size(H,1))-0.5);
                z = [z, false_detection];
                association_ground_truth = [association_ground_truth, 0];
            else
                detected = true;
            end
        end
        
        if rand(1) < P_D
            detection = mvnrnd(ground_truth(:,t),Q);
            z = [z, detection];
            association_ground_truth = [association_ground_truth, t];
        end
    end
end