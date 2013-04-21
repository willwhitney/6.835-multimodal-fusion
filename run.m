% Spring 2013 6.835 Intelligent Multimodal Interfaces
%
%  Project 4: Multimodal Signal Fusion using HMMs
%       Due: 6PM Wednesday, April 16, 2013
%
% This script will run through all the experiments you will perform in this
% mini project. Simply copy-and-paste the lines to the Matlab command line.
clc; clear all;

%% Add FullBNT path 
BNT_PATH = '/Users/will/Dropbox/MIT/6.835/miniproject4/bnt/';
addpath(BNT_PATH);
addpath(genpathKPM(BNT_PATH)); 

%% Load the dataset
load NATOPS6.mat;
% We will use 10% for training, 10% for validateion, 40% for testing. 
% The rest 40% will be regarded as unlabeled data and used in co-training.
D.split = split_data(D.labels, [.1 .1 .4 .4]); 
% Define the two "views" (i.e., body and hand) of data. 
% 1:12 contain body features, 13:20 contain hand features
D.views = {[1:12],[13:20]}; 
 
%% Set the parameters
params.verbose = 1;
params.randSeed = 12345; % random seed for reproducible experimental results
params.maxiter_em = 20; % max number of iter in EM algorithm
% Single-view params
params.nbHiddenStates = 9; % number of hidden states
params.nbGaussMixtures = 1; % number of Gaussian mixtures
% Multi-view params
params.nbViews = 2; % number of views (body and hand)
params.featureMap = D.views; 
params.nbHiddenStatesMV = [3 3]; % number of hidden states per view
params.nbGaussMixturesMV = [1 1]; % number of gaussian mixtures per view
params.weightsMV = [.5 .5]; % used in late-HMM and cotrain-HMM
% Co-training params
params.maxiter_cotrain = 5; % max number of iter in co-training algorithm
params.initN_cotrain = floor(numel(D.split.unlabeled)*0.5); % initial pool size
params.Ny_cotrain = 2; % number of samples per class to be added by each view in each iteration of cotraining

%% Set parameters values to try out
H = 8:4:12;
G = 1:3;
W = {[0 1],[.1 .9],[.2 .8],[.3 .7],[.4 .6],[.5 .5],[.6 .4],[.7 .3],[.8 .2],[.9 .1],[1 0]};
HMV = {[4 4],[8 8],[12 12]}; 
GMV = {[1 1],[2 2],[3 3]};


%% Part 1a: Unimodal - body only
% Important: do not delete R.body results as we will use it again for late-fusion experiment
D_body = D; D_body.seqs = cellfun(@(x) x(params.featureMap{1},:), D.seqs, 'UniformOutput', false); 
R.body = {}; 
for i=1:numel(H)
    for j=1:numel(G)
        params.nbHiddenStates = H(i);
        params.nbGaussMixtures = G(j);
        r = experiment_early_hmm(D_body, params);
        if params.verbose>=1,
            fprintf('(body) H=%d,G=%d,train=%.2f,validate=%.2f,test=%.2f\n',H(i),G(j),...
                r.stat.train.accuracy,r.stat.validate.accuracy,r.stat.test.accuracy);            
        end
        R.body = horzcat(R.body,r);
    end
end
% Find the best model based on performance on the validation split
BR.body = R.body{get_best_model(R.body)};
BR.body.stat.test.confmat = build_confmat(...
    BR.body.stat.test.Ystar, BR.body.stat.test.Ytrue);
plot_confmat( BR.body.stat.test.confmat, 'Body Only');
fprintf('[Body HMM] accuracy=%f (H=%d,G=%d)\n', BR.body.stat.test.accuracy,...
    BR.body.params.nbHiddenStates,BR.body.params.nbGaussMixtures);


%% Part 1b: Unimodal - hand only 
% Important: do not delete R.hand results as we will use it again for late-fusion experiment
D_hand = D; D_hand.seqs = cellfun(@(x) x(params.featureMap{2},:), D.seqs, 'UniformOutput', false);
R.hand = {};
for i=1:numel(H)
    for j=1:numel(G)
        params.nbHiddenStates = H(i);
        params.nbGaussMixtures = G(j);
        r = experiment_early_hmm(D_hand, params);
        if params.verbose>=1,
            fprintf('(hand) H=%d,G=%d,train=%.2f,validate=%.2f,test=%.2f\n',H(i),G(j),...
                r.stat.train.accuracy,r.stat.validate.accuracy,r.stat.test.accuracy);            
        end
        R.hand = horzcat(R.hand,r);
    end
end
BR.hand = R.hand{get_best_model(R.hand)};
BR.hand.stat.test.confmat = build_confmat(...
    BR.hand.stat.test.Ystar, BR.hand.stat.test.Ytrue);
plot_confmat( BR.hand.stat.test.confmat, 'Hand Only');
fprintf('[Hand HMM] accuracy=%f (H=%d,G=%d)\n', BR.hand.stat.test.accuracy,...
    BR.hand.params.nbHiddenStates,BR.hand.params.nbGaussMixtures);


%% Part 2a: HMM Early Fusion 
R.early = {};
for i=1:numel(H)
    for j=1:numel(G)
        params.nbHiddenStates = H(i);
        params.nbGaussMixtures = G(j);
        r = experiment_early_hmm(D, params);
        if params.verbose>=1,
            fprintf('(early) H=%d,G=%d,train=%.2f,validate=%.2f,test=%.2f\n',H(i),G(j),...
                r.stat.train.accuracy,r.stat.validate.accuracy,r.stat.test.accuracy);            
        end
        R.early = horzcat(R.early,r);        
    end
end
% Find the best model based on performance on the validation split
BR.early = R.early{get_best_model(R.early)};
BR.early.stat.test.confmat = build_confmat(...
    BR.early.stat.test.Ystar, BR.early.stat.test.Ytrue);
plot_confmat( BR.early.stat.test.confmat, 'Early Fusion HMM');
fprintf('[Early HMM] accuracy=%f (H=%d,G=%d)\n', BR.early.stat.test.accuracy,...
    BR.early.params.nbHiddenStates,BR.early.params.nbGaussMixtures);
   

%% Part 2b: HMM Late Fusion 
% We are going to use already trained hmms for body-only and hand-only
% Parameters (H,G,W) are validated inside experiment_late_hmm(...)
% R.late is 1-by-|H|x|G|x|W| cell array.
R.late = experiment_late_hmm(D, params, H, G, W, {R.body, R.hand});

% Find the best model based on performance on the validation split
BR.late = R.late{get_best_model(R.late)};
BR.late.stat.test.confmat = build_confmat(...
    BR.late.stat.test.Ystar, BR.late.stat.test.Ytrue);
plot_confmat( BR.late.stat.test.confmat, 'Late Fusion HMM');
fprintf('[Late HMM] accuracy=%f (H=[%d %d],G=[%d %d],W=[%.2f %.2f])\n', ...
    BR.late.stat.test.accuracy,...
    BR.late.params.nbHiddenStatesMV(1),...
    BR.late.params.nbHiddenStatesMV(2),...
    BR.late.params.nbGaussMixturesMV(1),...
    BR.late.params.nbGaussMixturesMV(2),...
    BR.late.params.weightsMV(1),...
    BR.late.params.weightsMV(2));

        
%% Part 3: Coupled HMM
R.coupled = {};
for i=1:numel(HMV) 
    params.nbHiddenStatesMV = HMV{i}; 
    R.coupled = horzcat(R.coupled,experiment_coupled_hmm(D, params)); 
end
% Find the best model based on performance on the validation split
BR.coupled = R.coupled{get_best_model(R.coupled)};
BR.coupled.stat.test.confmat = build_confmat(...
    BR.coupled.stat.test.Ystar, BR.coupled.stat.test.Ytrue);
plot_confmat( BR.coupled.stat.test.confmat, 'Coupled HMM');
fprintf('[Coupled HMM] accuracy=%f (H=[%d %d],G=[%d %d])\n', ...
    BR.coupled.stat.test.accuracy,...
    BR.coupled.params.nbHiddenStatesMV(1),...
    BR.coupled.params.nbHiddenStatesMV(2),...
    BR.coupled.params.nbGaussMixturesMV(1),...
    BR.coupled.params.nbGaussMixturesMV(2));



%% Part 4: Co-training HMM
HMV = {[8 8],[12 12]}; 
GMV = {[2 2],[3 3]};

R.cotrain = {};
for i=1:numel(HMV)
    for j=1:numel(GMV)
        params.nbHiddenStatesMV = HMV{i};
        params.nbGaussMixturesMV = GMV{j};
        R.cotrain = horzcat(R.cotrain,experiment_cotrain_hmm(D, params, W));
    end
end
BR.cotrain = R.cotrain{get_best_model(R.cotrain)};
BR.cotrain.stat.test.confmat = build_confmat(...
    BR.cotrain.stat.test.Ystar, BR.cotrain.stat.test.Ytrue);
plot_confmat( BR.cotrain.stat.test.confmat, 'Co-training HMM');
fprintf('[Co-train HMM] accuracy=%f (H=[%d %d],G=[%d %d],W=[%.2f %.2f])\n', ...
    BR.cotrain.stat.test.accuracy,...
    BR.cotrain.params.nbHiddenStatesMV(1),...
    BR.cotrain.params.nbHiddenStatesMV(2),...
    BR.cotrain.params.nbGaussMixturesMV(1),...
    BR.cotrain.params.nbGaussMixturesMV(2),...
    BR.cotrain.params.weightsMV(1),...
    BR.cotrain.params.weightsMV(2));


