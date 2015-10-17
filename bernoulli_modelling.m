load('R_G.mat');


Nusers = size(R,1);     %number of users
Nitems = size(R,2);     %number of items
Ncategories = size(G,2);    %number of genres
Nrates = max(max(R));   %number of rates
    
%[Pr_ItemInCategory Pr_Item Pr_Category] = buildBernoulliModel(R, G);

%Pr_CategoryGivenI = estimatePosteriorProbability(Pr_ItemInCategory, Pr_Item, Pr_Category);



 % simulate prediction of an item's category N times for different sets of
 % items that are used for training
N = 20;
portionTesting = 0.1; % size of a testing test is (portionTesting * Nitems)
%category prediction is made using preference models estimated based on items ranked as r
%r = 1; 
for j = 1:N
    training_subset_ind = floor(rand(Nitems - round(Nitems * portionTesting), 1) * Nitems) + 1;
    testing_subset_ind = floor(rand(round(Nitems * portionTesting), 1) * Nitems) + 1;
    [Pr_ItemInCategory Pr_Item Pr_Category] = buildBernoulliModel(R(:, training_subset_ind), G(training_subset_ind, :));
    counter_correct_prediction(j) = 0;
    j
    Pr_CategoryGivenI = estimatePosteriorProbability(Pr_ItemInCategory, Pr_Item, Pr_Category);
    for i = 1:length(testing_subset_ind)
         %figure, hold on;
        for k = 1:Nrates
            %plot(Pr_CategoryGivenI(i,:,k));
            likelyhood(k, :) = Pr_CategoryGivenI(i,:,k);
        end
        [max_val estimated_category] = max(prod(likelyhood));
        true_categories = find (G(i,:) ~= 0);
        %likelyhood_norm = likelyhood ./ (ones(5,1) * sum(likelyhood));
        %combined_likelyhood = sum(likelyhood_norm .* (ones(19,1) * [1 2 3 4 5])');
        %[max_val estimated_category] = max(combined_likelyhood);
        if(~isempty(intersect(estimated_category, true_categories)))
            counter_correct_prediction(j) = counter_correct_prediction(j) + 1;
        end
    end
end

category_prediction_rate = counter_correct_prediction/length(testing_subset_ind)
[mean(category_prediction_rate) std(category_prediction_rate)]