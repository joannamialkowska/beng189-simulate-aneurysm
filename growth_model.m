function dydt = growth_model(t, y, risk_factors, MAP, onsetTime)
    % Extract current state variables
    d = y(1); % Diameter (cm)
    T = y(2); % Wall Thickness (mm)
    D = y(3); % Distensibility (mmHg^-1)

    % Before aneurysm onset, no changes occur
    if t < onsetTime
        dydt = [0; 0; 0];
        return;
    end

    % Wall stress (Laplace’s Law)
    sigma_w = (MAP * d) / (2 * T);

    % Upper limit for aneurysm diameter (intervention absolutely necessary)
    d_max = 8;  % cm

    k_d0 = 0.002;  % Slow initial growth (cm/year)
    k_d_max = 0.0010;  % Faster growth beyond 4 cm
    k_T = 0.0005;  % Slower wall thinning rate
    k_D = 0.0002;  % Slower distensibility decay

    % Growth starts slow and increases as aneurysm enlarges
    k_d = k_d0 + (k_d_max / (1 + exp(-10 * (d - 4.0))));

    % Risk Factor Modifications
    if risk_factors.age > 60
        k_d = k_d + 0.0002 * (t - onsetTime) / 10; % Gradual increase over 10 years
        k_D = k_D + 0.00005;
    end
    if strcmp(risk_factors.sex, 'male')
        k_d = k_d + 0.0003;
        k_T = k_T + 0.0002;
    end
    if strcmp(risk_factors.sex, 'female')
        k_d = k_d + 0.0004 * (t - onsetTime) / 10; % Women will grow aneurysm faster as they are older
        k_T = k_T + 0.0003; %Blood vessels age faster in women
    end
    if risk_factors.hypertension
        k_d = k_d + 0.0002 * (t - onsetTime) / 5; % Increase gradually over 5 years
        MAP = MAP + 10;  % More gradual MAP increase
    end
    if risk_factors.smoking
        k_d = k_d + 0.0001;
        k_D = k_D + 0.00005;
    end
    if risk_factors.family_history
        k_d = k_d + 0.00015;
        k_T = k_T + 0.00001;
    end
    if risk_factors.diabetes
        k_d = k_d - 0.0002;  % Protective effect
        k_T = k_T - 0.00001; % Protective effect
    end

    % **Diameter Growth (Slower and Delayed)**
    d_d = k_d * sigma_w * (1 - d / d_max);

    % **Wall Thickness Reduction (Slower)**
    sigma_threshold = 120; % Hypothetical stress threshold (mmHg)
    d_T = -k_T * max(0, sigma_w - sigma_threshold);

    % **Distensibility Decline (Slower)**
    d_D = -k_D * D;

    % **Prevent Shrinking Below Initial Size**
    if d < risk_factors.d0_init && d_d < 0
        d_d = 0;
    end

    dydt = [d_d; d_T; d_D];
end
