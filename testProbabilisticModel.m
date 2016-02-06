function [category_prediction_ratec_array, prediction_incl_similar_array, G_cor] =...
            testProbabilisticModel(R, G, N, portion_step, buildUserPrefenceModel,...
            estimateCondititonalProbability, estimatePosteriorProbability)

    Nusers = size(R,1);     %number of users
    Nitems = size(R,2);     %number of items
    Ncategories = size(G,2);    %number of genres
    Nrates = max(max(R));   %number of rates     
    
    %% Calcuate correlation model
    G_norm = (G - ones(size(G,1),1) * mean(G));      % subtract mean
    G_norm = G_norm ./ (ones(size(G,1),1) * std(G)); % normalize so STD is one 
    G_cor = (G_norm' * G_norm) / Nitems;             % claculte correlation matrix
    G_cor(logical(eye(size(G_cor)))) = 0;            % Zero main diagonal   

    predicted_category_hist = zeros(Ncategories,  Nrates);

    for t =  1:(round(1/portion_step) - 1)
        t
        portionTraining = t*portion_step; % size of a testing test is (portionTesting * Nitems)
        %category prediction is made using preference models estimated based on items ranked as r
        cor_th = 0.1;
        clear counter_correct_prediction;
        clear counter_similar_prediction;
        clear correctly_predicted_items;
        G_est = zeros(Nitems, Ncategories);
        for j = 1:N
            training_subset_ind = randperm(Nitems, floor(Nitems * portionTraining));
            testing_subset_ind =  setdiff(1:Nitems, training_subset_ind);
            R_train = R;
            R_test = R;
            R_train(:, testing_subset_ind) = [];
            R_test(:, training_subset_ind) = [];
            G_train = G;
            G_test = G;
            G_train(testing_subset_ind,:) = [];
            G_test(training_subset_ind,:) = [];
            [Pr_Category Pr_UratedC] = buildUserPrefenceModel(R_train, G_train);


            counter_correct_prediction(j, 1:Nrates) = 0;
            counter_similar_prediction(j, 1:Nrates) = 0;
            Pr_ItemInCategory = estimateCondititonalProbability(Pr_UratedC, R_test); %164 %175
            Pr_CategoryGivenI = estimatePosteriorProbability(Pr_ItemInCategory, Pr_Category);
            for i = 1:length(testing_subset_ind)
                 %figure, hold on;
                for r = 1:Nrates
                    %plot(Pr_CategoryGivenI(i,:,k));
                    likelihood(r, :) = Pr_CategoryGivenI(:, i, r);
                    [max_val estimated_category] = max(likelihood(r,:));
                    %[max_val estimated_category] = max(sum(log(likelihood)));  %./ (ones(1,Ncategories)' * Rnum)'
                    %[votes estimated_category] = max(hist(estimated_category, unique(estimated_category)));
                    predicted_category_hist(estimated_category, r) = predicted_category_hist(estimated_category, r) + 1;
                    true_categories = find(G_test(i,:) ~= 0);
                    counter_similar_prediction(j, r) = counter_similar_prediction(j, r) + ...
                        (length(find(G_cor(true_categories, estimated_category(:)) > cor_th)) > 0);
                    %likelihood_norm = likelihood ./ (ones(5,1) * sum(likelihood));
                    %combined_likelihood = sum(likelihood_norm .* (ones(19,1) * [1 2 3 4 5])');
                    %[max_val estimated_category] = max(combined_likelihood);
                    if(~isempty(MY_intersect(estimated_category(:), true_categories)))
                        counter_correct_prediction(j, r) = counter_correct_prediction(j, r) + 1;
                        G_est(testing_subset_ind(i), estimated_category(:)) = 1;
                    end
                end
            end
        end
        category_prediction_rate = counter_correct_prediction/length(testing_subset_ind)
        category_prediction_ratec_array(t ,:, :) = [mean(category_prediction_rate); std(category_prediction_rate)];

        category_prediction_rate_inc_similar = (counter_correct_prediction + counter_similar_prediction)/length(testing_subset_ind);
        prediction_incl_similar_array(t ,:, :) = [mean(category_prediction_rate_inc_similar); std(category_prediction_rate_inc_similar)];
    end
end