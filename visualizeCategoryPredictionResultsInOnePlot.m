function visualizeCategoryPredictionResultsInOnePlot(category_prediction_ratec_array, prediction_incl_similar_array, portion_step) 
    Nrates = size(category_prediction_ratec_array,3);
	figure('Position', [100, 100, 540, 257]), hold on, grid on;
	title(['Prediction based on ratings r = {1,2,3,4,5}']);
	xlabel('Precentage of the total data used for training');
	ylabel('Correct prediction');
    for r = 1:Nrates
        ax = errorbar(category_prediction_ratec_array(:,1, r), category_prediction_ratec_array(:,2, r));
        %plot( prediction_incl_similar_array(:,1, r), 'color', ax.Color, 'LineStyle', ':');
    end
	ghandler = gca;
	ghandler.XTick = [1:19];
	ghandler.XTickLabel = [ ((1:19) * portion_step) * 100];
	legend({'r = 1', 'r = 2','r = 3','r = 4','r = 5',},'Location','northwest','Orientation','vertical','FontWeight','bold');
	legend('boxoff');
end