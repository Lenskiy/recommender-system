%% Preprocess the data and put it in R and G matrices
% R(length(unique(USER_DATA(:,1))), length(unique(USER_DATA(:,2)))) = uint8(0);
% item_set_from_ratings = unique(USER_DATA(:,2));
% l = length(unique(USER_DATA(:,1)));
% for u = 1:l %u is for users
%    user_u_idx = find(USER_DATA(:,1) == u);
%    items_by_u = USER_DATA(user_u_idx,2);
%    clear items_by_u_nogaps;
%    for i = 1:length(items_by_u)
%         items_by_u_nogaps(i) = find(item_set_from_ratings == items_by_u(i));
%    end
%    ratings_by_i = uint8(2*USER_DATA(user_u_idx,3) - 1);
%    R(u, items_by_u_nogaps) = ratings_by_i;
%    u/l
% end
% 
% movie_genre = {'Action', 'Aventure', 'Animation', ['Children' char(39) 's'],... 
%     'Comedy', 'Crime', 'Documentary', 'Drama', 'Fantasy', 'Film-Noir', 'Horror',...
%     'Musical', 'Mystery', 'Romance','Sci-Fi', 'Thriller', 'War', 'Western'};
% 
% for i = 1:size(movies,1)
%     moviesID(i) = movies{i,1};
% end
% 
% 
% G = zeros(length(unique(USER_DATA(:,2))), length(movie_genre));
% for i = 1:length(moviesID)
%     i
%     ind = find(moviesID(i) == item_set_from_ratings);
%     if(~isempty(ind))
%         for c = 1:length(movie_genre)
%             for j = 2:size(movies,2)
%                 if(strcmp(movies{i,j}, movie_genre{c}))
%                     G(ind, c) = 1;
%                 end
%             end
%         end
%     end
% end

%% Data preparation: replace this section with new data. R is rating and G is category matrix
DB = '20M';
switch(DB)
    case '100k'
        load('R_G.mat');
        R(:, find(G(:,1) == 1)) = []; % Remove genre 1 - uknown 
        G(find(G(:,1) == 1), :) = []; % Remove genre 1 - uknown
        G(:, 1) = [];
        G = (G' ./ (ones(size(G,2), 1) * sum(G')))'; %convert to probabilities, each row sums up to one
    case '1M'
        load('R_G_1M.mat');
    case '20M'
        load('R_G_20M.mat');        
end

%% 
Nusers = size(R,1);     %number of users
Nitems = size(R,2);     %number of items
Ncategories = size(G,2);    %number of genres
Nrates = max(max(R));   %number of rates

%% Plot figures for the paper     
[Pr_Category Pr_UratedC] = buildUserPrefenceModel(R, G);
r = 3;
figure('Position', [100, 100, 540, 1.5*257]), hold on, grid on;
axis([1 18 1 size(R,1) 0, max(max(Pr_UratedC(:,:,r)))]);
xlabel('categories');ylabel('users');zlabel(['P(genre, user, ' num2str(r) ')']);
for c = 1:Ncategories
    plot3(c*ones(1,Nusers), 1:Nusers, Pr_UratedC(:,c,r));
end

Rt = (R == r);
figure('Position', [100, 100, 540, 1.5*257]), hold on, grid on;
axis([1 18 1 size(R,1) 0, max(max(Pr_UratedC(:,:,r)))]);
xlabel('categories');ylabel('users');zlabel(['R_1(:,item) P(genre, user, ' num2str(r) ')']);
for c = 1:Ncategories
    prIgivenC(c) = prod(Rt(:,1).*Pr_UratedC(:,c,r) + (1 - Rt(:,1)).*(1 - Pr_UratedC(:,c,r)));
    plot3(c*ones(1,Nusers), 1:Nusers, Rt(:,1).*Pr_UratedC(:,c,r));
end

%% Bernoulli model 
%Simulate prediction of an item's category N times for different sets of items that are used for training
N = 2;
portion_step = 0.05;
[Bernoulli_category_prediction_ratec_array, Bernoulli_prediction_incl_similar_array, G_cor] =...
            testProbabilisticModel(R, G, N, portion_step, @buildUserPrefenceModel,...
            @estimateCondititonalPrBernoulli, @estimatePosteriorProbability);

%visualizeCategoryPredictionResults(Bernoulli_category_prediction_ratec_array, Bernoulli_prediction_incl_similar_array, portion_step);
visualizeCategoryPredictionResultsInOnePlot(Bernoulli_category_prediction_ratec_array, Bernoulli_prediction_incl_similar_array, portion_step);

% Multinomial model 
[likelihood_category_prediction_ratec_array, likelihood_prediction_incl_similar_array, G_cor] =...
            testProbabilisticModel(R, G, N, portion_step, @buildUserPrefenceModel,...
            @estimateCondititonalPrLikelihood, @estimatePosteriorProbability);

visualizeCategoryPredictionResultsInOnePlot(likelihood_category_prediction_ratec_array, likelihood_prediction_incl_similar_array, portion_step);
%% Visualize correlation matrix
% figure, imagesc(G_cor);                                 
% colorbar;
% ax = gca;
% ax.XTick = [1:Ncategories];
% ax.YTick = [1:Ncategories];
% ax.XTickLabel = movie_genre;
% ax.YTickLabel = movie_genre;
% set(gca, 'XTickLabelRotation', 45)