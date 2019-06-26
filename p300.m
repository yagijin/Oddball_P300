
%p300.m ： P300を確認するためのプログラム
%フィルタを通した（OpenBCI側で）xdf形式のデータに対して
%刺激提示から一秒のデータで加算平均を行って，それをプロットする

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%ファイル名とプロットするチャンネルを選択する
ch =2;
fname = "2019-06-10\oddballpic.xdf";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

xdfdata = load_xdf(fname);              %　関数のpathを通す必要あり

eeg_idx = 1;
stimu_idx=0;

if length(xdfdata)==2
    if strcmp(xdfdata{1}.info.type, 'stimulation')
        stimu_idx=1; 
        eeg_idx = 2;
    elseif strcmp(xdfdata{2}.info.type, 'stimulation')
        eeg_idx = 1;
        stimu_idx=2; 
    end
end   
xdfEEG = xdfdata{eeg_idx};
xdfStimu = xdfdata{stimu_idx};

data = xdfEEG.time_series(ch,:);
data_t = xdfEEG.time_stamps;
data_offset = data_t(1);
data_t = data_t - data_offset;              % スタートをゼロにする

stimu = xdfStimu.time_series;
stimu_t = xdfStimu.time_stamps;
stimu_t = stimu_t - data_offset;

ave_target = zeros(1,250);                  %データを0詰めする
ave_normal = zeros(1,250);

j=1;
counter=0;

for i=1:1:length(stimu)
    if (stimu(i)==1) && (counter ~= 1)
        while (data_t(j)<stimu_t(i))        %ターゲット刺激の場合
            j=j+1;
        end
        for k=1:1:250                       %はじめから1秒間だけ取得する
            ave_target(k) = ave_target(k) + data(j);
            j = j+1;
        end
        counter = 1;
        
    elseif (stimu(i)==2) && (counter ~= 2)  %ノーマル刺激の場合
        while (data_t(j)<stimu_t(i)) 
            j=j+1;
        end
        for k=1:1:250
            ave_normal(k) = ave_normal(k) + data(j);
            j = j+1;
        end
        counter = 2;
    elseif  stimu(i)==0                     %刺激がない場合
        counter = 0;
    else                                    %刺激提示からの1秒以外はなにもしない
        %何もしない
    end
end

figure(1); plot(4:4:1000, ave_target(1:250))        %プロット
figure(2); plot(4:4:1000, ave_normal(1:250))
