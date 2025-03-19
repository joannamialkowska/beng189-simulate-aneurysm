function [t_plot, QAo_plot, Psa_plot, MAP] = simulate_hemodynamics(Rs, Csa)
% simulate_hemodynamics: Simulates cardiovascular dynamics (flow and pressure)
%
% Description:
%   Simulates the aortic flow (QAo) and systemic arterial pressure (Psa)
%   over multiple cardiac cycles. Also calculates Mean Arterial Pressure (MAP)
%   using the systolic and diastolic peaks found in Psa_plot.
%
% Inputs:
%   Rs  - Systemic resistance (mmHg/(L/min))
%   Csa - Systemic arterial compliance (L/mmHg)
%
% Outputs:
%   t_plot   - Vector of time points for the simulation (min)
%   QAo_plot - Simulated aortic flow at each time point (L/min)
%   Psa_plot - Simulated systemic arterial pressure at each time point (mmHg)
%   MAP      - Mean Arterial Pressure (mmHg), computed as:
%              MAP = DBP + (1/3) * (SBP - DBP)
%
% Global variables used:
%   T, TS, TMAX, QMAX, dt

    T =0.0125;    %Duration of heartbeat (minutes)
    TS=0.0050;    %Duration of systole   (minutes)
    TMAX=0.0020;  %Time at which flow is max (minutes)
    QMAX=28.0;    %Max flow through aortic valve (liters/minute)

    % Initialize time step and number of simulation iterations:
    dt = 0.01 * T;    % Base time step as a fraction of the heartbeat duration
    dt = dt * 4;      % Adjust time step (resulting in 25 time steps per cycle)
    klokmax = 30 * T / dt;  % Total number of time steps for 30 cardiac cycles

    % Initialize pressure (Psa) at time zero:
    Psa = 0;

    % Preallocate arrays for speed:
    t_plot = zeros(1, klokmax);   % Time vector
    QAo_plot = zeros(1, klokmax);   % Aortic flow values over time
    Psa_plot = zeros(1, klokmax);   % Systemic arterial pressure values over time

    % Simulation loop: Compute QAo and Psa at each time step
    for klok = 1:klokmax
        t = klok * dt;           % Current time point
        QAo = QAo_now(t, T, TS, TMAX, QMAX);        % Compute aortic flow using an external function
        Psa = Psa_new(Psa, QAo, Rs, Csa, dt); % Update systemic arterial pressure using an external function
        t_plot(klok) = t;        % Save time point
        QAo_plot(klok) = QAo;    % Save flow value
        Psa_plot(klok) = Psa;    % Save pressure value
    end

    % Check that the pressure array has sufficient data points for later use
    if isempty(Psa_plot) || numel(Psa_plot) < 2
        error('Psa_plot is empty or has too few points! Simulation failed.');
    end

    % Find systolic and diastolic peaks in pressure signal
    [sys_peaks, sys_idx] = findpeaks(Psa_plot);    % Systolic peaks (maxima)
    [dias_peaks, dias_idx] = findpeaks(-Psa_plot); % Diastolic peaks (minima, negated)

    % Ensure diastolic indices match real values
    dias_peaks = -dias_peaks;

    % Compute Mean Arterial Pressure (MAP)
    if ~isempty(sys_peaks) && ~isempty(dias_peaks)
        SBP = mean(sys_peaks);  % Average Systolic Blood Pressure
        DBP = mean(dias_peaks); % Average Diastolic Blood Pressure
        MAP = DBP + (1/3) * (SBP - DBP);
    else
        warning('Could not find sufficient systolic/diastolic peaks. Using default MAP.');
        MAP = mean(Psa_plot); % Fallback to average pressure if peak detection fails
    end

    % Plot the simulated aortic flow and pressure curves
    figure;
    subplot(2,1,1);
    plot(t_plot, QAo_plot, 'LineWidth', 1.5);
    title('Flow QAo(t)');
    xlabel('Time (min)');
    ylabel('Flow (L/min)');

    subplot(2,1,2);
    plot(t_plot, Psa_plot, 'LineWidth', 1.5);
    title('Pressure Psa(t)');
    xlabel('Time (min)');
    ylabel('Pressure (mmHg/min)');

    % Highlight systolic and diastolic peaks
    hold on;
    plot(t_plot(sys_idx), sys_peaks, 'o', 'MarkerSize', 6, 'MarkerEdgeColor', 'r'); % Red circles for systolic
    plot(t_plot(dias_idx), dias_peaks, 'x', 'MarkerSize', 6, 'MarkerEdgeColor', 'b'); % Blue crosses for diastolic
    hold off;

    % Print results
    fprintf("Mean Arterial Pressure (MAP) = %.2f mmHg\n", MAP);
    fprintf("Average Systolic Pressure (SBP) = %.2f mmHg\n", SBP);
    fprintf("Average Diastolic Pressure (DBP) = %.2f mmHg\n", DBP);
end

