
%p300.m �F P300���m�F���邽�߂̃v���O����
%�t�B���^��ʂ����iOpenBCI���Łjxdf�`���̃f�[�^�ɑ΂���
%�h���񎦂����b�̃f�[�^�ŉ��Z���ς��s���āC������v���b�g����

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%�t�@�C�����ƃv���b�g����`�����l����I������
ch =2;
fname = "2019-06-10\oddballpic.xdf";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

xdfdata = load_xdf(fname);              %�@�֐���path��ʂ��K�v����

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
data_t = data_t - data_offset;              % �X�^�[�g���[���ɂ���

stimu = xdfStimu.time_series;
stimu_t = xdfStimu.time_stamps;
stimu_t = stimu_t - data_offset;

ave_target = zeros(1,250);                  %�f�[�^��0�l�߂���
ave_normal = zeros(1,250);

j=1;
counter=0;

for i=1:1:length(stimu)
    if (stimu(i)==1) && (counter ~= 1)
        while (data_t(j)<stimu_t(i))        %�^�[�Q�b�g�h���̏ꍇ
            j=j+1;
        end
        for k=1:1:250                       %�͂��߂���1�b�Ԃ����擾����
            ave_target(k) = ave_target(k) + data(j);
            j = j+1;
        end
        counter = 1;
        
    elseif (stimu(i)==2) && (counter ~= 2)  %�m�[�}���h���̏ꍇ
        while (data_t(j)<stimu_t(i)) 
            j=j+1;
        end
        for k=1:1:250
            ave_normal(k) = ave_normal(k) + data(j);
            j = j+1;
        end
        counter = 2;
    elseif  stimu(i)==0                     %�h�����Ȃ��ꍇ
        counter = 0;
    else                                    %�h���񎦂����1�b�ȊO�͂Ȃɂ����Ȃ�
        %�������Ȃ�
    end
end

figure(1); plot(4:4:1000, ave_target(1:250))        %�v���b�g
figure(2); plot(4:4:1000, ave_normal(1:250))
