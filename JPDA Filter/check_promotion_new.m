function [mu_promoted, z_nn] = check_promotion_new(mu_new, z_nt)
    % This function checks if a new track can be promoted to a tentative track
    % This happens if a second measurement is made that is close enough

    global DeltaMax
    global delta_t
    
    if isempty(z_nt)
        mu_promoted = zeros(4,0);
        z_nn = zeros(size(z_nt));
    else
        % To account for dimensionality
        treshold = DeltaMax^(size(mu_new,1));
    
        distance = zeros(size(mu_new,2),size(z_nt,2));
        for t = 1:size(mu_new,2)
            distance(t,:) = sum(abs(mu_new(:,t)-z_nt).^2,1);
        end
        [closest, ind] = min(distance,[],2);
        promoted = ind(closest < treshold);
    
        mu_promoted(1:2,:) = z_nt(:,promoted);
        mu_promoted(3:4,:) = zeros(size(z_nt(:,promoted)));
        if isempty(promoted)
            z_nn = z_nt;
        else
            z_nn = z_nt(:,~promoted);
        end
    end
%     if isempty(z_nt)
%         mu_promoted = zeros(4,0);
%         z_nn = zeros(size(z_nt));
%     else
%         % To account for dimensionality
%         treshold = DeltaMax^(size(mu_new,1));
%     
%         distance = zeros(size(mu_new,2),size(z_nt,2));
%         for t = 1:size(mu_new,2)
%             distance(t,:) = sum(abs(mu_new(:,t)-z_nt).^2,1);
%         end
%         [closest, ind] = min(distance,[],2);
%         promoted_z = ind(closest < treshold);
%         promoted_mu = closest < treshold;
% 
%         mu_promoted(1:2,:) = z_nt(:,promoted_z);
%         mu_promoted(3:4,:) = (z_nt(:,promoted_z)-mu_new(:,promoted_mu))./delta_t;
%         if isempty(promoted_z)
%             z_nn = z_nt;
%         else
%             z_nn = z_nt(:,~promoted_z);
%         end
%     end
end

