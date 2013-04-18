% Spring 2013 6.835 Intelligent Multimodal Interfaces
%
% [ Ystar, ll ] = testHMM( hmm, seqs )
% 

function [ Ystar, ll ] = testHMM( hmm, seqs )
    ll = cell(1, numel(seqs)); 
    for i=1:numel(seqs) 
        for j=1:numel(hmm)
            ll{i}(j,1) = mhmm_logprob(seqs{i}, hmm{j}.prior, ...
                hmm{j}.transmat, hmm{j}.mu, hmm{j}.sigma, hmm{j}.mixmat);
        end
    end
    [~, Ystar] = max(cell2mat(ll));
end

