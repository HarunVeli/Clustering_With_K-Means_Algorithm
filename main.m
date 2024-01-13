%% BÝLGÝLER
% 20010011011
% Harun Veli Tosun

%%
clc;
clear;

%% Veri Okuma, Eksik Veri Tamamlama ve Normalize Ýþlemi
% NOT -> Verilerin son sütunu küme deðerleri olarak sütun baþlýklarý ise 
% yok olarak kabul edildi ve okuma
% iþlemi ona göre yapýldý
data = xlsread('IrisLastVersion.xlsx','Cluster');
% FARKLI VERÝ SETÝ (Dinamik kontrolü saðlamak için)
% data = xlsread('DiabetesDataSet.xlsx','Sheet4');
clusterData = data(:, size(data, 2));
data(:, size(data, 2)) = [];
completedData = fillMissingValues(data);
normalizedData = minMaxNormalization(completedData, 0, 1);

%% Tanýmlamalar
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
    fprintf('4. RandIndex Karþýlaþtýr\n');
    fprintf('5. Çýkýþ\n');
    
    choice = input('Lütfen bir seçenek girin (1-5): ');
    
    switch choice
        case 1 %K-Means
            while true
                fprintf('--------------------------------------\n');
                clusterSize = input('Lütfen bir küme sayýsý girin (1-10): ');
                if clusterSize < 1 || clusterSize > 10
                    fprintf('Lütfen geçerli bir deðer giriniz\n');
                else
%                     fprintf('K-means uygulama iþlemi yapýlýyor...\n');
%                     [idx, centroids] = kMeans(completedData, clusterSize);
                    while true
                        fprintf('--------------------------------------\n');
                        kFoldCount = input('K-Fold için deðer giriniz (önerilen: 5): ');
                        if kFoldCount < 1
                            fprintf('Lütfen geçerli bir deðer giriniz\n');
                        else
                            fprintf('K-means uygulama iþlemi yapýlýyor...\n');
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
                clusterSize = input('Lütfen bir küme sayýsý girin (1-10): ');
                if clusterSize < 1 || clusterSize > 10
                    fprintf('Lütfen geçerli bir deðer giriniz\n');
                else
%                     fprintf('Normalize verilere K-means uygulama iþlemi yapýlýyor...\n');
%                     [idxNorm, centroidsNorm] = kMeans(normalizedData, clusterSize);
                    while true
                        fprintf('--------------------------------------\n');
                        kFoldCount = input('K-Fold için deðer giriniz (önerilen: 5): ');
                        if kFoldCount < 1
                            fprintf('Lütfen geçerli bir deðer giriniz\n');
                        else
                            fprintf('Normalize verilere K-means uygulama iþlemi yapýlýyor...\n');
                            normRandIndex = kFoldCrossValidation(size(normalizedData, 1), kFoldCount, normalizedData, clusterSize, clusterData);
                            break;
                        end
                    end
                break;
                end
            end
        case 3 %Normalize Ýþlemi
            while true
                fprintf('--------------------------------------\n');
                minValue = input('Min deðer giriniz (0-10): ');
                if minValue < 0 || minValue > 10
                    fprintf('Lütfen geçerli bir deðer giriniz\n');
                else 
                    while true
                        maxValue = input('Max deðer giriniz (Min deðerden küçük ve ayný olamaz, [0-10]): ');
                        if maxValue < 0 || maxValue > 10 || minValue > maxValue || minValue == maxValue
                            fprintf('Lütfen geçerli bir deðer giriniz\n');
                        else 
                            fprintf('Normalize iþlemi yapýlýyor...\n');
                            normalizedData = minMaxNormalization(completedData, minValue, maxValue);
                            break;
                        end
                    end
                    break;
                end
            end
        case 4
            fprintf('--------------------------------------\n');
            fprintf('Normal verilerlerin RandIndex deðeri: %0.3f\n', defaultRandIndex);
            fprintf('Normalize edilmiþ verilerlerin RandIndex deðeri: %0.3f\n', normRandIndex);
        case 5
            fprintf('Çýkýlýyor...\n');
            break;
        otherwise
            fprintf('Geçersiz seçenek, lütfen tekrar deneyin.\n');
    end
end

%% Eksik olan veriler nitelik bazlý ortalama yöntemi kullanýlarak tamamlanýr
function completedData = fillMissingValues(data)
    
    completedData = data;
    IsAnyMissingData = 0;
    
    % Her bir sütun için eksik deðerleri doldur
    for col = 1:size(data, 2)
        % Sütundaki eksik olmayan deðerlerin ortalamasýný al
        colMean = mean(data(~isnan(data(:, col)), col));
        
        % Eksik deðerleri ortalamayla doldur
        completedData(isnan(completedData(:, col)), col) = colMean;
        
        if sum(~isnan(data(:, col))) ~= size(data, 1)
            IsAnyMissingData = 1;
        end
    end
    
    if IsAnyMissingData
       disp('Eksik veri tespit edildi ve tamamlandý');
    end
    
end

%% Min-Max Normalizasyonu
function normalizedData = minMaxNormalization(data, customMin, customMax)
    % Her bir sütunun minimum ve maksimum deðerleri
    minValues = min(data);
    maxValues = max(data);

    % Min-Max normalizasyonu formülü: (X - min) / (max - min)
    normalizedData = (data - minValues) ./ (maxValues - minValues);

    % Özel min ve max deðerleri için dönüþüm
    normalizedData = normalizedData * (customMax - customMin) + customMin;
end

%% Kfold Dataset Ayýrma
function indices = splitDatasetForKFold(dataSize, kFoldCount)
    % Karýþtýrarak rastgele indis dizisi oluþtur
    indices = randperm(dataSize);
    % Veri setini k katmana böler her katmanýn örnek sayýsý belirlenir
    foldSizes = repmat(floor(dataSize / kFoldCount), 1, kFoldCount);
    % Kalan örnek sayýsý belirlenir
    remainder = dataSize - sum(foldSizes);
    
    % Kalan veriyi eþit olarak bölmek için
    for i = 1:remainder
        foldSizes(i) = foldSizes(i) + 1;
    end
    
    % Veri setini K fold'a bölmek
    indices = mat2cell(indices, 1, foldSizes);
end

%% RandIndex Hesaplama
function randIndex = calculateRandIndex(trueLabels, predictedLabels)
    % True Labels: Gerçek etiketler
    % Predicted Labels: Tahmin edilen etiketler

    % Verinin boyutu
    n = length(trueLabels);

    % Ayný kümede bulunan örnek sayýsý
    a = 0;
    for i = 1:n
        for j = i+1:n
            if trueLabels(i) == trueLabels(j) && predictedLabels(i) == predictedLabels(j)
                a = a + 1;
            end
        end
    end

    % Farklý kümede bulunan örnek sayýsý
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

%% Kfold Çapraz Doðrulama
function finalRandIndex = kFoldCrossValidation(dataSize, kFoldCount, data, clusterSize, clusterData)

    finalRandIndex = 0;
%     dataSize = size(normalizedData, 1);
    indices = splitDatasetForKFold(dataSize, kFoldCount);

        % Ýndices dizisini kullanýlarak eðitim ve test verileri seçilir
        for k = 1:kFoldCount
            testIndices = indices{k};
            trainIndices = setdiff(1:dataSize, testIndices);

            % Eðitim ve Test verisini seçme iþlemleri
            trainData = data(trainIndices, :);
            testData = data(testIndices, :);
            
            % Eðitim ile küme merkezleri elde edilir
            [~, centroids] = kMeans(trainData, clusterSize);
            % Elde edilen küme merkezleri ile teste verileri kümelendirilir
            [~, cluster] = kMeansTest(testData, centroids);
            
            % trainData(:,size(trainData, 2)+1) = trainIndices;
            % trainData(:,size(trainData, 2)+1) = idx;
            % Test verilerinin indisini ve kümesini test verisine ekleme
            % iþlemi
            % testData(:,size(testData, 2)+1) = testIndices;
            % testData(:,size(testData, 2)+1) = cluster;
            
            % Test verilerinin gerçek ve tahmin edilen küme deðerleri alýnýr
            realClusters = zeros(length(testIndices), 2);
            realClusters(:, 1) = clusterData(testIndices, 1);
            realClusters(:, 2) = cluster;
            
            % RandIndex hesaplanýr
            finalRandIndex = finalRandIndex + calculateRandIndex(realClusters(:, 1), realClusters(:, 2));

        end
        finalRandIndex = finalRandIndex / kFoldCount;
end






