function clinical_decision(diameter, thickness, D, risk_factors)

sev = [0, 0, 0]; % Initialize severity scores
% Diameter scoring
if diameter < 3  
    sev(1) = 0;
elseif diameter <= 4.4
    sev(1) = 0.5;
elseif diameter <= 5.4
    sev(1) = 0.7;
else
    sev(1) = 0.9;
end

% Thickness scoring
if thickness >= 6
    sev(3) = 0.9;
elseif thickness >= 4
    sev(3) = 0.7;
elseif thickness >= 2.5
    sev(3) = 0.3;
end

% Distensibility scoring
if D < 0.002
    sev(2) = 0.4;
elseif D < 0.01
    sev(2) = 0.3;
end

% Compute severity level
totalSev = sum(sev);

if strcmp(risk_factors.sex, 'female') %Account for the fact that women are more at risk of rupture and complications with smaller aneurysms
    if totalSev > 0.6
        severity = "large aneurysm";
        rupture_risk = 0.23;
    elseif totalSev > 0.4
        severity = "medium aneurysm";
        rupture_risk = 0.20;
    elseif totalSev > 0.2
        severity = "small aneurysm";
        rupture_risk = 0.15;
    else
        severity = "healthy";
        rupture_risk = 0.0;
    end


else   
    if totalSev > 0.8
        severity = "large aneurysm";
        rupture_risk = 0.14;
    elseif totalSev > 0.6
        severity = "medium aneurysm";
        rupture_risk = 0.10;
    elseif totalSev > 0.3
        severity = "small aneurysm";
        rupture_risk = 0.09;
    else
        severity = "healthy";
        rupture_risk = 0.0;
    end

end

% Determine clinical decision based on severity
if strcmp(severity, 'small aneurysm')
  decision = 'Observation and routine monitoring recommended.';  
elseif strcmp(severity, 'medium aneurysm')
    decision = 'Close monitoring; consider intervention if growth accelerates.';
elseif strcmp(severity, 'large aneurysm')
    decision = 'Surgical intervention recommended.';
else
    decision = 'No clear recommendation.';
end

% Display clinical decision results
fprintf('Aneurysm Severity: %s\n', severity);
fprintf('Estimated Rupture Risk: %.2f%%\n', rupture_risk * 100);
fprintf('Clinical Decision: %s\n', decision);

end