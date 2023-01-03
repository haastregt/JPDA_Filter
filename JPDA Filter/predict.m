function [mu_bar, sigma_bar] = predict(mu, sigma, u)
    % This function performs the prediction step of the Kalman Filter
    % Inputs:
    %           mu(t-1)           dimStatesXtau             | mean of each target
    %           sigma(t-1)        dimStatesXdimStatesXtau   | variance of each target
    %           u                 nInputsXtau               | input for each target
    % Outputs:   
    %           mu_bar(t)         dimStatesXtau             | predicted mean of each target
    %           sigma_bar(t)      dimStatesXdimStatesXtau   | predicted variance of each targetend

    global R
    global F
    global G

    mu_bar = F*mu + G*u;
    sigma_bar = F*sigma*F' + R;
end