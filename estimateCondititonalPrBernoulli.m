function logPr_ItemInCategory = estimateCondititonalPrBernoulli(Pr_UratedC, R)
    Nitems = size(R,2);                 %number of items
    
    Nusers = size(Pr_UratedC, 1);       %number of users
    Ncategories = size(Pr_UratedC, 2);  %number of genres
    Nrates = size(Pr_UratedC, 3);       %number of rates
    Nusers_half = ceil(Nusers/2);
    
    % Estimate conditional probability of Item i given Class c
    logPr_ItemInCategory = zeros(Nitems, Ncategories, Nrates, 'single'); % allocate memory
    %logPr_ItemInCategory_temp = zeros(Nitems, 1);
    for r = 1:Nrates
        R_temp = (R == r);
        R_temp_neg = ~R_temp; 
        for c = 1:Ncategories
            Pr_UratedC_temp = single(Pr_UratedC(:,:,r));
            %ind = find(G(:,c) ~= 0);
            %ind = 1:Nitems;
%             for i = 1:Nitems
%                 %Pr_ItemInCategory_temp((i)) =  prod(R_temp(:,(i)) .* Pr_UratedC_temp(:,c) + (1 - R_temp(:,(i))) .* (1 - Pr_UratedC_temp(:,c)));
%                 logPr_ItemInCategory_temp(i) =  sum(log(R_temp(:,i) .* Pr_UratedC_temp(:,c) + (1 - R_temp(:,i)) .* (1 - Pr_UratedC_temp(:,c))));
%             end
            TempU =  bsxfun(@times, R_temp(1:Nusers_half, :), Pr_UratedC_temp(1:Nusers_half, c));
            TempUn = bsxfun(@times, R_temp_neg(1:Nusers_half, :), single(1 - Pr_UratedC_temp(1:Nusers_half, c)));
            logPr_ItemInCategory(:, c, r) = sum(log(TempU + TempUn));
            TempU =  bsxfun(@times, R_temp(Nusers_half + 1:end, :), Pr_UratedC_temp(Nusers_half + 1:end, c));
            TempUn = bsxfun(@times, R_temp_neg(Nusers_half + 1:end, :), single(1 - Pr_UratedC_temp(Nusers_half + 1:end, c)));
            logPr_ItemInCategory(:, c, r) = logPr_ItemInCategory(:, c, r) + sum(log(TempU + TempUn))';            
            %logPr_ItemInCategory(:, c, r) =   sum(bsxfun(@times, R_temp, logPr_UratedC_temp(c,:)), 2);
            %logPr_ItemInCategory(:, c, r) = logPr_ItemInCategory_temp;
        end   
    end

end