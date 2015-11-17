function Pr_CategoryGivenI = estimatePosteriorProbability(Pr_ItemInCategory, Pr_Category)
    Nitems = size(Pr_ItemInCategory,1);
    Ncategories = size(Pr_ItemInCategory,2);
    Nrates = size(Pr_ItemInCategory,3);
    
    %Prior probability of an item
    Pr_Item = zeros(Nitems, Nrates);
    for r = 1:Nrates
        for i = 1:Nitems
            Pr_Item(i,r) = sum(Pr_Category(r, :) .* Pr_ItemInCategory(i, :, r));
        end
    end
    
        
    %Posterior probability of the class
    Pr_CategoryGivenI = zeros(Ncategories, Nitems, Nrates);
    
    for r = 1:Nrates
        logPr_Category(r, :) = log(Pr_Category(r,:));
        for i = 1:Nitems
            %Pr_CategoryGivenI(:, i, r) =  Pr_Category .* Pr_ItemInCategory(:, i, r) ./ Pr_Item(i,r);
            Pr_CategoryGivenI(:, i, r) =  logPr_Category(r,:) + log(Pr_ItemInCategory(i, :, r)) - log(Pr_Item(i,r));
        end
        %Pr_CategoryGivenI(i,isnan(Pr_CategoryGivenI(i,:,r)), r) = 0;
    end
end