% R(length(unique(USER_DATA(:,1))), length(unique(USER_DATA(:,2)))) = 0;
% 
% for i = 1:length(unique(USER_DATA(:,1)))
%    user_i_idx = find(USER_DATA(:,1) == i);
%    item_by_i = USER_DATA(user_i_idx,2);
%    ratings_by_i = USER_DATA(user_i_idx,3);
%    R(i, item_by_i) = ratings_by_i;
% end
% 
% movie_genre = {'Action', 'Aventure', 'Animation', ['Children' char(39) 's'],... 
%     'Comedy', 'Crime', 'Documentary', 'Drama', 'Fantasy', 'Film-Noir', 'Horror',...
%     'Musical', 'Mystery', 'Romance','Sci-Fi', 'Thriller', 'War', 'Western'};
% 
% G = zeros(movies{end,1}, length(movie_genre));
% for i = 1:size(movies,1)
%     %i
%     for c = 1:18
%         for j = 2:7
%             if(strcmp(movies{i,j}, movie_genre{c}))
%                 G(movies{i,1}, c) = strcmp(movies{i,j}, movie_genre{c});
%             end
%         end
%     end
% end

%% Data preparation: replace this section with new data. R is rating and G is category matrix
DB = '100k';
switch(DB)
    case '100k'
        load('R_G.mat');
        R(:, find(G(:,1) == 1)) = []; % Remove genre 1 - uknown 
        G(find(G(:,1) == 1), :) = []; % Remove genre 1 - uknown
        G(:, 1) = [];
        G = (G' ./ (ones(size(G,2), 1) * sum(G')))'; %convert to probabilities, each row sums up to one
    case '1M'
        load('R_G_1M.mat');
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
N = 10;
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