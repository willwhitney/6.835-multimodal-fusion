% Spring 2013 6.835 Intelligent Multimodal Interfaces
%
%  R = experiment_coupled_hmm(D, params)

function R = experiment_coupled_hmm(D, params)
    % Train model    
    chmm = trainCHMM( D.seqs(D.split.train), D.labels(D.split.train), params);
    R.model = chmm;
    R.params = params;
    
    % Test model on all three splits
    R.stat.train    = test_coupled_hmm(D.seqs(D.split.train), D.labels(D.split.train), chmm, params);
    R.stat.validate = test_coupled_hmm(D.seqs(D.split.validate), D.labels(D.split.validate), chmm, params);
    R.stat.test     = test_coupled_hmm(D.seqs(D.split.test), D.labels(D.split.test), chmm, params);
end

function stat = test_coupled_hmm(seqs, labels, chmm, params)
    Ystar = testCHMM(chmm, seqs, params);
    Ytrue = cellfun(@(x) mode(x), labels);
    accuracy = sum(Ystar==Ytrue)/numel(Ytrue);    
    stat.Ystar = Ystar; stat.Ytrue = Ytrue; stat.accuracy = accuracy;    
end