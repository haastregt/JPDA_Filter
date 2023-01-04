function [mu, sigma, beta] = iterate(mu, sigma, u, z)
    % This function performs one iteration of the JPDA filter.
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
    [nu_bar, beta, beta_auxillary] = associate(z, mu_bar,sigma_bar);

    % update step
    [mu, sigma] = update(mu_bar, sigma_bar, beta, beta_auxillary, nu_bar);
end