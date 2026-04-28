%% ================================================================
%  Probabilistic Power Model (PPM) for Wind Energy
%  Based on: Weibull Distribution + Piecewise Power Curve
%  Reference: Teyabeen et al. (2017, 2018), Zhang et al. (2014)
%% ================================================================
clear; clc; close all;

%% ============================================================
%  SECTION 1: WEIBULL DISTRIBUTION PARAMETERS (k and c)
%  ---------------------------------------------------------
%  k = shape parameter (Weibull modulus)
%     - Reflects the breadth of wind speed distribution
%     - k = 1   → Exponential distribution (random failures)
%     - k = 2   → Rayleigh distribution (typical wind scenario)
%     - k = 3.4 → Approximately Normal distribution
%     - Default k = 2 is used for general wind modeling
%     Source: HOMER Energy / Stevens & Smulders (1979)
%
%  c = scale parameter (characteristic wind speed, m/s)
%     - Determines the "spread" of the distribution
%     - Directly proportional to mean wind speed
%     - 63.2% of cumulative distribution is reached at v = c
%     Source: Weibull distribution theory
%
%  Egypt (Gulf of Suez) typical values:
%     k ≈ 2.0 – 2.5   (relatively stable trade winds)
%     c ≈ 9 – 11 m/s  (world-class wind resource)
%% ============================================================

k = 2.0;        % Shape parameter (dimensionless)
c = 8.0;       % Scale parameter (m/s) — Gulf of Suez / Zafarana

%% ============================================================
%  SECTION 2: TURBINE POWER CURVE PARAMETERS
%  ---------------------------------------------------------
%  The power curve is a piecewise function with 4 regions:
%
%  Region 1 — Below cut-in:   P(v) = 0              for v < v_ci
%  Region 2 — Cubic region:   P(v) = Pf(v)           for v_ci ≤ v < v_r
%             (Power ∝ v³, nonlinear increase)
%  Region 3 — Rated region:   P(v) = P_r (constant)  for v_r ≤ v < v_co
%             (Blade pitch control limits output)
%  Region 4 — Cut-out:        P(v) = 0              for v ≥ v_co
%             (Turbine shuts down to prevent structural damage)
%
%  Source: Teyabeen et al. (2017) — Mathematical Modelling of
%          Wind Turbine Power Curve
%% ============================================================

v_ci = 3;       % Cut-in speed  (m/s)  — turbine starts generating
v_r  = 12;      % Rated speed   (m/s)  — turbine reaches max power
v_co = 25;      % Cut-out speed (m/s)  — turbine shuts down
P_r  = 2000;    % Rated power   (kW)   — nameplate capacity (2 MW)

%% ============================================================
%  SECTION 3: WEIBULL PROBABILITY DENSITY FUNCTION
%  ---------------------------------------------------------
%  f(v) = (k/c) * (v/c)^(k-1) * exp(-(v/c)^k)
%
%  This represents the probability of wind speed v occurring.
%  Source: Harris & Cook (2014), Zhang et al. (2014)
%% ============================================================

v = linspace(0, 40, 2000);   % Wind speed vector (m/s)

f_v = (k ./ c) .* (v ./ c).^(k - 1) .* exp(-(v ./ c).^k);

%% ============================================================
%  SECTION 4: PIECEWISE TURBINE POWER CURVE — P(v)
%  ---------------------------------------------------------
%  Cubic region formula (Region 2):
%      P(v) = P_r * (v^3 - v_ci^3) / (v_r^3 - v_ci^3)
%
%  This gives the cubic (nonlinear) increase in power
%  proportional to v^3 between cut-in and rated speed.
%  Source: Teyabeen et al. (2017, 2018)
%% ============================================================

P_v = zeros(size(v));

for i = 1:length(v)
    if v(i) < v_ci
        % Region 1: Below cut-in — no power generated
        P_v(i) = 0;

    elseif v(i) >= v_ci && v(i) < v_r
        % Region 2: Cubic operating region
        % Power increases proportionally to v^3
        P_v(i) = P_r * (v(i)^3 - v_ci^3) / (v_r^3 - v_ci^3);

    elseif v(i) >= v_r && v(i) < v_co
        % Region 3: Rated region — constant maximum output
        P_v(i) = P_r;

    else
        % Region 4: Above cut-out — turbine shut down
        P_v(i) = 0;
    end
end

%% ============================================================
%  SECTION 5: EXPECTED POWER OUTPUT — E[P]
%  ---------------------------------------------------------
%  The Probabilistic Power Model (PPM) maps the Weibull PDF
%  through the turbine power curve:
%
%  E[P] = ∫ P(v) * f(v) dv   (from v_in to v_out)
%
%  Because of the piecewise (discontinuous) nature of P(v),
%  this integral is solved NUMERICALLY using the trapz method.
%
%  Source: Zhang et al. (2014), Probabilistic Power Model doc
%% ============================================================

E_P = trapz(v, P_v .* f_v);

fprintf('========================================\n');
fprintf('  PROBABILISTIC POWER MODEL RESULTS\n');
fprintf('========================================\n');
fprintf('Weibull k = %.2f,  c = %.2f m/s\n', k, c);
fprintf('Turbine: P_r=%.0f kW, v_ci=%.0f, v_r=%.0f, v_co=%.0f m/s\n', P_r, v_ci, v_r, v_co);
fprintf('----------------------------------------\n');
fprintf('Expected Power Output  E[P] = %.4f kW\n', E_P);

%% ============================================================
%  SECTION 6: VARIANCE AND STANDARD DEVIATION
%  ---------------------------------------------------------
%  Var[P] = E[P^2] - (E[P])^2
%
%  E[P^2] = ∫ P(v)^2 * f(v) dv
%% ============================================================

E_P2  = trapz(v, (P_v.^2) .* f_v);
Var_P = E_P2 - E_P^2;
Std_P = sqrt(Var_P);

fprintf('Variance               Var[P] = %.4f kW^2\n', Var_P);
fprintf('Standard Deviation     Std[P] = %.4f kW\n',  Std_P);

%% ============================================================
%  SECTION 7: CAPACITY FACTOR (CF)
%  ---------------------------------------------------------
%  CF_pdf = E_out / (P_r × T)
%
%  Since E[P] already represents average power (kW), and
%  P_r is rated power (kW):
%
%  CF = E[P] / P_r
%
%  CF shows the turbine's utilization — NOT mechanical efficiency.
%  Gulf of Suez: typical CF = 50–55% (world-class site)
%  Source: Wind_Energy_Concepts.docx, Probabilistic_Power_Model.pdf
%% ============================================================

CF = E_P / P_r;
AEP = E_P * 8760 / 1000;   % Annual Energy Production (MWh/year)

fprintf('Capacity Factor        CF     = %.4f (%.2f%%)\n', CF, CF * 100);
fprintf('Annual Energy Prod.    AEP    = %.2f MWh/year\n', AEP);
fprintf('========================================\n');

%% ============================================================
%  SECTION 8: MONTE CARLO SIMULATION
%  ---------------------------------------------------------
%  Generate N random wind speeds from the Weibull distribution
%  using the inverse CDF method:
%
%       v = c * (-ln(U))^(1/k),   where U ~ Uniform(0,1)
%
%  Then compute power for each sample and average.
%  Monte Carlo captures the full stochastic variability of
%  wind and improves estimation reliability.
%  Source: Rubinstein & Kroese (2016)
%% ============================================================

N = 100000;   % Number of Monte Carlo samples

% Generate Weibull-distributed wind speeds via inverse CDF
U    = rand(1, N);
v_mc = c .* (-log(U)).^(1 / k);

% Apply piecewise power curve to each sample
P_mc = zeros(1, N);
for i = 1:N
    if v_mc(i) < v_ci || v_mc(i) >= v_co
        P_mc(i) = 0;
    elseif v_mc(i) >= v_ci && v_mc(i) < v_r
        P_mc(i) = P_r * (v_mc(i)^3 - v_ci^3) / (v_r^3 - v_ci^3);
    else
        P_mc(i) = P_r;
    end
end

E_P_MC  = mean(P_mc);
Var_MC  = var(P_mc);
CF_MC   = E_P_MC / P_r;
AEP_MC  = E_P_MC * 8760 / 1000;

fprintf('\n--- Monte Carlo Results (N = %d samples) ---\n', N);
fprintf('MC Expected Power      = %.4f kW\n',       E_P_MC);
fprintf('MC Variance            = %.4f kW^2\n',     Var_MC);
fprintf('MC Capacity Factor     = %.4f (%.2f%%)\n', CF_MC, CF_MC * 100);
fprintf('MC Annual Energy Prod. = %.2f MWh/year\n', AEP_MC);
fprintf('========================================\n');

%% ============================================================
%  SECTION 9: PLOTS
%% ============================================================

figure('Name', 'Probabilistic Power Model - Wind Energy', ...
       'NumberTitle', 'off', 'Position', [100, 100, 1000, 750]);

% --- Plot 1: Weibull PDF ---
subplot(2, 2, 1);
plot(v, f_v, 'b-', 'LineWidth', 2.5);
xlabel('Wind Speed v (m/s)');
ylabel('Probability Density f(v)');
title(sprintf('Weibull PDF  (k = %.1f,  c = %.1f m/s)', k, c));
grid on; xlim([0 30]);
xline(mean(v_mc), 'r--', 'LineWidth', 1.5, ...
      'Label', sprintf('Mean = %.1f m/s', mean(v_mc)));

% --- Plot 2: Turbine Power Curve (4 regions) ---
subplot(2, 2, 2);
plot(v, P_v, 'r-', 'LineWidth', 2.5);
xline(v_ci, 'k--', 'LineWidth', 1.5, 'Label', 'Cut-in');
xline(v_r,  'g--', 'LineWidth', 1.5, 'Label', 'Rated');
xline(v_co, 'm--', 'LineWidth', 1.5, 'Label', 'Cut-out');
xlabel('Wind Speed v (m/s)');
ylabel('Power Output P(v) (kW)');
title('Piecewise Turbine Power Curve — 4 Regions');
legend('P(v)', 'v_{ci}=3', 'v_r=12', 'v_{co}=25', 'Location', 'east');
grid on; xlim([0 30]); ylim([-100, P_r * 1.15]);

% --- Plot 3: Power-Weighted PDF (Integrand of E[P]) ---
subplot(2, 2, 3);
area(v, P_v .* f_v, 'FaceColor', [0.5 0.2 0.8], 'FaceAlpha', 0.5, ...
     'EdgeColor', [0.3 0.1 0.6], 'LineWidth', 1.5);
xlabel('Wind Speed v (m/s)');
ylabel('P(v) \cdot f(v)  (kW)');
title(sprintf('Power-Weighted PDF — E[P] = %.1f kW  |  CF = %.1f%%', E_P, CF*100));
grid on; xlim([0 30]);

% --- Plot 4: Monte Carlo Power Distribution ---
subplot(2, 2, 4);
histogram(P_mc, 80, 'Normalization', 'probability', ...
          'FaceColor', [0.2 0.6 0.9], 'EdgeColor', 'white');
xline(E_P_MC, 'r-', 'LineWidth', 2, ...
      'Label', sprintf('E[P] = %.0f kW', E_P_MC));
xlabel('Power Output (kW)');
ylabel('Probability');
title(sprintf('Monte Carlo Distribution  (N = %d)', N));
grid on;

sgtitle('Probabilistic Power Model (PPM) — Wind Turbine Analysis', ...
        'FontSize', 14, 'FontWeight', 'bold');