function likelyhood = predictGenresBasedOnPrefModels(preferenceModels, item, userRatings, priorProb)
    noRatredProb = 0.01;
    Ngenres = size(preferenceModels,2);    %number of genres
    Nrates = size(preferenceModels,3);   %number of rates

    %P_UinC = sum(G) / sum(sum(G)); %Nusers;   %prior probabilities
	%likelyhood =  ones(5, Ngenres) / Ngenres;
    %likelyhood = [P_UinC; P_UinC; P_UinC; P_UinC; P_UinC];
    likelyhood = priorProb;
     
    for r = 1:Nrates
        %figure(r), hold on; title(['A rating model for the raiting ' num2str(r) ' estiamted based on the item ' num2str(item)]);
        usersRated = find(userRatings(2,:) == r);
        %color_delta(r,:) = [1 1 1] / length(usersRated);
        %figure, hold on; title(['Users that rated this movie as ' num2str(r)]);
        for u = 1:length(usersRated) %plot dynamicaly how likelyhood changes
            preferenceModel = preferenceModels(usersRated(u), :, r);
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
%             if(numberOfNotRatedCategories > 0) 
%                 ratedCategories = find(preferenceModel ~= 0);
%                 normParam =  noRatredProb * numberOfNotRatedCategories / (Ngenres - numberOfNotRatedCategories);
%                 preferenceModel(notRatedCategories) = noRatredProb; % replace with a small probability
%                 preferenceModel = preferenceModel / sum(preferenceModel);
%                 
%             end
            likelyhood(r,:) = likelyhood(r,:) .* preferenceModel;
            %figure(r),plot(likelyhood(r,:)/sum(likelyhood(r,:)), 'color', 1 - u * color_delta(r,:));
        end
    end
end