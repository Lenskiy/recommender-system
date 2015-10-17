load('R_G.mat');

[Pr_ItemInCategory Pr_Item Pr_Category] = buildBernoulliModel(R, G);

Pr_CategoryGivenI = estimatePosteriorProbability(Pr_ItemInCategory, Pr_Item, Pr_Category);





