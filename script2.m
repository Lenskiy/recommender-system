load('R_G.mat');

R(length(unique(USER_DATA(:,1))), length(unique(USER_DATA(:,2)))) = 0;

for i = 1:length(unique(USER_DATA(:,1)))
   user_i_idx = find(USER_DATA(:,1) == i);
   item_by_i = USER_DATA(user_i_idx,2);
   ratings_by_i = USER_DATA(user_i_idx,3);
   R(i, item_by_i) = ratings_by_i;
end

Nusers = size(R,1);     %number of users
Nitems = size(R,2);     %number of items
Ngenres = size(G,2);    %number of genres
Nrates = max(max(R));   %number of rates
    
    
movie_genre = {'unknown', 'Action', 'Adventure', 'Animation',... 
    ['Children' char(39) 's'], 'Comedy', 'Crime', 'Documentary', 'Drama',...
    'Fantasy', 'Film-Noir', 'Horror', 'Musical', 'Mystery', 'Romance',...
    'Sci-Fi', 'Thriller', 'War', 'Western'};
              %r g b
colors(1,:) = [0 0 0]; %unknown     % rating 1
colors(2,:) = [1 0 0]; %Action      % rating 2
colors(3,:) = [0 1 0]; %Adventure   % rating 3
colors(4,:) = [0 0 1]; %Animation   % rating 4
colors(5,:) = [1 1 0]; %Children    % rating 5
colors(6,:) = [1 0 1]; %Comedy
colors(7,:) = [0 1 1]; %Crime
colors(8,:) = [0.5 0.5 0.5]; %Documentary
colors(9,:) = [0.0 0.5 0.5]; %Drama
colors(10,:) = [0.5 0.0 0.5]; %Fantasy
colors(11,:) = [0.5 0.5 0.0]; %Film-Noir
colors(12,:) = [0.5 0.0 0.0]; %Horror
colors(13,:) = [0.0 0.5 0.0]; %Musical
colors(14,:) = [0.0 0.0 0.5]; %Mystery
colors(15,:) = [0.5 1 0.5]; %Romance
colors(16,:) = [1 0.5 0.5]; %Sci-Fi
colors(17,:) = [.5 0.5 1];  %Thriller
colors(18,:) = [1 1 0.5];   %War
colors(19,:) = [0.5 1 0.5]; %Western


% Building preference models based on all ratings 
p_UiRatedCkasK = buildPreferencesModels(R, G);
% Estimate likelyhood for item
predictGenres(R, G, 1)
% Ratings for all categories
figure, hold on;
for k = 1:Ngenres
    for j = 1:Nrates
        h(j) = p_UiRatedCkasK(1, k, j)/sum(p_UiRatedCkasK(1, k, :));
    end
    plot(h);
end

%preference models for user u
u = 110;
figure, hold on;
for k = 1:Nrates
    plot(p_UiRatedCkasK(u, :, k), 'color', colors(k, :));
end


%priorProb =  ones(Nrates, Ngenres); % no prior information is given i.e. all categories are equaly probable.
%Use prior information
priorProb = zeros(Nrates, Ngenres);
for k = 1:Nrates
    for i = 1:size(p_UiRatedCkasK,1)
        i_rated_as_k =  find(R(i,:) == k);
        priorProb(k, :) = priorProb(k,:) + sum(G(i_rated_as_k,:));
    end
end
priorProb = priorProb ./ (ones(19,1) * sum(priorProb'))';
    
G_norm = (G - ones(size(G,1),1) * mean(G));
G_norm = G_norm ./ (ones(size(G,1),1) * std(G));
G_cor = (G_norm' * G_norm) / Nitems;
G_cor(logical(eye(size(G_cor)))) = 0;
imagesc(G_cor);
colorbar;
ax = gca;
ax.XTick = [1:19];
ax.YTick = [1:19];
ax.XTickLabel = movie_genre;
ax.YTickLabel = movie_genre;
set(gca, 'XTickLabelRotation', 45)

 % simulate prediction of an item's category N times for different sets of
 % items that are used for training
N = 2;
r = 5;
portion_step = 0.05;
category_prediction_rate_array(19,2) = 0;
prediction_incl_similar_array(19,2) = 0;
for t =  1:19
    t
    portionTesting = t*portion_step; % size of a testing test is (portionTesting * Nitems)
%category prediction is made using preference models estimated based on items ranked as r
    
    %r = 5; 
    cor_th = 0.2;
    N = 5
    clear counter_correct_prediction
    clear counter_similar_prediction;
    for j = 1:N
        training_subset_ind = floor(rand(Nitems - round(Nitems * portionTesting), 1) * Nitems) + 1;
        testing_subset_ind = floor(rand(round(Nitems * portionTesting), 1) * Nitems) + 1;
        p_UiRatedCkasK = buildPreferencesModels(R(:, training_subset_ind), G(training_subset_ind, :));
        counter_correct_prediction(j) = 0;
        counter_similar_prediction(j) = 0;
        j
        for i = 1:length(testing_subset_ind)
            %i
            clear userRatings;
            usersRated_idx = find(R(:, testing_subset_ind(i)) > 0);
            userRatings(1,:) = usersRated_idx;
            for k = 1:length(usersRated_idx)
                userRatings(2, k) =  R(usersRated_idx(k), testing_subset_ind(i));
            end
            likelihood = predictGenresBasedOnPrefModels(p_UiRatedCkasK, testing_subset_ind(i), userRatings, priorProb);
            %[max_val estimated_category] = max(likelihood(r,:));
            [max_val estimated_category] = max(prod(likelihood)); 
            counter_similar_prediction = counter_similar_prediction + ...
                (length(find(G_cor(true_categories, estimated_category) > cor_th)) > 0);

            %likelyhood_norm = likelyhood ./ (ones(5,1) * sum(likelyhood));
            %combined_likelyhood = sum(likelyhood_norm .* (ones(19,1) * [1 2 3 4 5])');
            %[max_val estimated_category] = max(combined_likelyhood);
            true_categories = find (G(i,:) ~= 0);
            if(~isempty(intersect(estimated_category, true_categories)))
                counter_correct_prediction(j) = counter_correct_prediction(j) + 1;
            end
        end    
    end

    category_prediction_rate = counter_correct_prediction/length(testing_subset_ind)
    category_prediction_ratec_array(t,:) = [mean(category_prediction_rate) std(category_prediction_rate)];

    category_prediction_rate_inc_similar = (counter_correct_prediction + counter_similar_prediction) /length(testing_subset_ind)
    prediction_incl_similar_array(t, :) = [mean(category_prediction_rate_inc_similar) std(category_prediction_rate_inc_similar)];
end

likelyhood_norm = likelihood ./ (ones(5,1) * sum(likelihood))

combined_likelyhood = sum(likelyhood_norm .* (ones(19,1) * [1 2 3 4 5])');