function [Choices,TDs,Vs_whole] = simTmaze(free_or_not,RLmodel,p_alpha,p_beta,p_gamma,rew_S8,rew_S9,num_trial,decay_paras,rands_for_choice)

% [Choices,TDs,Vs_whole] = simTmaze(free_or_not,RLmodel,p_alpha,p_beta,p_gamma,rew_S8,rew_S9,num_trial,decay_paras,rands_for_choice);
%
% <input variables>
%   free_or_not: 1:free-choice, 0:forced-choice
%   RLmodel: 'Q':Q-learning, 'S':SARSA
%   p_alpha: learning rate (0 <= p_alpha <= 1)
%   p_beta: slope of the choice sigmoid (inverse temperature)
%   p_gamma: time discount factor (per time step) (0 <= p_gamma <= 1)
%   rew_S8: assumed amount of reward at S8
%   rew_S9: assumed amount of reward at S9
%   num_trial: number of trials
%	decay_paras: parameters for the decay of learned values ([kappa1, kappa2] defined in the paper (Morita and Kato, 2014))
%   rands_for_choice: random numbers used for choice
%
% <output variable>
%   Choices: index (# of A#) of the chosen action for all the trials
%   TDs: TD error at each time step for all the trials
%   Vs_whole: learned values of all the actions (state-action pairs) evaluated at the end of each trial
%
% Morita K and Kato A (2014)
% Striatal dopamine ramping may indicate flexible reinforcement learning with forgetting in the cortico-basal ganglia circuits.
% Front. Neural Circuits 8:36. doi:10.3389/fncir.2014.00036
%
% Copyright: Kenji Morita & Ayaka Kato (2014)

% random numbers used for choice
if isempty(rands_for_choice)
	rand('twister',sum(100*clock)); % set 'rand' to a different initial state everytime
	rands_for_choice = rand(num_trial,1); % random numbers used to make random choices
end

% number of time steps, states, and actions (state-action pairs)
num_tstep = 25;
num_state = 30;
num_action = 31;

% reward
Rs = zeros(num_trial,num_state); % reward at each state for all the trials, initialization
Rs(:,8) = rew_S8;
Rs(:,9) = rew_S9;

% variables
Choices = zeros(num_trial,1); % index (# of A#) of the chosen action for all the trials, initialization
TDs = zeros(num_trial,num_tstep); % TD error at each time step for all the trials, initialization
Vs_whole = zeros(num_trial,num_action); % learned values of all the actions (state-action pairs) evaluated at the end of each trial, initialization
Vs_latest = zeros(1,num_action); % latest (i.e., updated at each time step) learned values of all the actions (state-action pairs), initialization

% run simulation
for k_trial = 1:num_trial
    
    % at S1
    k_tstep = 1;
    current_state = 1; % index (# of S#) of the current state
	current_action = 1; % index (# of A#) of the current action
	previous_action = num_action; % index (# of A#) of the previous action
    TDs(k_trial,k_tstep) = Rs(k_trial,current_state) + p_gamma * Vs_latest(current_action) - Vs_latest(previous_action); % TD error
    Vs_latest(previous_action) = Vs_latest(previous_action) + p_alpha * TDs(k_trial,k_tstep); % update of the value of the previous action
    Vs_latest = Vs_latest .* ((1 - (1 - decay_paras(1))*exp(-Vs_latest/decay_paras(2))) .^ (1/num_tstep)); % decay
    
    % at S2,3,4
    for k_tstep = 2:4
        current_state = k_tstep; % index (# of S#) of the current state
        current_action = current_state; % index (# of A#) of the current action
        previous_action = current_state - 1; % index (# of A#) of the previous action
        TDs(k_trial,k_tstep) = Rs(k_trial,current_state) + p_gamma * Vs_latest(current_action) - Vs_latest(previous_action); % TD error
        Vs_latest(previous_action) = Vs_latest(previous_action) + p_alpha * TDs(k_trial,k_tstep); % update of the value of the previous action
        Vs_latest = Vs_latest .* ((1 - (1 - decay_paras(1))*exp(-Vs_latest/decay_paras(2))) .^ (1/num_tstep)); % decay
    end
    
    % at S5
    k_tstep = 5;
    current_state = 5; % index (# of S#) of the current state
    if free_or_not % free-choice
        prob_chooseA5 = 1 / ( 1 + exp(- p_beta * (Vs_latest(5) - Vs_latest(6)))); % probability of choosing action A5
        Choices(k_trial) = 6 - (rands_for_choice(k_trial) <= prob_chooseA5); % index (# of A#) of the chosen action (5 or 6)
    else % forced-choice
        Choices(k_trial) = 5 + (rands_for_choice(k_trial) <= 0.5); % random forced-choice
    end
    previous_action = current_state - 1; % index (# of A#) of the previous action
    if RLmodel == 'Q' % Q-learning
        TDs(k_trial,k_tstep) = Rs(k_trial,current_state) + p_gamma * max(Vs_latest(5),Vs_latest(6)) - Vs_latest(previous_action); % TD error for Q-learning
    elseif RLmodel == 'S' % SARSA
        TDs(k_trial,k_tstep) = Rs(k_trial,current_state) + p_gamma * Vs_latest(Choices(k_trial)) - Vs_latest(previous_action); % TD error for SARSA
    else
        error('RL algorithm is not properly specified');
    end
    Vs_latest(previous_action) = Vs_latest(previous_action) + p_alpha * TDs(k_trial,k_tstep); % update of the value of the previous action
    Vs_latest = Vs_latest .* ((1 - (1 - decay_paras(1))*exp(-Vs_latest/decay_paras(2))) .^ (1/num_tstep)); % decay
    
    % at S6,8,10,12,14 or S7,9,11,13,15
    for k_tstep = 6:10
        current_state = Choices(k_trial) + 2*k_tstep - 11; % index (# of S#) of the current state, which depends on the choice (5 or 6)
        current_action = current_state + 1; % index (# of A#) of the current action, which depends on the choice (5 or 6)
        previous_action = current_state - 1; % index (# of A#) of the previous action, which depends on the choice (5 or 6)
        TDs(k_trial,k_tstep) = Rs(k_trial,current_state) + p_gamma * Vs_latest(current_action) - Vs_latest(previous_action); % TD error
        Vs_latest(previous_action) = Vs_latest(previous_action) + p_alpha * TDs(k_trial,k_tstep); % update of the value of the previous action
        Vs_latest = Vs_latest .* ((1 - (1 - decay_paras(1))*exp(-Vs_latest/decay_paras(2))) .^ (1/num_tstep)); % decay
    end
    
    % at S16
    k_tstep = 11;
    current_state = 16; % index (# of S#) of the current state
    current_action = current_state + 1; % index (# of A#) of the current action
    previous_action = Choices(k_trial) + 10; % index (# of A#) of the previous action, which depends on the choice (5 or 6)
    TDs(k_trial,k_tstep) = Rs(k_trial,current_state) + p_gamma * Vs_latest(current_action) - Vs_latest(previous_action); % TD error
    Vs_latest(previous_action) = Vs_latest(previous_action) + p_alpha * TDs(k_trial,k_tstep); % update of the value of the previous action
    Vs_latest = Vs_latest .* ((1 - (1 - decay_paras(1))*exp(-Vs_latest/decay_paras(2))) .^ (1/num_tstep)); % decay
    
    % at S17,..,30
    for k_tstep = 12:25
        current_state = k_tstep+5; % index (# of S#) of the current state
        current_action = current_state + 1; % index (# of A#) of the current action
        previous_action = current_state; % index (# of A#) of the previous action
        TDs(k_trial,k_tstep) = Rs(k_trial,current_state) + p_gamma * Vs_latest(current_action) - Vs_latest(previous_action); % TD error
        Vs_latest(previous_action) = Vs_latest(previous_action) + p_alpha * TDs(k_trial,k_tstep); % update of the value of the previous action
        Vs_latest = Vs_latest .* ((1 - (1 - decay_paras(1))*exp(-Vs_latest/decay_paras(2))) .^ (1/num_tstep)); % decay
    end
    
    % copy Vs_latest to Vs_whole
    Vs_whole(k_trial,:) = Vs_latest;
    
end
