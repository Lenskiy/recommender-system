function logPr_ItemInCategory = estimateCondititonalPrBernoulli(Pr_UratedC, R)
    Nitems = size(R,2);                 %number of items
    
    Nusers = size(Pr_UratedC, 1);       %number of users
    Ncategories = size(Pr_UratedC, 2);  %number of genres
    Nrates = size(Pr_UratedC, 3);       %number of rates
    Nusers_quarter = ceil(Nusers/4);

    available_memory = 2^20; %30
    
    div_coef = ceil(size(R,1) * size(R,2) * 8  / available_memory);
    Nusers_part = floor(Nusers/div_coef);
    
    % Estimate conditional probability of Item i given Class c
    logPr_ItemInCategory = zeros(Nitems, Ncategories, Nrates); % allocate memory
    %logPr_ItemInCategory_temp = zeros(Nitems, 1);
    for r = 1:Nrates
        R_temp = (R == r);
        %R_temp_neg = ~R_temp;
        Pr_UratedC_temp = Pr_UratedC(:,:,r);
        for c = 1:Ncategories
            %[r, c]
            %ind = find(G(:,c) ~= 0);
            %ind = 1:Nitems;
%             for i = 1:Nitems
%                 %Pr_ItemInCategory_temp((i)) =  prod(R_temp(:,(i)) .* Pr_UratedC_temp(:,c) + (1 - R_temp(:,(i))) .* (1 - Pr_UratedC_temp(:,c)));
%                 logPr_ItemInCategory_temp(i) =  sum(log(R_temp(:,i) .* Pr_UratedC_temp(:,c) + (1 - R_temp(:,i)) .* (1 - Pr_UratedC_temp(:,c))));
%             end

            logPr_ItemInCategory_part = 0;
            t = 1;
            for j = 1:div_coef - 1
                %j/div_coef
                %Rt = full(R_temp(((j - 1) * Nusers_part + 1):(j * Nusers_part), :)); % in case then data is too large 
                Rt = R_temp(((j - 1) * Nusers_part + 1):(j * Nusers_part), :);
                Rt_neg = ~Rt;
                Pr_UratedC_temp_vec = Pr_UratedC_temp(((j - 1) * Nusers_part + 1):(j * Nusers_part), c);
                t = t .* (bsxfun(@times, Rt, Pr_UratedC_temp_vec) + bsxfun(@times, Rt_neg, 1 - Pr_UratedC_temp_vec));

%                         t =  bsxfun(@times, R_temp((j * Nusers_part + 1):((j + 1) * Nusers_part), :), Pr_UratedC_temp((j * Nusers_part + 1):((j + 1) * Nusers_part), c));
%                         tn = bsxfun(@times, R_temp_neg((j * Nusers_part + 1):((j + 1) * Nusers_part), :), (1 - Pr_UratedC_temp((j * Nusers_part + 1):((j + 1) * Nusers_part), c)));
%                         logPr_ItemInCategory_part = logPr_ItemInCategory_part + sum(log(t + tn), 1);     
            end
            logPr_ItemInCategory_part = logPr_ItemInCategory_part +  sum(log(t));
                
            Rt = R_temp(((div_coef - 1) * Nusers_part + 1):Nusers, :);
            Rt_neg = ~Rt;
            Pr_UratedC_temp_vec = Pr_UratedC_temp(((div_coef - 1) * Nusers_part + 1):Nusers, c);
            logPr_ItemInCategory(:, c, r) = logPr_ItemInCategory_part + sum(log(bsxfun(@times, Rt, Pr_UratedC_temp_vec) + bsxfun(@times, Rt_neg, (1 - Pr_UratedC_temp_vec))));
            
            %logPr_ItemInCategory(:, c, r) = logPr_ItemInCategory_part +  sum(log(bsxfun(@times, Rt, Pr_UratedC_temp(((div_coef - 1) * Nusers_part + 1):Nusers, c)) +...
            %      bsxfun(@times, Rt_neg, (1 - Pr_UratedC_temp(((div_coef - 1) * Nusers_part + 1):Nusers, c)))), 1);            
%              t =  bsxfun(@times, R_temp((div_coef * Nusers_part + 1):end, :), Pr_UratedC_temp((div_coef * Nusers_part + 1):end, c));
%              tn = bsxfun(@times, R_temp_neg((div_coef * Nusers_part + 1):end, :), (1 - Pr_UratedC_temp((div_coef * Nusers_part + 1):end, c)));
%              logPr_ItemInCategory(:, c, r) = logPr_ItemInCategory_part + sum(log(t + tn),1);
            
            %logPr_ItemInCategory(:, c, r) = sum(bsxfun(@times, R_temp, logPr_UratedC_temp(c,:)), 2);
            %logPr_ItemInCategory(:, c, r) = logPr_ItemInCategory_temp;
        end
    end

end