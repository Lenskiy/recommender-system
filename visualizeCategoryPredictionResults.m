function visualizeCategoryPredictionResults(category_prediction_ratec_array, prediction_incl_similar_array, portion_step) 
    Nrates = size(category_prediction_ratec_array,3);
    
    for r = 1:Nrates
        figure('Position', [100, 100, 540, 257]), hold on, grid on;
        ax = errorbar(category_prediction_ratec_array(:,1, r), category_prediction_ratec_array(:,2, r));
        plot( prediction_incl_similar_array(:,1, r), 'color', ax.Color, 'LineStyle', ':');
        title(['Prediction based on rating r = ' num2str(r)]);
        xlabel('Precentage of the total data used for training');
        ylabel('Correct prediction');
        ghandler = gca;
        ghandler.XTick = [1:19];
        ghandler.XTickLabel = [ ((1:19) * portion_step) * 100];
        legend({'Prediction rate', 'Prediction rate including correlated genres '},'Location','northwest','Orientation','vertical','FontWeight','bold');
        legend('boxoff');
    end
end