load('R_G.mat');

unknown_items = find(G(:,1) == 1);

R(:, unknown_items) = [];
G(unknown_items, :) = [];
G(:, 1) = [];


Nusers = size(R,1);     %number of users
Nitems = size(R,2);     %number of items
Ncategories = size(G,2);    %number of genres
Nrates = max(max(R));   %number of rates

movie_genre = {'Action', 'Adventure', 'Animation',... 
    ['Children' char(39) 's'], 'Comedy', 'Crime', 'Documentary', 'Drama',...
    'Fantasy', 'Film-Noir', 'Horror', 'Musical', 'Mystery', 'Romance',...
    'Sci-Fi', 'Thriller', 'War', 'Western'};
    
[Pr_ItemInCategory Pr_Item Pr_Category] = buildBernoulliModel(R, G);

Pr_CategoryGivenI = estimatePosteriorProbability(Pr_ItemInCategory, Pr_Item, Pr_Category);


G_norm = (G - ones(size(G,1),1) * mean(G));
G_norm = G_norm ./ (ones(size(G,1),1) * std(G));
G_cor = (G_norm' * G_norm) / Nitems;
G_cor(logical(eye(size(G_cor)))) = 0;
imagesc(G_cor);
colorbar;
ax = gca;
ax.XTick = [1:Ncategories];
ax.YTick = [1:Ncategories];
ax.XTickLabel = movie_genre;
ax.YTickLabel = movie_genre;
set(gca, 'XTickLabelRotation', 45)

Rnum(1) = length(find(R == 1));
Rnum(2) = length(find(R == 2));
Rnum(3) = length(find(R == 3));
Rnum(4) = length(find(R == 4));
Rnum(5) = length(find(R == 5));
 % simulate prediction of an item's category N times for different sets of
 % items that are used for training
predicted_category_hist(Ncategories,  Nrates) = 0;
N = 2;
%r = 5; 
portion_step = 0.05;
category_prediction_rate_array(Ncategories,2) = 0;
prediction_incl_similar_array(Ncategories,2) = 0;
clear category_prediction_rate_inc_similar
clear category_prediction_rate
for t =  1:19
    t
    portionTraining = t*portion_step; % size of a testing test is (portionTesting * Nitems)
    %category prediction is made using preference models estimated based on items ranked as r
    cor_th = 0.2;
    clear counter_correct_prediction;
    clear counter_similar_prediction;
    clear correctly_predicted_items;
    G_est = zeros(Nitems, Nrates);
    for j = 1:N
        training_subset_ind =  randperm(Nitems, floor(Nitems * portionTraining) + 1);
        testing_subset_ind =  setdiff(1:Nitems, training_subset_ind);
        R_ = R;%(:, training_subset_ind);
        %R_(:, testing_subset_ind) = 0;
        G_ = G;%G(training_subset_ind,:);
        G_(testing_subset_ind,:) = 0;
        [Pr_ItemInCategory Pr_Item Pr_Category] = buildBernoulliModel(R_, G_);
        counter_correct_prediction(j, Nrates) = 0;
        counter_similar_prediction(j, Nrates) = 0;
        j
        Pr_CategoryGivenI = estimatePosteriorProbability(Pr_ItemInCategory, Pr_Item, Pr_Category);
        for i = 1:length(testing_subset_ind)
             %figure, hold on;
            for r = 1:Nrates
                %plot(Pr_CategoryGivenI(i,:,k));
                likelihood(r, :) = Pr_CategoryGivenI(testing_subset_ind(i),:,r);
                [max_val estimated_category] = max(likelihood(r,:));
                %[max_val estimated_category] = max(sum(log(likelihood)));  %./ (ones(1,Ncategories)' * Rnum)'
                %[votes estimated_category] = max(hist(estimated_category, unique(estimated_category)));
                predicted_category_hist(estimated_category, r) = predicted_category_hist(estimated_category, r) + 1;
                true_categories = find (G(i,:) ~= 0);
                counter_similar_prediction(j, r) = counter_similar_prediction(j, r) + ...
                    (length(find(G_cor(true_categories, estimated_category(:)) > cor_th)) > 0);
                %likelihood_norm = likelihood ./ (ones(5,1) * sum(likelihood));
                %combined_likelihood = sum(likelihood_norm .* (ones(19,1) * [1 2 3 4 5])');
                %[max_val estimated_category] = max(combined_likelihood);
                if(~isempty(intersect(estimated_category(:), true_categories)))
                    counter_correct_prediction(j, r) = counter_correct_prediction(j, r) + 1;
                    G_est(testing_subset_ind(i), estimated_category(:)) = 1;
                end
            end
        end
    end
    for r = 1:Nrates
        category_prediction_rate(:, r) = counter_correct_prediction(:, r)/length(testing_subset_ind)
        category_prediction_ratec_array(t ,:, r) = [mean(category_prediction_rate(:, r)) std(category_prediction_rate(:, r))];

        category_prediction_rate_inc_similar(:, r) = (counter_correct_prediction(:, r) + counter_similar_prediction(:, r)) /length(testing_subset_ind)
        prediction_incl_similar_array(t, :, r) = [mean(category_prediction_rate_inc_similar(:, r)) std(category_prediction_rate_inc_similar(:, r))];
    end
end
figure, hold on, grid on;
for r = 1:Nrates
    ax = errorbar(category_prediction_ratec_array(:,1, r), category_prediction_ratec_array(:,2, r));

    %errorbar(prediction_incl_similar_array(:,1, r), prediction_incl_similar_array(:,2, r), 'color', ax.Color);
    xlabel('Precentage of the total data used for training')
    ylabel('Correct prediction')
    ax = gca;
    ax.XTick = [1:Ncategories];
    ax.XTickLabel = [ ((1:Ncategories) * portion_step) * 100];
end
% pred = find(correctly_predicted_items(1,:) > 0);
% sum(G(pred,:))
% figure, hold on;
% plot(sum(G(pred,:))/sum(sum(G(pred,:))),'g');
% plot(Pr_Category)
