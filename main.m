% main.m
clear; clc; close all;

% Define patient-specific risk factors
risk_factors.age = 65;
risk_factors.sex = 'female';
risk_factors.hypertension = true;
risk_factors.smoking = true;
risk_factors.family_history = true;
risk_factors.diabetes = true;

% Flag to indicate whether the patient already has an aneurysm
hasAneurysm = true;

% Set systemic hemodynamic parameters
Rs = 17.86;    % Systemic resistance (mmHg/(L/min)) (nominal)
Csa = 0.0011;  % Systemic arterial compliance (L/mmHg)

% Define simulation time span (years)
tspan = [0 30];

if tspan(2) + risk_factors.age > 110
    error('Simulation span exceeds possible lifespan. Please reduce simulation time given patient age.')
end

% If the patient already has an aneurysm, use preset initial conditions.
% Otherwise, simulate a random onset time for aneurysm formation.
if hasAneurysm
    % Patient already has an aneurysm: use given initial conditions.
    d0 = 3.0;   % Initial diameter (cm)
    T0 = 0.75;   % Initial wall thickness (mm)
    D0 = 0.01;  % Initial distensibility (mmHg^-1)
    onsetTime = 0; % Aneurysm exists from the start.
else
    % Patient does not have an aneurysm initially.
    % Determine a random onset time based on risk factors.
    % For example, assume that higher risk increases the probability of earlier onset.
    % Here we use a simple exponential model.
    
    % Define a baseline rate (lambda) of aneurysm formation.
    % You can adjust this rate based on risk factors.
    lambda = 0.1; % baseline formation rate (per year)
    if strcmp(risk_factors.sex, 'male')
        lambda = lambda * 4;
    end
    if risk_factors.hypertension
        lambda = lambda * 1.5;
    end
    if risk_factors.smoking
        lambda = lambda * 1.5;
    end
    if risk_factors.family_history
        lambda = lambda * 1.4;
    end
    if risk_factors.age > 60
        lambda = lambda * 1.3;
    end
    
    % Draw a random waiting time from an exponential distribution:
    onsetTime = exprnd(1/lambda);
    
    % Define initial aneurysm conditions upon onset (these may be small)
    d0 = 1.5;   % initial small diameter (cm)
    T0 = 2.4;   % initial wall thickness (mm)
    D0 = 0.012; % initial distensibility (mmHg^-1)
    
    fprintf('Aneurysm onset simulated at %.2f years.\n', onsetTime);
end

% Run the simulation
[d_values, T_values, D_values] = simulate_aneurysm(d0, T0, D0, tspan, risk_factors, Rs, Csa, onsetTime);

clinical_decision(d_values(end), T_values(end), D_values(end), risk_factors)

