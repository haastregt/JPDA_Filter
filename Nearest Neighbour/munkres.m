function [ opt_ass ] = munkres(L)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % IGNORE THIS FILE FOR NOW, IT IS NOT FINISHED, IT MIGHT BE USEFUL IN THE FUTURE IF WE WANT TO TO MORE COMPLICATED THINGS WITH THE GNN FILTER %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % This function performs performs the hungarian algorithm given the cost matrix for target-measurement pairs from the GNN
    % Inputs:
    %   cost_matrix: the cost matrix computed from the GNN
    % Outputs:
    %   Best assignment of targets to measurements

    %% Global variables
    global num_targets;
    global num_measurements;
    
    %% Step 0: If num_targets*num_measurements is too big use the munkres algorithm otherwise do exhaustive search

    cost_matrix = L;    % Create a copy of the cost matrix

    if num_targets*num_measurements > 1 % Exhaustive search % todo: change this to a better value cause now we are only using the Munkres algorithm with this value
        total_cost = zeros(1,nchoosek(num_measurements,num_targets));

        % Find all possible combinations without repetitions of measurements
        combinations = nchoosek(1:num_measurements,num_targets);

        % Find the total cost for each combination
        for i = 1:size(combinations,1)
            for j = 1:size(combinations,2)
                total_cost(i) = total_cost(i) + cost_matrix(j,combinations(i,j));
            end
        end

        % Find the minimum cost
        [~,min_cost] = min(total_cost);

        % Find the optimal assignment
        opt_ass = combinations(min_cost,:);


    else % Munkres algorithm
        %% Step 1: Row reduction

        % Subtract the minimum value from each row (Now each row contains at least one zero element)
        for i = 1:size(cost_matrix,1)
            cost_matrix(i,:) = cost_matrix(i,:) - min(cost_matrix(i,:));
        end

        %% Step 2: Column reduction

        % Subtract the minimum value from each column (Now each column contains at least one zero element)
        for i = 1:size(cost_matrix,2)
            cost_matrix(:,i) = cost_matrix(:,i) - min(cost_matrix(:,i));
        end

        %% Step 3: Check if an optimal assignment is possible: Check if the number of lines with zeros is equal to the number of columns

        % Find the number of lines with zeros
        num_lines = 0;
        for i = 1:size(cost_matrix,1)
            if sum(cost_matrix(i,:)==0) > 0
                num_lines = num_lines + 1;
            end
        end

        % Find the number of columns with zeros
        num_columns = 0;
        for i = 1:size(cost_matrix,2)
            if sum(cost_matrix(:,i)==0) > 0
                num_columns = num_columns + 1;
            end
        end    
        
        % If not, do step 4 otherwise go to step 5
        
        %% Step 4: shift zeros to the right until it is

        % If the number of lines is not equal to the number of columns, shift zeros to the right
        if num_lines ~= num_columns
            % Find the number of zeros in each column
            num_zeros = zeros(1,size(cost_matrix,2));
            for i = 1:size(cost_matrix,2)
                num_zeros(i) = sum(cost_matrix(:,i)==0);
            end

            % Find the column with the most zeros
            [~,max_zeros] = max(num_zeros);

            % Shift zeros to the right
            for i = 1:size(cost_matrix,1)
                if cost_matrix(i,max_zeros) == 0
                    cost_matrix(i,max_zeros) = 1;
                end
            end
        end

        %% Step 5: Find the optimal assignment
        
        % Choose the first zero element from each row of the cost_matrix and assign it to the corresponding target
        
        % Find the first zero element from each row
        first_zero = zeros(1,size(cost_matrix,1));
        for i = 1:size(cost_matrix,1)
            first_zero(i) = find(cost_matrix(i,:)==0,1);
        end

        % Assign the value from the original cost matrix L to the optimal assignment for each target based on the first zero assigned to it
        opt_ass = zeros(1,num_targets);
        
        for i = 1:num_targets
            


        

    end

end



