function [best_users_id users_trials predictions] = searchForBestUsers(R, G, N, train_part, buildUserPrefenceModel,...
            estimateCondititonalProbability, estimatePosteriorProbability)


    Nusers = size(R,1);         %number of users
    Nitems = size(R,2);         %number of items
    Ncategories = size(G,2);    %number of genres
    Nrates = max(max(R))        %length(unique(unique(R))) - 1;       %number of rates     
    
    

    trainingPortion = train_part; % size of a testing test is (portionTesting * Nitems)
    
    training_portion_of_items = 0.6;
    testing_portion_of_items = 1 - training_portion_of_items;
    
    %category prediction is made using preference models estimated based on items ranked as r

    clear counter_correct_prediction;
    clear counter_similar_prediction;
    clear correctly_predicted_items;
    the_best_prediction = 0;
    
    for k = 1:round(sqrt(N))
        training_item_subset_ind = randperm(Nitems, floor(Nitems * training_portion_of_items)); % select training samples randomly
        testing_item_subset_ind =  setdiff(1:Nitems, training_item_subset_ind); % choose remaing samples that are not part of training
        k

        for j = 1:round(sqrt(N))
            %j
            training_user_subset_ind = randperm(Nusers, floor(Nusers * trainingPortion)); % select training samples randomly
            testing_user_subset_ind =  setdiff(1:Nusers, training_user_subset_ind); % choose remaing samples that are not part of training
            %select portion of them
            %testing_item_subset_ind =  testing_item_subset_ind(randperm(length(testing_item_subset_ind), floor(Nitems * testing_portion_of_items)));

            R_train = R(training_user_subset_ind, training_item_subset_ind);
            R_test = R(training_user_subset_ind, testing_item_subset_ind);
            G_train = G(training_item_subset_ind,:);
            G_test = G(testing_item_subset_ind,:);
            [Pr_Category Pr_UratedC] = buildUserPrefenceModel(R_train, G_train);

            maxNumOfGenPerMovies = max(sum((G~=0)'));
            counter_correct_prediction = zeros(Nrates, maxNumOfGenPerMovies);
            Pr_ItemInCategory = estimateCondititonalProbability(Pr_UratedC, R_test); %164 %175
            Pr_CategoryGivenI = estimatePosteriorProbability(Pr_ItemInCategory, Pr_Category);

            for i = 1:length(testing_item_subset_ind)
                for r = 1:Nrates
                    likelihood(r, :) = Pr_CategoryGivenI(:, i, r);
                    true_categories = find(G_test(i,:) ~= 0);
                    if(isempty(true_categories))
                        continue;
                    end

                    [max_val estimated_category] = maxN(likelihood(r, :), length(true_categories)); 

                    for c = 1:max(length(true_categories))
                        overlap_pred_true = MY_intersect(estimated_category(1:c), true_categories);
                        if(length(overlap_pred_true) == c)
                            counter_correct_prediction(r, c) = counter_correct_prediction(r, c) + 1;
                        end
                    end
                end
            end

            for c = 1:maxNumOfGenPerMovies
                total = sum(sum(c <= sum(logical(G_test)')));
                if(total ~= 0)
                    category_prediction_rate = counter_correct_prediction(:,c)/total;
                    category_prediction_ratec_array{c}(:) = category_prediction_rate;
                end
            end

            %check if current prediction is better than all previous
            if(max(category_prediction_ratec_array{1} ) > the_best_prediction)
                the_best_prediction = max(category_prediction_ratec_array{1});
                best_users_id = (k-1)*round(sqrt(N))+j;
            end

            users_trials((k-1)*round(sqrt(N))+j, :) = training_user_subset_ind;
            predictions((k-1)*round(sqrt(N))+j, :) = category_prediction_ratec_array{1};

        end    
    end
end