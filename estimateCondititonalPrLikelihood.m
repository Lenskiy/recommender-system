function logPr_ItemInCategory = estimateCondititonalPrLikelihood(Pr_UratedC, R)
    Nitems = size(R,2);                 %number of items
    
    Nusers = size(Pr_UratedC, 1);       %number of users
    Ncategories = size(Pr_UratedC, 2);  %number of genres
    Nrates = size(Pr_UratedC, 3);       %number of rates

    available_memory = 2^20; %30
    
    div_coef = ceil(size(R,1) * size(R,2) * 8  / available_memory);
    Nusers_part = floor(Nusers/div_coef);
    
    % Estimate conditional probability of Item i given Class c
    logPr_ItemInCategory = zeros(Nitems, Ncategories, Nrates); % allocate memory
    for r = 1:Nrates
        R_temp = full(R == r);
        Pr_UratedC_temp = log(Pr_UratedC(:,:,r));
        for c = 1:Ncategories
            [r, c]
            logPr_ItemInCategory_part = 0;
            for j = 1:div_coef - 1
                %Rt = full(R_temp(((j - 1) * Nusers_part + 1):(j * Nusers_part), :)); % in case then data is too large 
                Rt = R_temp(((j - 1) * Nusers_part + 1):(j * Nusers_part), :);
                Pr_UratedC_temp_vec = Pr_UratedC_temp(((j - 1) * Nusers_part + 1):(j * Nusers_part), c);
                logPr_ItemInCategory_part = logPr_ItemInCategory_part + sum(bsxfun(@times, Rt, Pr_UratedC_temp_vec));
            end
            Rt = R_temp(((div_coef - 1) * Nusers_part + 1):Nusers, :);
            Pr_UratedC_temp_vec = Pr_UratedC_temp(((div_coef - 1) * Nusers_part + 1):Nusers, c);
            logPr_ItemInCategory(:, c, r) = logPr_ItemInCategory_part + sum(bsxfun(@times, Rt, Pr_UratedC_temp_vec));
        end
    end

end
