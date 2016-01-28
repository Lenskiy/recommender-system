function [Pr_Category Pr_UratedC] = buildUserPrefenceModel(R, G)
    Nusers = size(R,1);     %number of users
    Nitems = size(R,2);     %number of items
    Ncategories = size(G,2);    %number of genres
    Nrates = max(max(R));   %number of rates

    %Estimate prior probabilities
    total_ratings = zeros(Nrates, Ncategories);

    for r = 1:Nrates 
        R_temp = zeros(Nusers, Nitems); % indicates whether user_t rated item_i as n
        R_temp(find(R == r)) = 1;
        Rn(:,:,r) = R_temp;
        for c = 1:Ncategories
            itemsGeners = (G(:,c));
            tr = 0;
            for u = 1:size(R,1)
                tr = tr + R_temp(u,:) * itemsGeners;
            end
            total_ratings(r,c) = tr;
        end
    end
    Pr_Category = ((total_ratings + 1)  ./ ((sum(total_ratings')' + Ncategories)...
        * ones(1, Ncategories))); %Add Lapalcian smoothing
    
    
    %Estimate probability user_i rates categoy_j as r
    Pr_UratedC = zeros(Nusers, Ncategories, Nrates); % allocate memory
    Pr_UratedC_temp = zeros(1, Nusers);
    %Pr_UinC_temp = 
    for r = 1:Nrates
        R_temp = Rn(:,:,r)';
        for c = 1:Ncategories
            itemsGeners = (G(:,c))'; %sign(G(:,c))'
            denom = 0;
            %denom = sum(itemsGeners); % make it dependent on r
            for u = 1:Nusers
                Pr_UratedC_temp(u) = itemsGeners * R_temp(:,u); % The number of users rated movies of category c
                denom = denom + Pr_UratedC_temp(u);
                %Pr_UinC(u,c,r) = (1 + sum(Rn(u,:,r) .* G(:,c)')) / (2 + sum(Rn(u,:,r))); % replaced G(:,c)' by  Rn(u,:,r)
            end
            Pr_UratedC(:,c,r) = (Pr_UratedC_temp + 1) / (denom + Nusers); %  should sum to 1
        end
    end
end