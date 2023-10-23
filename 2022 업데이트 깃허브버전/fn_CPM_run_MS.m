function [save_T_stat, C_cookd, C_ZRE] = fn_CPM_run_MS(Tout, y_mea, pathnm_csv, pathnm_pics, Case_str, date_fr, date_to)
% https://www.sciencedirect.com/science/article/pii/S0378778814009645

%% ���� ����
% �ۼ���: �����
% �ۼ���: 191206
    
% ���ǻ���
% Tout�� y_mea�� 1x12n �迭�̾����. 

% ��������
% (220608) ���� ������ ����. �̻�ġ Ž���� Ȱ��.
% (210302) ���е� 1% ������ ��뷮�� nan ���� ó���Ѵ�.
% (210302) 4parameter ���� ������� ����

%--------------------------------------------------
% (230417) GlobalSearch ���� ������ ������
% gs = GlobalSearch;
% [x_opt,fval] = run(gs,problem);    
%--------------------------------------------------

%% ���� üũ
fnExistFolder(pathnm_pics);

%% �ؼҰ� ó��
% 220608 NaN ���� �� ���ؼ� ��ó�� : ���� lb�� ���� ub�� NaN�� �ƴϾ�� �մϴ�.
% y_mea( y_mea <= prctile(y_mea,1) ) = nan;
% idx= y_mea <= prctile(y_mea,1) & y_mea <= median(y_mea)/10;
% y_mea( idx ) = nan;


%% CPM type ����
% CPM_type_list={'1p','2p_h','2p_c','3p_h','3p_c','4p_h','4p_c','5p'};
CPM_type_list={'1p','2p_h','2p_c','3p_h','3p_c','5p'};

%% �ֹ���� ����ȭ
% �ʱⰪ ���� - �ſ� �߿�. ���Ű��� �ް��� �޶���


% �ܱ� �µ� Ž�� ���� ����
% 1�� ����
% To_lb= 5;
% To_ub= 20;

% 2�� ����
% To_lb= 0;
% To_ub= 30;

% 3�� ���� (221212)
To_lb= 0;
To_ub= 25;

% ȸ�� �Ķ���� ����

Y_min = min(y_mea);
Y_max = max(y_mea);

% 1������
% b0_0 = median(y_mea, 'omitnan');
% b1_0 = (Y_max-Y_min)/100; % 
% b2_0 = b1_0;

% 2������
b0_0 = 0;  
b1_0 = 0; 
b2_0 = 0;

save_T_stat = [];

for m=1:length(CPM_type_list)
% for m=1:3
    CPM_type=CPM_type_list{m};
%     CPM_type
    f = @(x)fn_CPM_obj(x, Tout, y_mea, CPM_type);

        %% �ʱⰪ �������� ����
        % A = [1,2] �� b = 1�� ����Ͽ� A*x <= b �������� ���� �ε�� ���� ������ ��Ÿ���ϴ�.
        % Aeq = [2,1] �� beq = 1�� ����Ͽ� Aeq*x = beq �������� ���� ��� ���� ������ ��Ÿ���ϴ�

    switch CPM_type
        case '1p'
            x0 = [b0_0 ];  % b0, b1
            A = []; 
            b = [];
            Aeq=[];
            beq=[];
            lb=[Y_min];
            ub=[Y_max];
            nonlcon=[];

        case '2p_h'
            % b0_0 : ���� ����
            % b1_0 : ���� �����

            x0 = [b0_0  b1_0];             

            A = []; 
            b = [];
            Aeq=[];
            beq=[];
            
            lb=[0       Y_min]; % ����� ���� �Ǵ� ��� % https://www.sciencedirect.com/science/article/pii/S0378778814009645
            ub=[inf     Y_max];
            nonlcon=[];

        case '2p_c'
            % b0_0 : ���� �����
            % b1_0 : ���� ����

            x0 = [b0_0  b1_0];  % b0, b1
            A = []; 
            b = [];
            Aeq=[];
            beq=[];

            lb=[Y_min     0]; % ����� ���� �Ǵ� ��� % https://www.sciencedirect.com/science/article/pii/S0378778814009645
            ub=[Y_max   inf];
            nonlcon=[];
            
        case '3p_h'
            % b0_0 : �����
            % b1_0 : ����
            % b2_0 : ������

            x0 = [b0_0  b1_0  (To_lb+To_ub)/2];  % b0, b1, b2
            A = [];   
            b = [];
            Aeq=[];
            beq=[];
            lb=[Y_min     0      To_lb];
            ub=[Y_max    inf     To_ub];
            nonlcon=[];

        case '3p_c'
            % b0_0 : �����
            % b1_0 : ����
            % b2_0 : ������

            x0 = [b0_0  b1_0  (To_lb+To_ub)/2];  % b0, b1, b2
            A  = [];  
            b  = [];
            Aeq= [];
            beq= [];
            lb = [Y_min     0   To_lb];
            ub = [Y_max   inf   To_ub];
            nonlcon=[];

        case '5p'
            % b0_0 : �����
            % b1_0 : ���� ����
            % b2_0 : ���� ����
            % b3_0 : ���� ������
            % b4_0 : ���� ������

            x0 = [b0_0  b1_0  b2_0  (To_lb+To_ub)/2  (To_lb+To_ub)/2]; 
%             x0 = [b0_0  b1_0  b2_0  To_lb  To_ub]; 
            A  = [0      0  0  1  -1];  % b3 <= b4
            b  = [0];
            Aeq= [];
            beq= [];
            lb = [Y_min      0     0   To_lb    To_lb]; % To_lb = 10
            ub = [Y_max    inf   inf   To_ub    To_ub]; % To_lb = 20
            nonlcon=[];

% ------------------------------------------------- %
        case '4p_h'
            % b0_0 : �����
            % b1_0 : ���� ��
            % b2_0 : ���� ��
            % b3_0 : ������

            x0 = [b0_0  b1_0  b2_0  (To_lb+To_ub)/2];  % b0, b1, b2, b3
            %  A*x <= b              
            A = [0 -1 1 0];  % -b1+b2 <= 0
            b = [0];
            Aeq=[];
            beq=[];
            lb=[0     0     0   To_lb];
            ub=[inf inf   inf   To_ub];
            nonlcon=[];

        case '4p_c'
            % b0_0 : �����
            % b1_0 : ���� ��
            % b2_0 : ���� ��
            % b3_0 : ������

            x0 = [b0_0  b1_0  b2_0  (To_lb+To_ub)/2];  % b0, b1, b2, b3
            %  A*x <= b   
            A = [0 1 -1 0];  % -b1+b2 <= 0
            b = [0];
            Aeq=[];
            beq=[];
            lb=[0     0     0   To_lb];
            ub=[inf inf   inf   To_ub];
            nonlcon=[];        
% ------------------------------------------------- %
        otherwise
    end

    %% ����ȭ

    % --------- legacy ���� ---------
    % options = optimoptions('fmincon','Display','off');
    % [x_opt,fval,exitflag,output]  = fmincon(f,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
    
    % ---------  ��Ƽ��ŸƮ ���� (230414) ---------
    options = optimoptions('fmincon','Display','off','Algorithm','sqp');
    problem = createOptimProblem('fmincon','objective',...
    f,'x0',x0,'Aineq',A,'bineq',b,'lb',lb,'ub',ub,'nonlcon',nonlcon,'options',options);

    % �ߵ�
    rs = RandomStartPointSet('NumStartPoints',20,'ArtificialBound',10000); % ArtificialBound ����Ʈ = 1000
    
    % % ������ �ð�ȭ : ������� �����
    % points = list(rs,problem);
    % figure("Visible","off")
    % t=tiledlayout(3,2,'TileSpacing','Compact');
    % for k = 1:numel(x0)
    %     nexttile
    %     plot(points(:,k))
    %     hold on
    %     plot(x0(k),"Marker",'x','Color','r')
    %     title(['b',num2str(k)])
    % end
    % title(t,['CPM type : ', CPM_type])
    % xlabel(t,'samples')
    % 
    % pic_name = ['CPM_RandomStartPointSet_pk',Case_str];
    % saveas(gcf, [pathnm_pics, pic_name, num2str(date_fr), num2str(date_to)], 'png')
    
    ms = MultiStart;
    [x_opt,fval] = run(ms,problem, rs);
    
    %% ��� ����
    [T_stat, Cook_out_idx, D, ~, ZRE, p ] = fn_CPM_stat(Case_str, CPM_type, x_opt, Tout, y_mea, date_fr,date_to );
    
    C_cookd(m,1) = {D};
%     C_cookd(m,1) = {Cook_out_idx};    
    C_ZRE(m,1) = {ZRE};

    % save opt x
    save_T_stat = [save_T_stat;T_stat];
        
end  
            
    %% ���� �� ����

    [~,p1] = sort(save_T_stat.RMSE);
    r1 = transpose( 1:length(save_T_stat.RMSE) );
    r1(p1) = r1;
    rank_md = [r1];

    [~,p2] = sort(rank_md);
    r2 = transpose( 1:length(rank_md) );
    r2(p2) = r2;
    MD_RANK = r2;
    
    % ��ũ ����
    save_T_stat.MD_RANK = MD_RANK;
    save_T_stat = movevars(save_T_stat, 'MD_RANK', 'Before', 'b0');
        
end


