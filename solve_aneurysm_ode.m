function [t, y] = solve_aneurysm_ode(d0, T0, D0, tspan, risk_factors, MAP, onsetTime)
    % solve_aneurysm_ode: Simulates aneurysm progression with stochastic onset.
    %
    % Inputs:
    %   d0, T0, D0   - Initial aneurysm parameters.
    %   tspan        - Simulation time range (years).
    %   risk_factors - Patient-specific risk factors (must include d0_init).
    %   MAP          - Mean arterial pressure (mmHg).
    %   onsetTime    - Time at which aneurysm growth begins (years).
    %
    % Outputs:
    %   t - Time points of simulation.
    %   y - Matrix of state variables over time [d; T; D].
    
    % Include initial diameter in risk_factors for later clamping
    risk_factors.d0_init = d0;
    
    % Initial conditions
    y0 = [d0, T0, D0];

    % Solve ODE using ode45 with the updated growth model
    [t, y] = ode45(@(t, y) growth_model(t, y, risk_factors, MAP, onsetTime), tspan, y0);
end
