% Spring 2013 6.835 Intelligent Multimodal Interfaces
%
% R = experiment_early_hmm(D, params)

function R = experiment_early_hmm(D, params)
    % Train model    
    hmm = trainHMM( D.seqs(D.split.train), D.labels(D.split.train), params);
    
    R.model = hmm;
    R.params = params;
    
    % Test model on all three splits
    R.stat.train    = test_early_hmm(D.seqs(D.split.train), D.labels(D.split.train), hmm);
    R.stat.validate = test_early_hmm(D.seqs(D.split.validate), D.labels(D.split.validate), hmm);
    R.stat.test     = test_early_hmm(D.seqs(D.split.test), D.labels(D.split.test), hmm);
end

function stat = test_early_hmm(seqs, labels, hmm)
    Ystar = testHMM(hmm, seqs);
    Ytrue = cellfun(@(x) mode(x), labels);
    accuracy = sum(Ystar==Ytrue)/numel(Ytrue);    
    stat.Ystar = Ystar; stat.Ytrue = Ytrue; stat.accuracy = accuracy;
end