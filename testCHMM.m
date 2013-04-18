% Spring 2013 6.835 Intelligent Multimodal Interfaces
%
% [ Ystar, ll ] = testCHMM( chmm, seqs, params )
%  

function [ Ystar, ll ] = testCHMM( chmm, seqs, params )
    ll = cell(1, numel(seqs));
    for i=1:numel(seqs)
        for j=1:numel(chmm)
            ll{i}(j,1) = chmm_logprob(seqs{i}, chmm{j}, params);        
        end
    end
    [~, Ystar] = max(cell2mat(ll));
end

function [ll] = chmm_logprob(data, chmm, params)
    engine = smoother_engine(jtree_2TBN_inf_engine(chmm));
    evidence = cell(chmm.nnodes_per_slice,size(data,2));
    for i=1:numel(chmm.observed)
       evidence(chmm.observed(i),:) = ...
           num2cell(data(params.featureMap{i},:),1);
    end
    [~, ll] = enter_evidence(engine, evidence); 
end
