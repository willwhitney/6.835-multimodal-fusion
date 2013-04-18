% Spring 2013 6.835 Intelligent Multimodal Interfaces
%
% plot_confmat( confmat, mytitle )
% 

function plot_confmat( confmat, mytitle )
    if ~exist('mytitle','var')
        mytitle = 'No Title';
    end

    nbLabels = size(confmat,1);
    for i=1:nbLabels,
        confmat(:,i) = confmat(:,i)/sum(confmat(:,i));
    end

    figure;
    %colormap(gray);
    imagesc(confmat,[0 1]);
    xlabel('Ground Truth');
    ylabel('Prediction');
    set(gca, 'XTick', 1:nbLabels);
    set(gca, 'YTick', 1:nbLabels);
    set(gca, 'TickLength', [0 0]);
    title(mytitle);
    colorbar;

    for x=1:nbLabels,
        y = x;
        for y=1:nbLabels,  
            text('Position', [(y-.5)/nbLabels, 1-(x-.5)/nbLabels], ...
                 'String', sprintf('%.2f', confmat(x,y)), ...                
                 'FontWeight', 'demi', ...
                 'HorizontalAlignment', 'center', ...
                 'Units', 'normalized', ...
                 'Color', [0 0 0]);           
        end            
    end

    for x=1:nbLabels,
        line([x-.5 x-.5], [0 nbLabels+.5], 'Color', 'k');
    end        
    for y=1:nbLabels,
        line([0 nbLabels+.5], [y-.5 y-.5], 'Color', 'k');
    end
end

