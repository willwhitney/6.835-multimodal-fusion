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



%% Part 2a: HMM Early Fusion 
R.early = {};
for i=1:numel(H)
    for j=1:numel(G)
        params.nbHiddenStates = H(i);
        params.nbGaussMixtures = G(j);
        r = experiment_early_hmm(D, params);
        if params.verbose>=1,
            fprintf('(early) H=%d,G=%d,test=%.2f,validate=%.2f,test=%.2f\n',H(i),G(j),...
                r.stat.train.accuracy,r.stat.validate.accuracy,r.stat.test.accuracy);            
        end
        R.early = horzcat(R.early,r);        
    end
end
% Find the best model based on performance on the validateion split
BR.early = R.early{get_best_model(R.early)};
BR.early.stat.test.confmat = build_confmat(...
    BR.early.stat.test.Ystar, BR.early.stat.test.Ytrue);
plot_confmat( BR.early.stat.test.confmat, 'Early Fusion HMM');
fprintf('[Early HMM] accuracy=%f (H=%d,G=%d)\n', BR.early.stat.test.accuracy,...
    BR.early.params.nbHiddenStates,BR.early.params.nbGaussMixtures);
   
