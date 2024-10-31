% Satellite Power Usage Simulation
%
% The purpose of this simulation is to look at the power generation and power usage of a satellite.
% In this example simpifies a lot of areas, as to act as a base for more complicated systems.
%
%
% Author: William Avison
% Date: July 2024
% Description:
%   This simulation considers these power-consuming subsystems:
%       - Payload
%       - Communication (radios)
%       - On Board Computer
%       - Attitude Orbit Control System
%
% Parameters:
%   - simulation_time: Total simulation time in seconds
%   - time_step: Time step for the simulation in seconds
%
% Outputs:
%   - Battery charge levels over time
%   - Graphs showing power consumption and generation

% Simulation parameters
simulation_time = 86400; % 24 hours in seconds
time_step = 60;          % 1 minute step
time_vector = 0:time_step:simulation_time; % time array
num_steps = length(time_vector);

% Power usage of subsystems & payload (in Watts)
payload_power = 50;
comms_power = 30;
obc_power = 10;
aocs_power = 20;

% Total power consumption (assumes subsystems are all active for simplicity)
total_power_usage = payload_power + comms_power + obc_power + attitude_control_power;

% Solar power generation (in Watts)
solar_power = 100; % Assume constant for simplicity

% Battery parameters
battery_capacity = 500; % Wh, battery max capacity
battery_charge = 500;   % Wh, initial battery charge
battery_charge_history = zeros(1, num_steps);

% Orbit parameters
eclipse_fraction = 0.4; % Fraction of orbit in eclipse
in_sunlight = true;

% Simulation loop
for t = 1:num_steps
    % Determine if satellite is in sunlight or eclipse
    if mod(time_vector(t), 6000) < (1 - eclipse_fraction) * 6000
        in_sunlight = true;
    else
        in_sunlight = false;
    end

    % Power generation and battery charge
    if in_sunlight
        % Solar power is available; battery charges if excess power
        net_power = solar_power - total_power_usage;
        if net_power > 0
            battery_charge = min(battery_charge + (net_power * time_step / 3600), battery_capacity);
        else
            battery_charge = battery_charge + (net_power * time_step / 3600);
        end
    else
        % In eclipse, battery discharges
        battery_charge = battery_charge - (total_power_usage * time_step / 3600);
    end

    % Record battery charge history
    battery_charge_history(t) = battery_charge;

    % Check for battery depletion
    if battery_charge <= 0
        disp(['Battery depleted at t = ', num2str(time_vector(t)/3600), ' hours']);
        break;
    end
end

% Plot results
figure;
subplot(2, 1, 1);
plot(time_vector / 3600, battery_charge_history);
xlabel('Time (hours)');
ylabel('Battery Charge (Wh)');
title('Satellite Battery Charge over Time');
grid on;

subplot(2, 1, 2);
plot(time_vector / 3600, total_power_usage * ones(1, num_steps), 'r', 'DisplayName', 'Power Consumption');
hold on;
plot(time_vector / 3600, solar_power * ones(1, num_steps), 'b', 'DisplayName', 'Solar Power Generation');
xlabel('Time (hours)');
ylabel('Power (W)');
title('Satellite Power Usage and Generation');
legend;
grid on;

