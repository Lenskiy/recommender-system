load('R_G.mat');


Nusers = size(R,1);     %number of users
Nitems = size(R,2);     %number of items
Ncategories = size(G,2);    %number of genres
Nrates = max(max(R));   %number of rates
    
%[Pr_ItemInCategory Pr_Item Pr_Category] = buildBernoulliModel(R, G);

%Pr_CategoryGivenI = estimatePosteriorProbability(Pr_ItemInCategory, Pr_Item, Pr_Category);


G_norm = (G - ones(size(G,1),1) * mean(G));
G_norm = G_norm ./ (ones(size(G,1),1) * std(G));
G_cor = (G_norm' * G_norm) / Nitems;
G_cor(logical(eye(size(G_cor)))) = 0;
imagesc(G_cor);
colorbar;

Rnum(1) = length(find(R == 1));
Rnum(2) = length(find(R == 2));
Rnum(3) = length(find(R == 3));
Rnum(4) = length(find(R == 4));
Rnum(5) = length(find(R == 5));
 % simulate prediction of an item's category N times for different sets of
 % items that are used for training
N = 5;
portionTesting = 0.1; % size of a testing test is (portionTesting * Nitems)
%category prediction is made using preference models estimated based on items ranked as r
r = 5; 
cor_th = 0.2;
clear counter_correct_prediction;
clear counter_similar_prediction;
for j = 1:N
    training_subset_ind = floor(rand(Nitems - round(Nitems * portionTesting), 1) * Nitems) + 1;
    testing_subset_ind = floor(rand(round(Nitems * portionTesting), 1) * Nitems) + 1;
    [Pr_ItemInCategory Pr_Item Pr_Category] = buildBernoulliModel(R(:, training_subset_ind), G(training_subset_ind, :));
    counter_correct_prediction(j) = 0;
    counter_similar_prediction(j) = 0;
    j
    Pr_CategoryGivenI = estimatePosteriorProbability(Pr_ItemInCategory, Pr_Item, Pr_Category);
    for i = 1:length(testing_subset_ind)
         %figure, hold on;
        for k = 1:Nrates
            %plot(Pr_CategoryGivenI(i,:,k));
            likelihood(k, :) = Pr_CategoryGivenI(i,:,k);
        end
        %[max_val estimated_category] = max(likelihood(r,:));
        [max_val estimated_category] = max(prod(likelihood));  %./ (ones(1,Ngenres)' * Rnum)'
        %[votes estimated_category] = max(hist(estimated_category, unique(estimated_category)));
        true_categories = find (G(i,:) ~= 0);
        counter_similar_prediction(j) = counter_similar_prediction(j) + ...
            (length(find(G_cor(true_categories, estimated_category) > cor_th)) > 0);
        %likelihood_norm = likelihood ./ (ones(5,1) * sum(likelihood));
        %combined_likelihood = sum(likelihood_norm .* (ones(19,1) * [1 2 3 4 5])');
        %[max_val estimated_category] = max(combined_likelihood);
        if(~isempty(intersect(estimated_category, true_categories)))
            counter_correct_prediction(j) = counter_correct_prediction(j) + 1;
        end
    end
end

category_prediction_rate = counter_correct_prediction/length(testing_subset_ind)
prediction = [mean(category_prediction_rate) std(category_prediction_rate)]

category_prediction_rate_inc_similar = (counter_correct_prediction + counter_similar_prediction) /length(testing_subset_ind)
prediction_incl_similar = [mean(category_prediction_rate_inc_similar) std(category_prediction_rate_inc_similar)]
