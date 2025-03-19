function [d_values, T_values, D_values] = simulate_aneurysm(d0, T0, D0, tspan, risk_factors, Rs, Csa, onsetTime)
    % simulate_aneurysm: Simulates aneurysm growth based on hemodynamics and risk factors
    %
    % Inputs:
    %   d0, T0, D0  - Initial aneurysm parameters (diameter, thickness, distensibility)
    %   tspan       - Simulation time range (years)
    %   risk_factors- Struct with patient-specific risk factors
    %   Rs, Csa     - Systemic resistance and compliance
    %   onsetTime   - Stochastic onset time of aneurysm in years

    % Run cardiovascular system simulation
    [t_plot, QAo_plot, Psa_plot, MAP] = simulate_hemodynamics(Rs, Csa);

    % If aneurysm onset is after simulation period, exit early
    if onsetTime > tspan(2)
        fprintf('No aneurysm developed during the simulation period.\n');
        return;
    end

    % Adjust time span to start after onsetTime
    tspan_adjusted = [onsetTime, tspan(2)];

    % Solve aneurysm progression ODE from onsetTime onward
    [t, y] = solve_aneurysm_ode(d0, T0, D0, tspan, risk_factors, MAP, onsetTime);

    % Extract computed values
    d_values = y(:,1);  % Diameter
    T_values = y(:,2);  % Wall Thickness
    D_values = y(:,3);  % Distensibility

    % Find rupture time (first index where d reaches max)
    rupture_idx = find(d_values >= max(d_values), 1);
    ruptureTime = t(rupture_idx); % Corresponding time
    
    % Trim data to stop plotting at rupture
    t_trimmed = t(1:rupture_idx);
    d_trimmed = d_values(1:rupture_idx);
    T_trimmed = T_values(1:rupture_idx);
    D_trimmed = D_values(1:rupture_idx);
    
    % Plot results
    figure;
    
    % Diameter Progression
    subplot(3,1,1);
    plot(t_trimmed, d_trimmed, 'b', 'LineWidth', 1.5);
    title('Aneurysm Diameter Progression');
    ylabel('Diameter (cm)');
    grid on;
    hold on;
    xline(onsetTime, '--r', 'Onset'); % Mark aneurysm onset
    xline(ruptureTime, '--k', 'Probable Rupture'); % Mark rupture
    hold off;
    
    % Wall Thickness Change
    subplot(3,1,2);
    plot(t_trimmed, T_trimmed, 'r', 'LineWidth', 1.5);
    title('Wall Thickness Change');
    ylabel('Thickness (mm)');
    grid on;
    hold on;
    xline(onsetTime, '--r', 'Onset');
    xline(ruptureTime, '--k', 'Rupture');
    hold off;
    
    % Distensibility Decline
    subplot(3,1,3);
    plot(t_trimmed, D_trimmed, 'g', 'LineWidth', 1.5);
    title('Distensibility Decline');
    ylabel('Distensibility (mmHg^{-1})');
    xlabel('Time (years)');
    grid on;
    hold on;
    xline(onsetTime, '--r', 'Onset');
    xline(ruptureTime, '--k', 'Rupture');
    hold off;
