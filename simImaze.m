function [TDs,Vs_whole] = simImaze(p_alpha,p_gamma,rew_size,num_trial,decay_paras)

% [TDs,Vs_whole] = simImaze(p_alpha,p_gamma,rew_size,num_trial,decay_paras)
%
% <input variables>
%	p_alpha: learning rate (0 <= p_alpha <= 1)
%	p_gamma: time discount factor (per time step) (0 <= p_gamma <= 1)
%	rew_size: reward size (reward amount)
%	num_trial: number of trials
%	decay_paras: parameters for the decay of learned values ([kappa1, kappa2] defined in the paper (Morita and Kato, 2014))
%   	decay_paras(1): (1:no decay, 0:full decay)
%       decay_paras(2): magnitude-dependence of the rate of decay ("decay_paras(2)=inf" means constant rate)
%
% <output variable>
%   TDs: TD error at each time step for all the trials
%   Vs_whole: learned values of all the states evaluated at the end of each trial
%
% Morita K and Kato A (2014)
% Striatal dopamine ramping may indicate flexible reinforcement learning with forgetting in the cortico-basal ganglia circuits.
% Front. Neural Circuits 8:36. doi:10.3389/fncir.2014.00036
%
% Copyright: Kenji Morita (2014)

% number of time steps (states)
num_tstep = 7; % number of time steps within each trial
rew_tstep = num_tstep; % index of the time step in which reward is given in rewrad-present trials (1 <= rew_tstep <= num_tstep)

% reward
Rs = zeros(num_trial,num_tstep); % reward at each state (time step) for all the trials, initialization
Rs(:,rew_tstep) = rew_size;

% variables
TDs = zeros(num_trial,num_tstep); % TD error at each time step for all the trials, initialization
Vs_whole = zeros(num_trial,num_tstep); % learned values of all the states evaluated at the end of each trial, initialization
Vs_latest = zeros(1,num_tstep); % latest (i.e., updated at each time step) learned values of all the states, initialization

% run simulation
for k_trial = 1:num_trial
    
    % initial time step
    k_tstep = 1;
    TDs(k_trial,k_tstep) = Rs(k_trial,k_tstep) + p_gamma * Vs_latest(k_tstep) - 0; % TD error (NB: value of the 'preceding state' is assumed to be 0)
    Vs_latest = Vs_latest .* ((1 - (1 - decay_paras(1))*exp(-Vs_latest/decay_paras(2))) .^ (1/num_tstep)); % decay
    
    % afterward
    for k_tstep = 2:num_tstep
        TDs(k_trial,k_tstep) = Rs(k_trial,k_tstep) + p_gamma * Vs_latest(k_tstep) - Vs_latest(k_tstep-1); % TD error
        Vs_latest(k_tstep-1) = Vs_latest(k_tstep-1) + p_alpha * TDs(k_trial,k_tstep); % update of state values
        Vs_latest = Vs_latest .* ((1 - (1 - decay_paras(1))*exp(-Vs_latest/decay_paras(2))) .^ (1/num_tstep)); % decay
    end
    
    % copy Vs_latest to Vs_whole
    Vs_whole(k_trial,:) = Vs_latest;
    
end
