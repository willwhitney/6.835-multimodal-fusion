% Spring 2013 6.835 Intelligent Multimodal Interfaces
%
% [ confmat ] = build_confmat( prediction, groundtruth )
%
function [ confmat ] = build_confmat( prediction, groundtruth )

    if min(prediction)==0
        for i=1:numel(prediction)
            prediction(i) = prediction(i)+1;
        end
    end
    if min(groundtruth)==0
        for i=1:numel(groundtruth)
            groundtruth(i) = groundtruth(i)+1;
        end
    end

    unique_y = unique(groundtruth);
    confmat = zeros(numel(unique_y),numel(unique_y));

    for i=1:numel(groundtruth)
        confmat(prediction(i),groundtruth(i)) = confmat(prediction(i),groundtruth(i)) + 1;
    end

end

