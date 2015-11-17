function [Pr_ItemInCategory Pr_Item Pr_Category] = buildBernoulliModel(R, G)

    Nusers = size(R,1);     %number of users
    Nitems = size(R,2);     %number of items
    Ncategories = size(G,2);    %number of genres
    Nrates = max(max(R));   %number of rates

    %Prior probability of a category
%     for r = 1:Nrates
%         Pr_Category(r, :) =  sum(G(find(sum(R == r) > 0),:)) ./ length(find(sum(R == r) > 0));
%         %Pr_Category(r, :) =  (sum(G(find(sum(R == r) > 0),:)) + ones(1, size(G,2))) / (Nitems + Ncategories);
%         %(sum(G) + ones(1, size(G,2))) / (Nitems + Ncategories) %sum(sum(G)); % should be devided by Nitems, but item can belong to more than one categories
%     end
    total_ratings = zeros(Nrates, Ncategories);
    for r = 1:Nrates
        Rt = (R == r);
        for c = 1:Ncategories
            for u = 1:size(R,1)
                total_ratings(r,c) = total_ratings(r,c) + Rt(u,:) * sign(G(:,c));
            end
        end
    end
    Pr_Category = (total_ratings  ./ (sum(total_ratings')' * ones(1, Ncategories)));
    %Pr_Category = (1 / Ncategories) * ones(1, Ncategories);
    %figure, plot(Pr_Category); xlabel('Category C_j');  ylabel('P(C_j)');
    
    
    %Rn indicates wether user_t rated item_i as n
    Rn = zeros(Nusers, Nitems, Nrates); % allocate memory
    for r = 1:Nrates
        R_temp = zeros(Nusers, Nitems);
        R_temp(find(R == r)) = 1;
        Rn(:,:,r) = R_temp;
    end

    %Estimate probability user_i rates categoy_j as r
    Pr_UratedC = zeros(Nusers, Ncategories, Nrates); % allocate memory
    Pr_UratedC_temp = zeros(1, Nusers);
    %Pr_UinC_temp = 
    for r = 1:Nrates
        R_temp = Rn(:,:,r)';
        for c = 1:Ncategories
            itemsGeners = sign(G(:,c));
            denom = 2 + sum(itemsGeners); % make it dependent on r
            for u = 1:Nusers
                 Pr_UratedC_temp(u) = R_temp(:,u)' * itemsGeners;
                %Pr_UinC(u,c,r) = (1 + sum(Rn(u,:,r) .* G(:,c)')) / (2 + sum(Rn(u,:,r))); % replaced G(:,c)' by  Rn(u,:,r)
            end
            Pr_UratedC(:,c,r) = (Pr_UratedC_temp + 1) / denom;
        end
    end
    % user = 4; rate = 5;
    % figure, plot(Pr_UinC(4,:,5))
    % for r = 1 : Nrates
    %     figure, surf(Pr_UinC(:, :, r)); ylabel('users'); xlabel('category');
    % end
    
    % Estimate conditional probability of Item i given Class c
    Pr_ItemInCategory = zeros(Nitems, Ncategories, Nrates); % allocate memory
    Pr_ItemInCategory_temp = zeros(Nitems, 1);
    for r = 1:Nrates
        R_temp = Rn(:,:,r);
        for c = 1:Ncategories
            Pr_UratedC_temp = Pr_UratedC(:,:,r);
            ind = find(G(:,c) ~= 0);
            for i = 1:length(ind)%Nitems
            %R_temp = sign(Rn(:,i,1) + Rn(:,i,2) + Rn(:,i,3)  + Rn(:,i,4)  + Rn(:,i,5));
%                   Pr_ItemInCategory(i, c, 1) =  prod(R_temp .* Pr_UinC(:,c,1) +  (1 - R_temp) .* (1 - Pr_UinC(:,c,1)));
%                   Pr_ItemInCategory(i, c, 2) =  prod(R_temp .* Pr_UinC(:,c,2) +  (1 - R_temp) .* (1 - Pr_UinC(:,c,2)));
%                   Pr_ItemInCategory(i, c, 3) =  prod(R_temp .* Pr_UinC(:,c,3) +  (1 - R_temp) .* (1 - Pr_UinC(:,c,3)));
%                   Pr_ItemInCategory(i, c, 4) =  prod(R_temp .* Pr_UinC(:,c,4) +  (1 - R_temp) .* (1 - Pr_UinC(:,c,4)));
%                   Pr_ItemInCategory(i, c, 5) =  prod(R_temp .* Pr_UinC(:,c,5) +  (1 - R_temp) .* (1 - Pr_UinC(:,c,5)));
                Pr_ItemInCategory_temp(ind(i)) =  prod(R_temp(:,ind(i)) .* Pr_UratedC_temp(:,c) + (1 - R_temp(:,ind(i))) .* (1 - Pr_UratedC_temp(:,c)));
                %Pr_ItemInCategory(i, c, r) =  sum(log(Rn(:,i,r).*Pr_UinC(:,c,r) + (1 - Rn(:,i,r)).*(1 - Pr_UinC(:,c,r))));
            end
            Pr_ItemInCategory(:, c, r) = Pr_ItemInCategory_temp;
        end   
    end

    %Prior probability of an item
    Pr_Item = zeros(Nitems, Nrates);
    for r = 1:Nrates
        for i = 1:Nitems
            Pr_Item(i,r) = sum(Pr_Category(r, :) .* Pr_ItemInCategory(i, :, r));
        end
    end
end