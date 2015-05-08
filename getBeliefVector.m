function [vector, number] = getBeliefVector(filename, nAction, nState)

number = ones(nAction, 1);
vector = zeros(nAction, nState, 10000);

fid = fopen(filename);

tline = fgets(fid);

count = 0;

while ischar(tline)
    % fprintf('line number %d:, %s ',x, tline)
    if count == 0
        action = textscan( tline, '%d', 'delimiter', ' ' );
        action = action{1,1} + 1;
    else
        if count == 1
            tempVector = textscan( tline, '%f', 'delimiter', ' ' );
            vector(action, :, number(action)) = tempVector{1, 1}(:);
            number(action)= number(action) + 1;
        end
    end
    count = mod((count + 1), 3);
        
    tline = fgets(fid);
end

fclose(fid);
