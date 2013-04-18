% Spring 2013 6.835 Intelligent Multimodal Interfaces
%
% R = experiment_cotrain_hmm(D, params, W) 

function R = experiment_cotrain_hmm(D, params, W)
    % Train model    
    cohmm = trainCoHMM( D.seqs(D.split.train), D.labels(D.split.train), ...
                        D.seqs(D.split.unlabeled), params);
    % Test model
    r.train = testLateHMM(D.seqs(D.split.train),D.labels(D.split.train),cohmm,params.featureMap,W);
    r.validate = testLateHMM(D.seqs(D.split.validate),D.labels(D.split.validate),cohmm,params.featureMap,W);
    r.test = testLateHMM(D.seqs(D.split.test),D.labels(D.split.test),cohmm,params.featureMap,W);

    R = cell(1,numel(W));
    for i=1:numel(W)
        R{i}.model = cohmm;
        R{i}.params = params;
        R{i}.params.weightsMV = W{i};
        R{i}.stat.train    = r.train{i};
        R{i}.stat.validate = r.validate{i};
        R{i}.stat.test     = r.test{i};        
        if params.verbose>=1,
            fprintf('H=[%d %d],G=[%d %d],W=[%.2f %.2f], test=%.2f,validate=%.2f,test=%.2f\n',...
                params.nbHiddenStatesMV(1),params.nbHiddenStatesMV(2),...
                params.nbGaussMixturesMV(1),params.nbGaussMixturesMV(2),W{i}(1),W{i}(2),...
                R{i}.stat.train.accuracy,R{i}.stat.validate.accuracy,R{i}.stat.test.accuracy);            
        end
    end
end
