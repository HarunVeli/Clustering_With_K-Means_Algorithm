%% B�LG�LER
% 20010011011
% Harun Veli Tosun

%% Uzakl�k �l��mleri yap�l�r
function [distances, idx] = kMeansTest(data, centroids)
    % Veri matrisinin boyutlar� n-> veri say�s�, k-> k�me say�s�
    [n, ~] = size(data);
    [k, ~] = size(centroids);

    % Uzakl�k matrisini ba�lat
    distances = zeros(n, k);

    % Uzakl�klar� hesapla
    for i = 1:k
        for j = 1:n
            % �klid uzakl��� hesapla
            distances(j, i) = sqrt(sum((data(j, :) - centroids(i, :)).^2));
        end
    end
    
    % En yak�na g�re k�me belirlenir
    [~, idx] = min(distances, [], 2);
end

