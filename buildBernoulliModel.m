function [Pr_ItemInCategory Pr_Item Pr_Category] = buildBernoulliModel(R, G)

    Nusers = size(R,1);     %number of users
    Nitems = size(R,2);     %number of items
    Ncategories = size(G,2);    %number of genres
    Nrates = max(max(R));   %number of rates

    %Prior probability of a category
    Pr_Category =  sum(G) / Nitems; %sum(sum(G)); % should be devided by Nitems, but item can belong to more than one categories
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
    Pr_UinC = zeros(Nusers, Ncategories, Nrates); % allocate memory
    for r = 1:Nrates
        for c = 1:Ncategories
            for u = 1:Nusers
                Pr_UinC(u,c,r) = sum(Rn(u,:,r) .* G(:,c)') / (2 + sum(G(:,c)'));
            end
        end
    end

    % for r = 1 : Nrates
    %     figure, surf(Pr_UinC(:, :, r)); ylabel('users'); xlabel('category');
    % end
    
    % Estimate conditional probability of Item i given Class c
    Pr_ItemInCategory = zeros(Nitems, Ncategories, Nrates); % allocate memory
    for r = 1:Nrates
        for c = 1:Ncategories
            for i = 1:Nitems
                Pr_ItemInCategory(i, c, r) =  prod(Rn(:,i,r) .* Pr_UinC(:,c,r) +...
                                           + (1 - Rn(:,i,r)) .* (1 - Pr_UinC(:,c,r)));
            end
        end
    end

    %Prior probability of an item
    Pr_Item = zeros(Nitems, Nrates);
    for r = 1:Nrates
        for i = 1:Nitems
            Pr_Item(i,r) = sum(Pr_Category .* Pr_ItemInCategory(i, :, r));
        end
    end
end