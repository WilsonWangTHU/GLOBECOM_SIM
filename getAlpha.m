function [vector, number] = getAlpha(filename)

vector = zeros(2000, 1);

fid = fopen(filename);
iVector = 1;
tline = fgets(fid);

% Epoch: 1...1 vectors in 0.00 secs. (0.00 total) (err=1.00e+00)
while ischar(tline)
    
    % fprintf('line number %d:, %s ',x, tline)
    textscan( tline, '%f', 'delimiter', ' ' );
    tempIndex = find(tline - 'e' == 0)
    x = tline(tempIndex(end) -4 : tempIndex(end) + 3);
    
    vector(iVector) = str2num(x);
    iVector = iVector + 1;
    
    tline = fgets(fid);
end
number = iVector - 1;

vector = vector(1: number);
fclose(fid);
