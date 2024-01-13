%% BÝLGÝLER
% 20010011011
% Harun Veli Tosun

%% Kümeleme iþlemi baþlatýlýr ve çizimi gerçekleþtirilir
function [idx, centroids] = kMeans(data, k)
    % Veriyi k kümesine ayýr
    [idx, centroids] = kMeansClustering(data, k);

    % Sonuçlarý çiz
    % ilk 2 boyut referans alýnarak çizildi. Tam doðru sonucu
    % belirtmemektedir. Sadece görsel olarak anlaþýlabilmesi için
    % eklenmiþtir. (Kodun hýzlý çalýþmasý için kapatýlabilir)
    figure;
    gscatter(data(:, 1), data(:, 2), idx, 'rgbmcyk', 'o');
    hold on;
    plot(centroids(:, 1), centroids(:, 2), 'kx', 'MarkerSize', 15, 'LineWidth', 3);
    hold off;
    
end

%% Kümeleme iþlemi yapýlýr
function [idx, centroids] = kMeansClustering(data, k)
    [n, m] = size(data);

    % Rastgele baþlangýç merkezleri seç 
    randIndices = generateRandomIndices(n, k);% Hazýr Fonk -> randperm(n, k);
    centroids = data(randIndices, :);

    while true
        % Her örneði en yakýn merkeze atama
%         distances = pdist2(data, centroids); (Hazýr Fonksiyon kaldýrýldý)
        distances = calculateDistances(data, centroids);
        [~, idx] = min(distances, [], 2);% 2 -> sütunlar arasýndaki min bulmasý için

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

        % Merkezlerde bir deðiþiklik olup olmadýðýný kontrol et
        if isequal(newCentroids, centroids)
            break;
        end

        centroids = newCentroids;
    end
end

%% Küme sayýsý kadar rastgele küme merkezi belirler
function randIndices = generateRandomIndices(n, k)
    randIndices = zeros(1, k);
    availableIndices = 1:n;

    for i = 1:k
        % Rastgele bir indis seç
        randomIndex = randi(length(availableIndices));

        % Seçilen indisleri kaydet
        randIndices(i) = availableIndices(randomIndex);

        % Seçilen indisleri listeden kaldýr
        availableIndices(randomIndex) = [];
    end
end

%% Uzaklýk ölçümleri yapýlýr
function distances = calculateDistances(data, centroids)
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
end
