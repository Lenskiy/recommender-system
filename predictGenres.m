function likelyhood = predictGenres(R, G, item)
    noRatredProb = 0.01;
    Nusers = size(R,1);     %number of users
    Nitems = size(R,2);     %number of items
    Ngenres = size(G,2);    %number of genresp
    Nrates = max(max(R));   %number of rates

    p_UiRatedCkasK = buildPreferencesModels(R, G);
    
   for k = 1:5
       [user_ind item_ind] = find(R == k);
       weight(k, :) = sum(G(item_ind,:));
   end


    %P_UinC = sum(G) / sum(sum(G)); %Nusers;   %prior probabilities
	likelyhood =  ones(5, Ngenres) / Ngenres;
    %likelyhood = [P_UinC; P_UinC; P_UinC; P_UinC; P_UinC];
    %likelyhood = weight;
    for r = 1:Nrates
        usersRated = find(R(:,item) == r);
        %figure, hold on; title(['Users that rated this movie as ' num2str(r)]);
        for u = 1:length(usersRated) %plot dynamicaly how likelyhood changes
            preferenceModel = p_UiRatedCkasK(usersRated(u), :, r);
            %plot(preferenceModel);
            notRatedCategories = find(preferenceModel == 0);
            numberOfNotRatedCategories = length(notRatedCategories);
            % We should replace zero probabilities with some small
            % probability noRatredProb to avoid the case when becaue of zero
            % number of ratings in some categories for some user will
            % result in result likelyhood zero for this category, even thought
            % other user has ratings of this category.
            % When zeros replaced with noRatredProb, the remaining
            % probabilites should be corrected so the likelyhood sum to 1.
            if(numberOfNotRatedCategories > 0) 
                ratedCategories = find(preferenceModel ~= 0);
                normParam =  noRatredProb * numberOfNotRatedCategories / (Ngenres - numberOfNotRatedCategories);
                preferenceModel(ratedCategories) = preferenceModel(ratedCategories) - normParam;
                preferenceModel(notRatedCategories) = noRatredProb; % replace with a small probability
            end
            likelyhood(r,:) = likelyhood(r,:) .* preferenceModel; 
        end
    end
end