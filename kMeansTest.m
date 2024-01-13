%% BÝLGÝLER
% 20010011011
% Harun Veli Tosun

%% Uzaklýk ölçümleri yapýlýr
function [distances, idx] = kMeansTest(data, centroids)
    % Veri matrisinin boyutlarý n-> veri sayýsý, k-> küme sayýsý
    [n, ~] = size(data);
    [k, ~] = size(centroids);

    % Uzaklýk matrisini baþlat
    distances = zeros(n, k);

    % Uzaklýklarý hesapla
    for i = 1:k
        for j = 1:n
            % Öklid uzaklýðý hesapla
            distances(j, i) = sqrt(sum((data(j, :) - centroids(i, :)).^2));
        end
    end
    
    % En yakýna göre küme belirlenir
    [~, idx] = min(distances, [], 2);
end

