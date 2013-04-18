% Spring 2013 6.835 Intelligent Multimodal Interfaces
%
% R = experiment_late_hmm(D, params, H, G, W, M)    

function R = experiment_late_hmm(D, params, H, G, W, M)    
    % Train models if M (already trained models) is not provided
    if ~exist('M','var')
        M = cell(1,2);
        for view=1:2
            seqs = cellfun(@(x) x(params.featureMap{view},:), D.seqs(D.split.train), 'UniformOutput', false);
            for i=1:numel(H)
                for j=1:numel(G)
                    params.nbHiddenStates = H(i);
                    params.nbGaussMixtures = G(j);
                    r.model = trainHMM( seqs, D.labels(D.split.train), params );
                    r.params = params;
                    M{view}{end+1} = r;
                end
            end
        end
    end
    
    % Test model
    R = {};
    for i=1:numel(M{1})
        for j=1:numel(M{2})
            hmm = {M{1}{i}.model,M{2}{j}.model};
            params = M{1}{i}.params;
            params.nbHiddenStatesMV = [M{1}{i}.params.nbHiddenStates M{2}{j}.params.nbHiddenStates];
            params.nbGaussMixturesMV = [M{1}{i}.params.nbGaussMixtures M{2}{j}.params.nbGaussMixtures];            
            Rc.train = testLateHMM(D.seqs(D.split.train),D.labels(D.split.train),hmm,params.featureMap,W);
            Rc.validate = testLateHMM(D.seqs(D.split.validate),D.labels(D.split.validate),hmm,params.featureMap,W);
            Rc.test = testLateHMM(D.seqs(D.split.test),D.labels(D.split.test),hmm,params.featureMap,W);
            r = cell(1,numel(W));
            for k=1:numel(W)
                r{k}.params.weightsMV = W{k};
                r{k}.model = hmm;
                r{k}.params = params;
                r{k}.stat.train = Rc.train{k};
                r{k}.stat.validate = Rc.validate{k};
                r{k}.stat.test = Rc.test{k};
                if params.verbose>=1,
                    fprintf('(late) H=[%d %d],G=[%d %d],W=[%.2f %.2f], train=%.2f,validate=%.2f,test=%.2f\n',...
                        params.nbHiddenStatesMV(1),params.nbHiddenStatesMV(2),...
                        params.nbGaussMixturesMV(1),params.nbGaussMixturesMV(2),W{k}(1),W{k}(2),...
                        r{k}.stat.train.accuracy,r{k}.stat.validate.accuracy,r{k}.stat.test.accuracy);  
                end 
            end
            R = horzcat(R, r);
        end
    end
end