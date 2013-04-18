% Spring 2013 6.835 Intelligent Multimodal Interfaces
%
% [ I ] = split_data( labels, separation_ratio )
%
% Input
%   labels - 1xN cell of labels
%   ratio  - [train validate test unlabeled] split
%
% Output
%   I      - Indices of each split

function [ I ] = split_data( labels, ratio )
    assert( numel(ratio)==4 ); % [train validate test unlabeled]
    ratio = ratio / sum(ratio);
    cum_ratio = cumsum(ratio);
    
    Y = cellfun(@(x) unique(x), labels);    
    I.train=[]; I.validate=[]; I.test=[]; I.unlabeled=[];
    for y=1:numel(unique(Y))
        idx = find(Y==y);
        cnt = floor(numel(idx)*cum_ratio);
        I.train     = horzcat(I.train,    idx(1:cnt(1)));
        I.validate  = horzcat(I.validate, idx(cnt(1)+1:cnt(2)));
        I.test      = horzcat(I.test,     idx(cnt(2)+1:cnt(3)));
        I.unlabeled = horzcat(I.unlabeled,idx(cnt(3)+1:end));
    end    
end

