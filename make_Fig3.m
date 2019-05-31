% make_Fig3
%
% Script M-file for making Figure 3B
%
% Morita K and Kato A (2014)
% Striatal dopamine ramping may indicate flexible reinforcement learning with forgetting in the cortico-basal ganglia circuits.
% Front. Neural Circuits 8:36. doi:10.3389/fncir.2014.00036
%
% Copyright: Kenji Morita (2014)


%% Fig3Ba

F = figure;
A = axes;
hold on;
colors = 'rbgm';
Vs = [0:0.01:2];
kappa1 = 0.6;
kappa2s = [inf, 1.5, 0.9, 0.6];
P = plot([0 2],[1 1],'k:');
for k_kappa2 = 1:length(kappa2s)
    decays = 1 - (1 - kappa1)*exp(-Vs/kappa2s(k_kappa2));
    P = plot(Vs,decays,colors(k_kappa2));
end
axis([0 2 0.55 1.05]);
set(A,'Box','off');
set(A,'FontName','Ariel','FontSize',20);
set(A,'XTick',[0:0.5:2],'XTickLabel',[0:0.5:2]);
set(A,'YTick',[0.6:0.1:1],'YTickLabel',[0.6:0.1:1]);


%% Fig3Bb

% parameters
num_tstep = 7;
num_trial = 10;
num_allstep = num_tstep * num_trial;

% decay parameters
decay_paras_set{1} = [1 inf];
decay_paras_set{2} = [0.6 inf];
decay_paras_set{3} = [0.6 1.5];
decay_paras_set{4} = [0.6 0.9];
decay_paras_set{5} = [0.6 0.6];

% calculation
for k_decay = 1:5
    Vs_latest = [0.5 1];
    Vs_all{k_decay} = Vs_latest;
    for k_tstep = 1:num_allstep
        Vs_latest = Vs_latest .* ((1 - (1 - decay_paras_set{k_decay}(1))*exp(-Vs_latest/decay_paras_set{k_decay}(2))) .^ (1/num_tstep));
        Vs_all{k_decay} = [Vs_all{k_decay}; Vs_latest];
    end
end

% plot
F = figure;
A = axes;
hold on;
colors = 'yrbgm';
symbols = ':-';
for k_decay = 1:5
    for k_initialV = 2
        P = plot([0:num_allstep],Vs_all{k_decay}(:,k_initialV),[colors(k_decay) symbols(k_initialV)]);
    end
end
axis([0 num_allstep 0 1.1]);
set(A,'Box','off');
set(A,'FontName','Ariel','FontSize',20);
set(A,'XTick',[0:num_tstep:num_allstep],'XTickLabel',[0:num_trial]);
set(A,'YTick',[0:0.1:1.1],'YTickLabel',[0:0.1:1.1]);


%% Fig3Bc

F = figure;
A = axes;
hold on;
colors = 'rbgm';
num_trial = 100;
p_alpha = 0.5;
p_gamma = 0.8^(1/(num_tstep-1));
rew_size = 1;
% without decay
kappa1 = 1;
kappa2 = inf;
[TDs,Vs_whole] = simImaze(p_alpha,p_gamma,rew_size,num_trial,[kappa1,kappa2]);
P = plot([1:num_tstep],TDs(end,1:num_tstep),'k--');
% with decay
kappa1 = 0.6;
kappa2s = [inf, 1.5, 0.9, 0.6];
for k_kappa2 = 1:length(kappa2s)
    kappa2 = kappa2s(k_kappa2);
    [TDs,Vs_whole] = simImaze(p_alpha,p_gamma,rew_size,num_trial,[kappa1,kappa2]);
    P = plot([1:num_tstep],TDs(end,1:num_tstep),colors(k_kappa2));
end
axis([1 num_tstep 0 0.8]);
set(A,'Box','off');
set(A,'FontName','Ariel','FontSize',20);
set(A,'XTick',[1:num_tstep],'XTickLabel',[1:num_tstep]);
set(A,'YTick',[0:0.1:0.8],'YTickLabel',[0:0.1:0.8]);
