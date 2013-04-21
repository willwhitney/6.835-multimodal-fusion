% Spring 2013 6.835 Intelligent Multimodal Interfaces
%
% [ cohmm ] = trainCoHMM( seqs, labels, useqs, params )
%
% Input
%   seqs   - 1-by-N cell array of training samples
%   labels - 1-by-N cell array of labels
%   useqs  - 1-by-M cell array of unlabeled samples
%   params
%     maxiter_cotrain - max number of iterations
%     initN_cotrain   - initial pool size
%     Ny_cotrain      - num of samples (per class) to label in each iter
%
% Output
%   cohmm  - 1-by-2 cell array of trained HMMs

function [ cohmm ] = trainCoHMM( seqs, labels, useqs, params ) 
    params
    RandStream.setGlobalStream(...
        RandStream('mt19937ar', 'seed', params.randSeed));
    
    cohmm = cell(1, 2);
    cohmm{1} = [];
    cohmm{2} = [];
    useqsPrimeIndices = randsample(1:numel(useqs), params.initN_cotrain);
    useqsPrime = useqs(useqsPrimeIndices);
    useqs(useqsPrimeIndices) = [];
    for iteration = 1:params.maxiter_cotrain
        iteration
        body_seqs = cellfun(@(x) x(params.featureMap{1},:), seqs, 'UniformOutput', false);
        hand_seqs = cellfun(@(x) x(params.featureMap{2},:), seqs, 'UniformOutput', false);
        
        params.nbHiddenStates = params.nbHiddenStatesMV(1);
        params.nbGaussMixtures = params.nbGaussMixturesMV(1);
        bodyHMM = trainHMM(body_seqs, labels, params);
        
        params.nbHiddenStates = params.nbHiddenStatesMV(2);
        params.nbGaussMixtures = params.nbGaussMixturesMV(2);
        handHMM = trainHMM(hand_seqs, labels, params);
        
        body_useqs = cellfun(@(x) x(params.featureMap{1},:), useqsPrime, 'UniformOutput', false);
        hand_useqs = cellfun(@(x) x(params.featureMap{2},:), useqsPrime, 'UniformOutput', false);
        
        bodyResults = zeros(numel(useqsPrime), 3);
        handResults = zeros(numel(useqsPrime), 3);
        
        % each of these in format [Ystar, LL]
        [bodyYstar, bodyLL] = testHMM(bodyHMM, body_useqs);
        [handYstar, handLL] = testHMM(handHMM, hand_useqs);
        
        bodyResults(:, 1) = bodyYstar;
        handResults(:, 1) = handYstar;
        
        % put in indices so we can find the data points in the useqs array
        bodyResults(:, 3) = 1:numel(useqsPrime);
        handResults(:, 3) = 1:numel(useqsPrime);
        
        % include only max-likelihood in LL array for sorting
        bodyLL = cellfun(@getMaxLikelihood, bodyLL, 'UniformOutput', false);
        handLL = cellfun(@getMaxLikelihood, handLL, 'UniformOutput', false);
        
        bodyLL = cell2mat(bodyLL);
        handLL = cell2mat(handLL);
        
        bodyResults(:, 2) = bodyLL;
        handResults(:, 2) = handLL;
        
        bodyResults = sortrows(bodyResults, 2);
        handResults = sortrows(handResults, 2);
        
        bodyResults = flipud(bodyResults);
        handResults = flipud(handResults);
        
        bodyResults = sortrows(bodyResults, 1);
        handResults = sortrows(handResults, 1);
        
        gestureIndex = 1;
        bIndex = 1;
        hIndex = 1;
        removeIndices = [];
        while gestureIndex <=6
            
            while bodyResults(bIndex, 1) < gestureIndex 
                bIndex = bIndex + 1;
            end
            seqs = [seqs useqsPrime{bodyResults(bIndex, 3)}];
            seqs = [seqs useqsPrime{bodyResults(bIndex + 1, 3)}];
            removeIndices = [removeIndices bodyResults(bIndex, 3) bodyResults(bIndex + 1, 3)];
            
            labelRow = bodyResults(bIndex, 1) * ones(1, size(useqsPrime{bodyResults(bIndex, 3)}, 2));
            labels = [labels labelRow];
            labelRow = bodyResults(bIndex + 1, 1) * ones(1, size(useqsPrime{bodyResults(bIndex + 1, 3)}, 2));
            labels = [labels labelRow];
            
            
            while handResults(hIndex, 1) < gestureIndex 
                hIndex = hIndex + 1;
            end
            seqs = [seqs useqsPrime{handResults(hIndex, 3)}];
            seqs = [seqs useqsPrime{handResults(hIndex + 1, 3)}];
            removeIndices = [removeIndices handResults(hIndex, 3) handResults(hIndex + 1, 3)];
            
            labelRow = handResults(hIndex, 1) * ones(1, size(useqsPrime{handResults(hIndex, 3)}, 2));
            labels = [labels labelRow];
            labelRow = handResults(hIndex + 1, 1) * ones(1, size(useqsPrime{handResults(hIndex + 1, 3)}, 2));
            labels = [labels labelRow];
            
%             labels = [labels bodyResults(hIndex, 1) bodyResults(hIndex + 1, 1)];
            
            gestureIndex = gestureIndex + 1;
        end
        
        removeIndices = unique(removeIndices);                
        numToAdd = numel(removeIndices);
        useqsPrime(removeIndices) = [];
        
        newuseqsPrimeIndices = randsample(1:numel(useqs), numToAdd);
        useqsPrime = [useqsPrime useqs(newuseqsPrimeIndices)];
        useqs(newuseqsPrimeIndices) = [];
        
        cohmm{1} = bodyHMM;
        cohmm{2} = handHMM;
    end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
%     
%     if ~exist(cohmm,'var')
%         error('Implement trainCoHMM.m');
%     end
end

function [ likelihood ] = getMaxLikelihood( datapoint )
    likelihood = max(datapoint);
end












