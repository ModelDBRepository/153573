% make_Fig2
%
% Script M-file for making Figure 2C
%
% Morita K and Kato A (2014)
% Striatal dopamine ramping may indicate flexible reinforcement learning with forgetting in the cortico-basal ganglia circuits.
% Front. Neural Circuits 8:36. doi:10.3389/fncir.2014.00036
%
% Copyright: Kenji Morita (2014)


%% Fig2Ca
F = figure;
A = axes;
hold on;
colors = 'rbgm';
n = 7;
j_set = [6:-1:0];
p_alphas = [0.4:0.2:0.8];
p_gamma = 0.8^(1/j_set(1));
Rew = 1;
% without decay
delta_at_start = Rew * (p_gamma^j_set(1));
P = plot(n-j_set,[delta_at_start zeros(1,length(j_set)-1)],'k--');
% with decay
kappa = 0.75;
for k_alpha = 1:length(p_alphas)
    p_alpha = p_alphas(k_alpha);
    deltas = Rew * ((((p_alpha * kappa * p_gamma).^j_set) * (1 - kappa)) ./ ((1 - kappa * (1 - p_alpha)).^(j_set+1)));
    deltas(1) = Rew * (((p_alpha * kappa * p_gamma)^j_set(1)) / ((1 - kappa * (1 - p_alpha))^j_set(1)));
    P = plot(n-j_set,deltas,colors(k_alpha));
end
axis([n-j_set(1) n-j_set(end) 0 0.8]);
set(A,'Box','off');
set(A,'FontName','Ariel','FontSize',24);
set(A,'XTick',n-j_set,'XTickLabel',n-j_set);
set(A,'YTick',[0:0.2:0.8],'YTickLabel',[0:0.2:0.8]);


%% Fig2Cb
F = figure;
A = axes;
hold on;
colors = 'rbgm';
n = 7;
j_set = [6:-1:0];
p_alpha = 0.6;
p_gammas = [0.4 0.8 1].^(1/j_set(1));
Rew = 1;
% without decay
for k_gamma = 1:length(p_gammas)
    p_gamma = p_gammas(k_gamma);
    delta_at_start = Rew * (p_gamma^j_set(1));
    P = plot(n-j_set,[delta_at_start zeros(1,length(j_set)-1)],[colors(k_gamma) '--']);
end
% with decay
kappa = 0.75;
for k_gamma = 1:length(p_gammas)
    p_gamma = p_gammas(k_gamma);
    deltas = Rew * ((((p_alpha * kappa * p_gamma).^j_set) * (1 - kappa)) ./ ((1 - kappa * (1 - p_alpha)).^(j_set+1)));
    deltas(1) = Rew * (((p_alpha * kappa * p_gamma)^j_set(1)) / ((1 - kappa * (1 - p_alpha))^j_set(1)));
    P = plot(n-j_set,deltas,colors(k_gamma));
end
axis([n-j_set(1) n-j_set(end) 0 1]);
set(A,'Box','off');
set(A,'FontName','Ariel','FontSize',24);
set(A,'XTick',n-j_set,'XTickLabel',n-j_set);
set(A,'YTick',[0:0.2:1],'YTickLabel',[0:0.2:1]);


%% Fig2Cc
F = figure;
A = axes;
hold on;
colors = 'rbgy';
n = 7;
j_set = [6:-1:0];
p_alpha = 0.6;
p_gamma = 0.8^(1/j_set(1));
Rew = 1;
% without decay
delta_at_start = Rew * (p_gamma^j_set(1));
P = plot(n-j_set,[delta_at_start zeros(1,length(j_set)-1)],'k--');
% with decay
kappas = [0.63 0.75 0.87];
for k_kappa = 1:length(kappas)
    kappa = kappas(k_kappa);
    deltas = Rew * ((((p_alpha * kappa * p_gamma).^j_set) * (1 - kappa)) ./ ((1 - kappa * (1 - p_alpha)).^(j_set+1)));
    deltas(1) = Rew * (((p_alpha * kappa * p_gamma)^j_set(1)) / ((1 - kappa * (1 - p_alpha))^j_set(1)));
    P = plot(n-j_set,deltas,colors(k_kappa));
end
axis([n-j_set(1) n-j_set(end) 0 0.8]);
set(A,'Box','off');
set(A,'FontName','Ariel','FontSize',24);
set(A,'XTick',n-j_set,'XTickLabel',n-j_set);
set(A,'YTick',[0:0.2:0.8],'YTickLabel',[0:0.2:0.8]);


%% Fig2Cd
F = figure;
A = axes;
hold on;
colors = 'rbgy';
n = 7;
j_set = [6:-1:0];
p_alpha = 0.6;
p_gamma = 0.8^(1/j_set(1));
Rews = [0.5:0.5:1.5];
% without decay
for k_Rew = 1:length(Rews)
    Rew = Rews(k_Rew);
    delta_at_start = Rew * (p_gamma^j_set(1));
    P = plot(n-j_set,[delta_at_start zeros(1,length(j_set)-1)],[colors(k_Rew) '--']);
end
% with decay
kappa = 0.75;
for k_Rew = 1:length(Rews)
    Rew = Rews(k_Rew);
    deltas = Rew * ((((p_alpha * kappa * p_gamma).^j_set) * (1 - kappa)) ./ ((1 - kappa * (1 - p_alpha)).^(j_set+1)));
    deltas(1) = Rew * (((p_alpha * kappa * p_gamma)^j_set(1)) / ((1 - kappa * (1 - p_alpha))^j_set(1)));
    P = plot(n-j_set,deltas,colors(k_Rew));
end
axis([n-j_set(1) n-j_set(end) 0 1.2]);
set(A,'Box','off');
set(A,'FontName','Ariel','FontSize',24);
set(A,'XTick',n-j_set,'XTickLabel',n-j_set);
set(A,'YTick',[0:0.2:1.2],'YTickLabel',[0:0.2:1.2]);
