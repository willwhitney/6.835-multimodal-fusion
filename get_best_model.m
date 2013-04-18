% Spring 2013 6.835 Intelligent Multimodal Interfaces
%
% [ max_idx ] = get_best_model( R )
%  

function [ max_idx ] = get_best_model( R )
    max_idx=-1; max_val=-1; 
    for i=1:numel(R)
        r = R{i}; 
        if r.stat.validate.accuracy > max_val
            max_val = r.stat.validate.accuracy;
            max_idx = i;
        end
    end
end

