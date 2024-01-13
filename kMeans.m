%% B�LG�LER
% 20010011011
% Harun Veli Tosun

%% K�meleme i�lemi ba�lat�l�r ve �izimi ger�ekle�tirilir
function [idx, centroids] = kMeans(data, k)
    % Veriyi k k�mesine ay�r
    [idx, centroids] = kMeansClustering(data, k);

    % Sonu�lar� �iz
    % ilk 2 boyut referans al�narak �izildi. Tam do�ru sonucu
    % belirtmemektedir. Sadece g�rsel olarak anla��labilmesi i�in
    % eklenmi�tir. (Kodun h�zl� �al��mas� i�in kapat�labilir)
    figure;
    gscatter(data(:, 1), data(:, 2), idx, 'rgbmcyk', 'o');
    hold on;
    plot(centroids(:, 1), centroids(:, 2), 'kx', 'MarkerSize', 15, 'LineWidth', 3);
    hold off;
    
end

%% K�meleme i�lemi yap�l�r
function [idx, centroids] = kMeansClustering(data, k)
    [n, m] = size(data);

    % Rastgele ba�lang�� merkezleri se� 
    randIndices = generateRandomIndices(n, k);% Haz�r Fonk -> randperm(n, k);
    centroids = data(randIndices, :);

    while true
        % Her �rne�i en yak�n merkeze atama
%         distances = pdist2(data, centroids); (Haz�r Fonksiyon kald�r�ld�)
        distances = calculateDistances(data, centroids);
        [~, idx] = min(distances, [], 2);% 2 -> s�tunlar aras�ndaki min bulmas� i�in

        % Yeni merkezleri hesapla
        newCentroids = zeros(k, m);
        for i = 1:k
            clusterPoints = data(idx == i, :);
            if ~isempty(clusterPoints)
                newCentroids(i, :) = mean(clusterPoints);
            else
                newCentroids(i, :) = centroids(i, :);
            end
        end

        % Merkezlerde bir de�i�iklik olup olmad���n� kontrol et
        if isequal(newCentroids, centroids)
            break;
        end

        centroids = newCentroids;
    end
end

%% K�me say�s� kadar rastgele k�me merkezi belirler
function randIndices = generateRandomIndices(n, k)
    randIndices = zeros(1, k);
    availableIndices = 1:n;

    for i = 1:k
        % Rastgele bir indis se�
        randomIndex = randi(length(availableIndices));

        % Se�ilen indisleri kaydet
        randIndices(i) = availableIndices(randomIndex);

        % Se�ilen indisleri listeden kald�r
        availableIndices(randomIndex) = [];
    end
end

%% Uzakl�k �l��mleri yap�l�r
function distances = calculateDistances(data, centroids)
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
end
