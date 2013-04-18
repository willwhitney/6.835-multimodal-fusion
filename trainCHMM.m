% Spring 2013 6.835 Intelligent Multimodal Interfaces
%
% [ chmm ] = trainCHMM( seqs, labels, params )
%   
function [ chmm ] = trainCHMM( seqs, labels, params )
    RandStream.setGlobalStream(...
        RandStream('mt19937ar', 'seed', params.randSeed));

    Y = cellfun(@(x) mode(x), labels);
    unique_Y = unique(Y);
    chmm = cell(1, numel(unique_Y));
    ll = cell(1, numel(unique_Y));

    for y = 1:numel(unique_Y)
        if params.verbose>2
            fprintf('-- Training a coupled HMM for label=%d\n', unique_Y(y));
        end
        chmm{y}.label = unique_Y(y);
        seqs_y = seqs(Y==unique_Y(y));
        [chmm{y}, ll{y}] = train_chmm(seqs_y, params);        
    end
end


function [chmm, LLtrace] = train_chmm(seqs, params)
    N = params.nbViews;
    Q = params.nbHiddenStatesMV;
    X = cellfun(@(x) numel(x), params.featureMap);

    % Create model and infernece engine
    chmm   = make_chmm(N,Q,X); 
    engine = smoother_engine(jtree_2TBN_inf_engine(chmm));
    
    % Construct data structure for evidence
    evidence = cell(1,numel(seqs));
    for i=1:numel(seqs)
        evidence{i} = cell(chmm.nnodes_per_slice,size(seqs{i},2));
        for j=1:numel(chmm.observed)
            evidence{i}(chmm.observed(j),:) = ...
                num2cell((seqs{i}(params.featureMap{j},:)),1);
        end
    end

    % Start parameter learning using EM
    [chmm, LLtrace] = learn_params_dbn_em(engine, evidence, ...
        'max_iter', params.maxiter_em, 'verbose', (params.verbose>=2));
end

function [chmm] = make_chmm(N,Q,X) 
    assert( N == size(Q,2), 'Q must be in the size of [1 N]' );
    assert( N == size(X,2), 'X must be in the size of [1 N]' );
    
%     chmm = mk_chmm(N,Q, X);
    

%{ 
    My version. Might work.
    sliceSize = N * 2;
    
    intra = zeros(sliceSize);
    intra(1, 3) = 1;
    intra(2, 4) = 1;
    
    inter = zeros(sliceSize);
    inter(1, [1 2]) = 1;
    inter(2, [1 2]) = 1;
    
    observedNodes = [3 4];
    hiddenNodes = [3 4];
    
    ns = [Q X];
    
    chmm = mk_dbn(intra, inter, ns)
%}

    % Modified from mk_chmm.m
    ss = N*2;
    hnodes = 1:N;
    onodes = (1:N)+N;

    intra = zeros(ss);
    for i=1:N
        intra(hnodes(i), onodes(i))=1;
    end

    inter = zeros(ss);
    for i=1:N
        inter(i, max(i-1,1):min(i+1,N))=1;
    end
    
    ns = [Q X]; 

    eclass1 = [hnodes onodes];
    eclass2 = [hnodes+ss onodes];
    
    dnodes = hnodes;
    
    chmm = mk_dbn(intra, inter, ns, 'discrete', dnodes, 'eclass1', eclass1, 'eclass2', eclass2, ...
        'observed', onodes);
    
    for i=hnodes(:)'
        chmm.CPD{i} = tabular_CPD(chmm, i);
    end
    for i=onodes(:)'
        chmm.CPD{i} = gaussian_CPD(chmm, i);
    end
    for i=hnodes(:)'+ss
        chmm.CPD{i} = tabular_CPD(chmm, i);
    end




%     if ~exist(chmm,'var')
%         error('Implement make_chmm (inside trainCHMM.m)');
%     end
end
