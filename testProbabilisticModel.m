function [category_prediction_ratec_array, prediction_incl_similar_array, G_est, G_cor] =...
            testProbabilisticModel(R, G, N, train_parts, test_parts, buildUserPrefenceModel,...
            estimateCondititonalProbability, estimatePosteriorProbability)

    Nusers = size(R,1);         %number of users
    Nitems = size(R,2);         %number of items
    Ncategories = size(G,2);    %number of genres
    Nrates = max(max(R));       %number of rates     
    
    %% Calcuate correlation model
    G_norm = (logical(G) - ones(size(G,1),1) * mean(logical(G)));      % subtract mean
    G_norm = G_norm ./ (ones(size(G,1),1) * std(logical(G))); % normalize so STD is one 
    G_cor = (G_norm' * G_norm) / Nitems;             % claculte correlation matrix
    G_cor(logical(eye(size(G_cor)))) = 0;            % Zero main diagonal   

    
    if(train_parts + test_parts > 1)
        disp('Training and testing portion of the data all together should not be larger than 1');
    end
    for t =  1:length(train_parts)
        t
        trainingPortion = train_parts(t); % size of a testing test is (portionTesting * Nitems)
        testingPortion = test_parts(t); 
        %category prediction is made using preference models estimated based on items ranked as r
        cor_th = 0.1;
        clear counter_correct_prediction;
        clear counter_similar_prediction;
        clear correctly_predicted_items;
        G_est = zeros(Nitems, Ncategories);
        counter_similar_prediction = zeros(N, Nrates);
        for j = 1:N
            j
            training_subset_ind = randperm(Nitems, floor(Nitems * trainingPortion)); % select training samples randomly
            testing_subset_ind =  setdiff(1:Nitems, training_subset_ind); % choose remaing samples that are not part of training
             %select portion of them
            testing_subset_ind =  testing_subset_ind(randperm(length(testing_subset_ind), floor(Nitems*testingPortion)));

            R_train = R(:, training_subset_ind);
            R_test = R(:, testing_subset_ind);
            G_train = G(training_subset_ind,:);
            G_test = G(testing_subset_ind,:);
            [Pr_Category Pr_UratedC] = buildUserPrefenceModel(R_train, G_train);

            maxNumOfGenPerMovies = max(sum((G~=0)'));
            counter_correct_prediction(j, 1:Nrates, maxNumOfGenPerMovies) = 0;
            Pr_ItemInCategory = estimateCondititonalProbability(Pr_UratedC, R_test); %164 %175
            Pr_CategoryGivenI = estimatePosteriorProbability(Pr_ItemInCategory, Pr_Category);
            for i = 1:length(testing_subset_ind)
                 %figure, hold on;
                for r = 1:Nrates
                        %plot(Pr_CategoryGivenI(i,:,k));
                        likelihood(r, :) = Pr_CategoryGivenI(:, i, r);
                        true_categories = find(G_test(i,:) ~= 0);
                        if(isempty(true_categories))
                            continue;
                        end
                        [max_val estimated_category] = maxN(likelihood(r, :), length(true_categories)); 
                        
                        %overlap_pred_true = MY_intersect(estimated_category(:), true_categories);

                        %[max_val estimated_category] = max(sum(log(likelihood)));  %./ (ones(1,Ncategories)' * Rnum)'
                        %[votes estimated_category] = max(hist(estimated_category, unique(estimated_category)));
                        %predicted_category_hist(best_cat, r) = predicted_category_hist(best_cat, r) + 1;
                        counter_similar_prediction(j, r) = counter_similar_prediction(j, r) + uint8(sum(sum(G_cor(true_categories, estimated_category(1)) > cor_th)) > 0);
                        %likelihood_norm = likelihood ./ (ones(5,1) * sum(likelihood));
                        %combined_likelihood = sum(likelihood_norm .* (ones(19,1) * [1 2 3 4 5])');
                        %[max_val estimated_category] = max(combined_likelihood);

%                         if(isempty(overlap_pred_true))
%                             continue;
%                         end
                        G_est(testing_subset_ind(i), estimated_category(:)) = 1;
                        for c = 1:max(length(true_categories))
                            overlap_pred_true = MY_intersect(estimated_category(1:c), true_categories);
                            if(length(overlap_pred_true) == c)
                                counter_correct_prediction(j, r, c) = counter_correct_prediction(j, r, c) + 1;
                            end
                        end
                end
            end
        end
        
        for c = 1:maxNumOfGenPerMovies
            total = sum(sum(c <= sum(logical(G_test)')));
            if(total ~= 0)
                category_prediction_rate = counter_correct_prediction(:,:,c)/total
                category_prediction_ratec_array{c}(t ,:, :) = [mean(category_prediction_rate); std(category_prediction_rate)];
            end
        end
        
        category_prediction_rate_inc_similar = (counter_correct_prediction(:,:,1) + counter_similar_prediction)/length(testing_subset_ind);
        prediction_incl_similar_array(t ,:, :) = [mean(category_prediction_rate_inc_similar); std(category_prediction_rate_inc_similar)];
    end
end