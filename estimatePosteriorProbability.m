function Pr_CategoryGivenI = estimatePosteriorProbability(Pr_ItemInCategory, Pr_Item, Pr_Category)
    Nitems = size(Pr_ItemInCategory,1);
    Ncategories = size(Pr_ItemInCategory,2);
    Nrates = size(Pr_ItemInCategory,3);
    %Posterior probability
    Pr_CategoryGivenI = zeros(Nitems, Ncategories, Nrates);
    for r = 1:Nrates
        for i = 1:Nitems
            Pr_CategoryGivenI(i, :, r) =  Pr_Category .* Pr_ItemInCategory(i, :, r) ./ Pr_Item(i,r);
        end
        Pr_CategoryGivenI(i,isnan(Pr_CategoryGivenI(i,:,r)), r) = 0;
    end
end