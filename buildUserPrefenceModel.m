function [Pr_Category, Pr_UratedC] = buildUserPrefenceModel(R, G)
    Nusers = size(R,1);     %number of users
    Nitems = size(R,2);     %number of items
    Ncategories = size(G,2);    %number of genres
    Nrates = max(max(R));   %number of rates
    %G = logical(G);
    %Estimate prior probabilities 
    total_ratings = zeros(Nrates, Ncategories);
    Pr_UratedC = zeros(Nusers, Ncategories, Nrates); % allocate memory
    Pr_UratedC_temp = zeros(1, Nusers);    

    for r = 1:Nrates 
        R_temp = logical(zeros(Nusers, Nitems, 'uint8'));
        R_temp = (R == r);
        %R_temp(R == r) = true; % indicates whether user_t rated item_i as n
        R_temp = R_temp';
        for c = 1:Ncategories
%            itemsGeners = G(:,c);
%             for u = 1:Nusers
%                 %tr = tr + sum(R_temp(:,u) & itemsGeners); %1031 %638 
%                 Pr_UratedC_temp(u) = nnz(R_temp(:,u) & itemsGeners); %The number of users rated movies of category c
%                  \
%                 %tr = tr + numUserRatedC;
%             end
            Pr_UratedC_temp = sum(bsxfun(@times, R_temp, G(:,c)), 1);
            total_ratings(r,c) = sum(Pr_UratedC_temp);
            Pr_UratedC(:,c,r) = (Pr_UratedC_temp + 1) / (total_ratings(r,c) + Nusers);
        end
    end
    %Pr_Category = (total_ratings + 1)  ./ ((sum(total_ratings')' + Ncategories) * ones(1, Ncategories)); %Add Lapalcian smoothing
    Pr_Category = (((sum(G) + 1)/( sum(sum(G)) + size(G,2)))' * ones(1, length(unique(R)) - 1))';
    
%     %Estimate probability user_i rates categoy_j as r
%     Pr_UratedC = zeros(Nusers, Ncategories, Nrates); % allocate memory
%     Pr_UratedC_temp = zeros(1, Nusers);
%     %Pr_UinC_temp = 
%     for r = 1:Nrates
%         R_temp = false; % indicates whether user_t rated item_i as n
%         R_temp(R == r) = true;
%         R_temp = R_temp';
%         %R_temp = Rn(:,:,r)';
%         for c = 1:Ncategories
%             itemsGeners = (G(:,c))'; %sign(G(:,c))'
%             denom = 0;
%             %denom = sum(itemsGeners); % make it dependent on r
%             for u = 1:Nusers
%                % Pr_UratedC_temp(u) = itemsGeners * R_temp(:,u); % The number of users rated movies of category c
%                Pr_UratedC_temp(u) = nnz(R_temp(u,:) & itemsGeners);
%                denom = denom + Pr_UratedC_temp(u);
%                 %Pr_UinC(u,c,r) = (1 + sum(Rn(u,:,r) .* G(:,c)')) / (2 + sum(Rn(u,:,r))); % replaced G(:,c)' by  Rn(u,:,r)
%             end
%             Pr_UratedC(:,c,r) = (Pr_UratedC_temp + 1) / (denom + Nusers); %  should sum to 1
%         end
%     end
end