function [mu, sigma, beta] = gnn_iterate(mu, sigma, u, z)
    % This function performs one iteration of the GNN filter.
    % Inputs:
    %           mu(t-1)                   dimStates X tau
    %           sigma(t-1)                dimStates X dimStates X tau
    %           u                         nInputs X tau
    %           z                         dimMeasurements X nMeasurements
    % Outputs:
    %           mu(t)                     dimStates X tau
    %           sigma(t)                  dimStates X dimStates X tau

    % predict step
    [mu_bar, sigma_bar] = predict(mu, sigma, u);

    % associate step
    [z_opt, invalid] = gnn_associate(z, mu_bar, sigma_bar);

    % update step
    if invalid == 0
        [mu, sigma] = gnn_update(mu_bar, sigma_bar, z_opt);
    else
        mu = mu_bar;
        sigma = sigma_bar;
    end

end