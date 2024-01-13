%% B�LG�LER
% 20010011011
% Harun Veli Tosun

%%
clc;
clear;

%% Veri Okuma, Eksik Veri Tamamlama ve Normalize ��lemi
% NOT -> Verilerin son s�tunu k�me de�erleri olarak s�tun ba�l�klar� ise 
% yok olarak kabul edildi ve okuma
% i�lemi ona g�re yap�ld�
data = xlsread('IrisLastVersion.xlsx','Cluster');
% FARKLI VER� SET� (Dinamik kontrol� sa�lamak i�in)
% data = xlsread('DiabetesDataSet.xlsx','Sheet4');
clusterData = data(:, size(data, 2));
data(:, size(data, 2)) = [];
completedData = fillMissingValues(data);
normalizedData = minMaxNormalization(completedData, 0, 1);

%% Tan�mlamalar
defaultRandIndex = 0;
normRandIndex = 0;
kFoldCount = 5; 
clusterSize = -1;

%% MENU
while true
    
    fprintf('--------------------------------------\n');
    fprintf('1. K-means Uygula\n');
    fprintf('2. Normalize Verilere K-means Uygula\n');
    fprintf('3. Verileri Normalize Et\n');
    fprintf('4. RandIndex Kar��la�t�r\n');
    fprintf('5. ��k��\n');
    
    choice = input('L�tfen bir se�enek girin (1-5): ');
    
    switch choice
        case 1 %K-Means
            while true
                fprintf('--------------------------------------\n');
                clusterSize = input('L�tfen bir k�me say�s� girin (1-10): ');
                if clusterSize < 1 || clusterSize > 10
                    fprintf('L�tfen ge�erli bir de�er giriniz\n');
                else
%                     fprintf('K-means uygulama i�lemi yap�l�yor...\n');
%                     [idx, centroids] = kMeans(completedData, clusterSize);
                    while true
                        fprintf('--------------------------------------\n');
                        kFoldCount = input('K-Fold i�in de�er giriniz (�nerilen: 5): ');
                        if kFoldCount < 1
                            fprintf('L�tfen ge�erli bir de�er giriniz\n');
                        else
                            fprintf('K-means uygulama i�lemi yap�l�yor...\n');
                            defaultRandIndex = kFoldCrossValidation(size(completedData, 1), kFoldCount, completedData, clusterSize, clusterData);
                            break;
                        end
                    end
                break;
                end
            end
        case 2 %Normalize K-Means
            while true
                fprintf('--------------------------------------\n');
                clusterSize = input('L�tfen bir k�me say�s� girin (1-10): ');
                if clusterSize < 1 || clusterSize > 10
                    fprintf('L�tfen ge�erli bir de�er giriniz\n');
                else
%                     fprintf('Normalize verilere K-means uygulama i�lemi yap�l�yor...\n');
%                     [idxNorm, centroidsNorm] = kMeans(normalizedData, clusterSize);
                    while true
                        fprintf('--------------------------------------\n');
                        kFoldCount = input('K-Fold i�in de�er giriniz (�nerilen: 5): ');
                        if kFoldCount < 1
                            fprintf('L�tfen ge�erli bir de�er giriniz\n');
                        else
                            fprintf('Normalize verilere K-means uygulama i�lemi yap�l�yor...\n');
                            normRandIndex = kFoldCrossValidation(size(normalizedData, 1), kFoldCount, normalizedData, clusterSize, clusterData);
                            break;
                        end
                    end
                break;
                end
            end
        case 3 %Normalize ��lemi
            while true
                fprintf('--------------------------------------\n');
                minValue = input('Min de�er giriniz (0-10): ');
                if minValue < 0 || minValue > 10
                    fprintf('L�tfen ge�erli bir de�er giriniz\n');
                else 
                    while true
                        maxValue = input('Max de�er giriniz (Min de�erden k���k ve ayn� olamaz, [0-10]): ');
                        if maxValue < 0 || maxValue > 10 || minValue > maxValue || minValue == maxValue
                            fprintf('L�tfen ge�erli bir de�er giriniz\n');
                        else 
                            fprintf('Normalize i�lemi yap�l�yor...\n');
                            normalizedData = minMaxNormalization(completedData, minValue, maxValue);
                            break;
                        end
                    end
                    break;
                end
            end
        case 4
            fprintf('--------------------------------------\n');
            fprintf('Normal verilerlerin RandIndex de�eri: %0.3f\n', defaultRandIndex);
            fprintf('Normalize edilmi� verilerlerin RandIndex de�eri: %0.3f\n', normRandIndex);
        case 5
            fprintf('��k�l�yor...\n');
            break;
        otherwise
            fprintf('Ge�ersiz se�enek, l�tfen tekrar deneyin.\n');
    end
end

%% Eksik olan veriler nitelik bazl� ortalama y�ntemi kullan�larak tamamlan�r
function completedData = fillMissingValues(data)
    
    completedData = data;
    IsAnyMissingData = 0;
    
    % Her bir s�tun i�in eksik de�erleri doldur
    for col = 1:size(data, 2)
        % S�tundaki eksik olmayan de�erlerin ortalamas�n� al
        colMean = mean(data(~isnan(data(:, col)), col));
        
        % Eksik de�erleri ortalamayla doldur
        completedData(isnan(completedData(:, col)), col) = colMean;
        
        if sum(~isnan(data(:, col))) ~= size(data, 1)
            IsAnyMissingData = 1;
        end
    end
    
    if IsAnyMissingData
       disp('Eksik veri tespit edildi ve tamamland�');
    end
    
end

%% Min-Max Normalizasyonu
function normalizedData = minMaxNormalization(data, customMin, customMax)
    % Her bir s�tunun minimum ve maksimum de�erleri
    minValues = min(data);
    maxValues = max(data);

    % Min-Max normalizasyonu form�l�: (X - min) / (max - min)
    normalizedData = (data - minValues) ./ (maxValues - minValues);

    % �zel min ve max de�erleri i�in d�n���m
    normalizedData = normalizedData * (customMax - customMin) + customMin;
end

%% Kfold Dataset Ay�rma
function indices = splitDatasetForKFold(dataSize, kFoldCount)
    % Kar��t�rarak rastgele indis dizisi olu�tur
    indices = randperm(dataSize);
    % Veri setini k katmana b�ler her katman�n �rnek say�s� belirlenir
    foldSizes = repmat(floor(dataSize / kFoldCount), 1, kFoldCount);
    % Kalan �rnek say�s� belirlenir
    remainder = dataSize - sum(foldSizes);
    
    % Kalan veriyi e�it olarak b�lmek i�in
    for i = 1:remainder
        foldSizes(i) = foldSizes(i) + 1;
    end
    
    % Veri setini K fold'a b�lmek
    indices = mat2cell(indices, 1, foldSizes);
end

%% RandIndex Hesaplama
function randIndex = calculateRandIndex(trueLabels, predictedLabels)
    % True Labels: Ger�ek etiketler
    % Predicted Labels: Tahmin edilen etiketler

    % Verinin boyutu
    n = length(trueLabels);

    % Ayn� k�mede bulunan �rnek say�s�
    a = 0;
    for i = 1:n
        for j = i+1:n
            if trueLabels(i) == trueLabels(j) && predictedLabels(i) == predictedLabels(j)
                a = a + 1;
            end
        end
    end

    % Farkl� k�mede bulunan �rnek say�s�
    b = 0;
    for i = 1:n
        for j = i+1:n
            if trueLabels(i) ~= trueLabels(j) && predictedLabels(i) ~= predictedLabels(j)
                b = b + 1;
            end
        end
    end

    % Rand Index hesapla
    randIndex = (a + b) / nchoosek(n, 2);
end

%% Kfold �apraz Do�rulama
function finalRandIndex = kFoldCrossValidation(dataSize, kFoldCount, data, clusterSize, clusterData)

    finalRandIndex = 0;
%     dataSize = size(normalizedData, 1);
    indices = splitDatasetForKFold(dataSize, kFoldCount);

        % �ndices dizisini kullan�larak e�itim ve test verileri se�ilir
        for k = 1:kFoldCount
            testIndices = indices{k};
            trainIndices = setdiff(1:dataSize, testIndices);

            % E�itim ve Test verisini se�me i�lemleri
            trainData = data(trainIndices, :);
            testData = data(testIndices, :);
            
            % E�itim ile k�me merkezleri elde edilir
            [~, centroids] = kMeans(trainData, clusterSize);
            % Elde edilen k�me merkezleri ile teste verileri k�melendirilir
            [~, cluster] = kMeansTest(testData, centroids);
            
            % trainData(:,size(trainData, 2)+1) = trainIndices;
            % trainData(:,size(trainData, 2)+1) = idx;
            % Test verilerinin indisini ve k�mesini test verisine ekleme
            % i�lemi
            % testData(:,size(testData, 2)+1) = testIndices;
            % testData(:,size(testData, 2)+1) = cluster;
            
            % Test verilerinin ger�ek ve tahmin edilen k�me de�erleri al�n�r
            realClusters = zeros(length(testIndices), 2);
            realClusters(:, 1) = clusterData(testIndices, 1);
            realClusters(:, 2) = cluster;
            
            % RandIndex hesaplan�r
            finalRandIndex = finalRandIndex + calculateRandIndex(realClusters(:, 1), realClusters(:, 2));

        end
        finalRandIndex = finalRandIndex / kFoldCount;
end






