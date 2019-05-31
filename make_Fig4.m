% make_Fig4
%
% Script M-file for making Figure 4C(a,b),Db,E(a,b),Fb
%
% <usage>
%   Please specify the figure to plot in "which_figure = " below.
%
% <notes>
%   If "use_saved_randoms" below is set to 1, the same (saved) random numbers as those used in the simulations for the figures in the paper will be used.
%   Instead, if "use_saved_randoms" is set to 0, newly generated random numbers will be used.
%   Notably, it is also possible to make figures for cases that are not included in the paper by directly changing the value of variables/parameters below,
%   i.e., "free_or_not", "RLmodel", "rew_S8", "rew_S9", as well as others, but then modification of parameters for plotting (e.g., range of axes) may be needed
%   (special attention will be needed for making heat-map figures (like Fig.4Cb,Eb) because TD error can become negative depending on conditions/parameters);
%   e.g., forced-choice with SARSA (rather than forced-choice with Q-learning shown in Fig. 4Db in the paper) can be tested by setting "free_or_not" to 0 and "RLmodel" to 'S'.
%
% Morita K and Kato A (2014)
% Striatal dopamine ramping may indicate flexible reinforcement learning with forgetting in the cortico-basal ganglia circuits.
% Front. Neural Circuits 8:36. doi:10.3389/fncir.2014.00036
%
% Copyright: Kenji Morita (2014)


% which figure to draw
which_figure = 'C'; % please set this to 'C', 'D', 'E', or 'F' for plotting Fig. 4C(a,b), Db, E(a,b), or Fb, respectively

% whether to use the same (saved) random numbers as those used in the simulations for the figures in the paper, or instead use newly generated random numbers
use_saved_randoms = 1; % 1: use the same (saved) random numbers, 0: use newly generated random numbers

% upload random numbers
if use_saved_randoms
    load(['rands_for_choice_Fig4' which_figure '.mat']); % "rands_for_choice" is created in the workspace
else
    rands_for_choice = [];
end

% free-choice or not (forced-choice)
if (which_figure == 'C') || (which_figure == 'E') || (which_figure == 'F')
    free_or_not = 1; % free-choice
elseif which_figure == 'D'
    free_or_not = 0; % forced-choice
end

% algorithm of the reinforcement learning (RL) model
if (which_figure == 'C') || (which_figure == 'D') || (which_figure == 'E')
    RLmodel = 'Q'; % Q-learning
elseif which_figure == 'F'
    RLmodel = 'S'; % SARSA
end

% amounts of rewards at S8 and/or S9
rew_S8 = 1;
if which_figure == 'C'
    rew_S9 = 0;
elseif (which_figure == 'D') || (which_figure == 'E') || (which_figure == 'F')
    rew_S9 = 0.25;
end

% parameters for the RL model
p_alpha = 0.5; % learning rate (0 <= p_alpha <= 1)
p_beta = 1.5; % slope of the choice sigmoid (inverse temperature)
p_gamma = 0.8^(1/25); % time discount factor (per time step) (0 <= p_gamma <= 1)

% number of trials
num_session = 25; % number of pseudo-sessions
num_trial_per_session = 40; % number of trials per pseudo-session
num_trial = num_trial_per_session * num_session; % number of trials

% parameters for the decay of learned values
decay_paras = [0.6,0.6]; % [kappa1, kappa2] defined in the paper (Morita and Kato, 2014)

% run simulation
[Choices,TDs,Vs_whole] = simTmaze(free_or_not,RLmodel,p_alpha,p_beta,p_gamma,rew_S8,rew_S9,num_trial,decay_paras,rands_for_choice);

% analysis of the simulation results
% convert "TDs" (TD errors at S1, S2, ..., S30) to "TDs_shift" (TD errors at S26, S27, .., S30, S1, S2, ..., S25)
initial_TDs_at_S26_to_S30 = zeros(1,5); % Since the learned value of every state-action pair is assumed to be initially 0, TDs at S26-S30 are initially 0
TDs_of_1st_trial = [initial_TDs_at_S26_to_S30, TDs(1,1:20)];
TDs_of_2nd_to_1000th_trials = [TDs(1:end-1,21:end), TDs(2:end,1:20)];
TDs_shift = [TDs_of_1st_trial; TDs_of_2nd_to_1000th_trials];
% check the ratio of rewarded trials (in the experiment, the ratio was 65%) (NB: in the case of Fig. 4D, this gives the ratio of large-reward trials)
rewarded_ratio = sum(Choices == 5)/num_trial
% sort into rewarded and unrewarded trials
    % NB: in the case of Fig. 4D (forced-cohice), "rewarded" and "unrewarded" in the following instead represent "large-reward" and "small-reward", respectively
TDs_rewarded = TDs_shift(Choices == 5, :);
TDs_unrewarded = TDs_shift(Choices == 6, :);
% calculate the mean TD errors across rewarded trials and those across unrewarded trials in each pseudo-session
meanTDs_rewarded_sessions = zeros(num_session,size(TDs_shift,2)); % initialization
meanTDs_unrewarded_sessions = zeros(num_session,size(TDs_shift,2)); % initialization
num_rewarded_trials_sessions = zeros(1,num_session); % number of rewarded trials in each pseudo-session, initialization
num_unrewarded_trials_sessions = zeros(1,num_session); % number of unrewarded trials in each pseudo-session, initialization
for k_session = 1:num_session
    TDs_shift_session{k_session} = TDs_shift((k_session-1)*num_trial_per_session+[1:num_trial_per_session],:); % TD errors in each pseudo-session
    Choices_session{k_session} = Choices((k_session-1)*num_trial_per_session+[1:num_trial_per_session]); % choices in each session
    TDs_rewarded_session{k_session} = TDs_shift_session{k_session}(Choices_session{k_session} == 5, :); % TD errors in rewarded trials in each pseudo-session
    TDs_unrewarded_session{k_session} = TDs_shift_session{k_session}(Choices_session{k_session} == 6, :); % TD errors in unrewarded trials in each pseudo-session
    meanTDs_rewarded_sessions(k_session,:) = mean(TDs_rewarded_session{k_session},1); % mean TD errors across rewarded trials in each pseudo-session
    meanTDs_unrewarded_sessions(k_session,:) = mean(TDs_unrewarded_session{k_session},1); % mean TD errors across unrewarded trials in each pseudo-session
    num_rewarded_trials_sessions(k_session) = size(TDs_rewarded_session{k_session},1); % number of rewarded trials in each pseudo-sessio
    num_unrewarded_trials_sessions(k_session) = size(TDs_unrewarded_session{k_session},1); % number of unrewarded trials in each pseudo-session
end
% check if there is at least 1 reward/unrewarded trial in every pseudo-session (if not, error may occur later in the codes for plotting)
min(num_rewarded_trials_sessions)
min(num_unrewarded_trials_sessions)

% plot Fig4Ca,Db,Ea,Fb
clear colors
if (which_figure == 'C') || (which_figure == 'E')
    Ymin = -0.025;
    Ymax = 0.4;
    colors{1} = 'b';
    colors{2} = 'r';
    YTick = [0:0.1:0.4];
elseif which_figure == 'D'
    Ymin = -0.025;
    Ymax = 0.525;
    colors{1} = [0 1 1/2];
    colors{2} = [0 1/2 1/4];
    YTick = [0:0.1:0.5];
elseif which_figure == 'F'
    Ymin = -0.3;
    Ymax = 0.4;
    colors{1} = 'b';
    colors{2} = 'r';
    YTick = [-0.3:0.1:-0.1 0:0.1:0.4];
end
F = figure;
A = axes;
hold on;
P = plot([0 10],[0 0],'k-.');
P = plot([2 2],[Ymin Ymax],'k:');
P = plot([6 6],[Ymin Ymax],'k--');
P = plot([8 8],[Ymin Ymax],'k');
P = errorbar([0:1:10],mean(TDs_rewarded(:,4:14),1),std(TDs_rewarded(:,4:14),1,1),'.'); set(P,'Color',colors{1});
P = errorbar([0:1:10],mean(TDs_unrewarded(:,4:14),1),std(TDs_unrewarded(:,4:14),1,1),'.'); set(P,'Color',colors{2});
P = plot([0:1:10],mean(meanTDs_rewarded_sessions(:,4:14),1)+std(meanTDs_rewarded_sessions(:,4:14),1,1)/sqrt(num_session),':'); set(P,'Color',colors{1});
P = plot([0:1:10],mean(meanTDs_rewarded_sessions(:,4:14),1)-std(meanTDs_rewarded_sessions(:,4:14),1,1)/sqrt(num_session),':'); set(P,'Color',colors{1});
P = plot([0:1:10],mean(meanTDs_unrewarded_sessions(:,4:14),1)+std(meanTDs_unrewarded_sessions(:,4:14),1,1)/sqrt(num_session),':'); set(P,'Color',colors{2});
P = plot([0:1:10],mean(meanTDs_unrewarded_sessions(:,4:14),1)-std(meanTDs_unrewarded_sessions(:,4:14),1,1)/sqrt(num_session),':'); set(P,'Color',colors{2});
P = plot([0:1:10],mean(meanTDs_rewarded_sessions(:,4:14),1)); set(P,'Color',colors{1});
P = plot([0:1:10],mean(meanTDs_unrewarded_sessions(:,4:14),1)); set(P,'Color',colors{2});
axis([0 10 Ymin Ymax]);
set(A,'Box','off');
set(A,'PlotBoxAspectRatio',[2.5 1 1]);
set(A,'FontName','Ariel','FontSize',20);
set(A,'XTick',[0:1:10],'XTickLabel',[]);
set(A,'YTick',YTick,'YTickLabel',YTick);

% plot Fig4Cb,Eb
if (which_figure == 'C') || (which_figure == 'E')
    tmp_matrix = TDs_shift(401:440,4:14); % trials No.401-440 are plotted
    tmp_scale = 64/max(max(tmp_matrix)); % this will be used below for scaling for plotting
    F = figure;
    A = axes;
    hold on;
    P = image(flipud(tmp_matrix)*tmp_scale); % scaling by multiplying "tmp_scale" is done so that differences across the values in "tmp_matrix" can be well seen in the heat-map
    P = plot([3 3],[0.5 40.5],'r:');
    P = plot([7 7],[0.5 40.5],'r--');
    P = plot([9 9],[0.5 40.5],'r');
    C = colorbar; set(C,'YTick',tmp_scale*[0:0.1:0.5],'YTickLabel',[0:0.1:0.5]);
    axis([0.5 11.5 0.5 40.5]);
    set(A,'Box','off');
    set(A,'PlotBoxAspectRatio',[1.5 1 1]);
    set(A,'FontName','Ariel','FontSize',20);
    set(A,'XTick',[1:1:11],'XTickLabel',[]);
    set(A,'YTick',[1:5:36],'YTickLabel',[40:-5:5]);
end
