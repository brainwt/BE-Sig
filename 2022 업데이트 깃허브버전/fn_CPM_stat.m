function [T_stat, Cook_out_idx, D, ZRE_out_idx, ZRE, p] = fn_CPM_stat(ID, CPM_type, x_opt, Tout, y_mea, date_start,date_end)


%     %%%%%%%%%%%%% (210302) �߰� %%%%%%%%%%%
% 	% y_mea 0 �� ��� nan ó�� �� ����
%     % Tout nan�� ��� ����
%     idx_y = (y_mea == 0 );
%     y_mea(idx_y)  = nan;
%     idx = ismissing(Tout) ~= 1 & ismissing(y_mea) ~= 1;
%     Tout = Tout(idx);
%     y_mea = y_mea(idx);
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%   �ڼ��� ���� ��ġ
switch CPM_type
    case '1p' % Y=b0*AA;
        p   = 1;
        p_L = 1;
        p_R = 1;
        [y_pred] = fn_CPM_1p(x_opt,Tout);
        idx_L=find(Tout <= 50);
        idx_R=find(Tout > -50 );
        
        yint_L = x_opt(1);
        yslp_L = 0;
        
        yint_R = 0;
        yslp_R = 0;
        
    case '2p_h' % Y= b0*AA - b1*Tout;
        p   = 2;
        p_L = 2;
        p_R = 2;
        [y_pred] = fn_CPM_2p_h(x_opt,Tout);
        idx_L=find(Tout <= 50);
        idx_R=find(Tout > -50 );

        yint_L = x_opt(1);
        yslp_L = - x_opt(2);
        
        yint_R = 0;
        yslp_R = 0;
        
    case '2p_c' % Y=b0*AA + b1*Tout;
        p   = 2;
        p_L = 2;
        p_R = 2;
        [y_pred] = fn_CPM_2p_c(x_opt,Tout);
        idx_L=find(Tout <= 50);
        idx_R=find(Tout > -50 );
        
        yint_L = 0;
        yslp_L = 0;
        
        yint_R = x_opt(1);
        yslp_R = x_opt(2);
        
    case '3p_h' % Y1(idx1) = b0 + b1*(b2-Tout(idx1));

        p   = 3; % �� �Ķ���� ����
        p_L = 2; % ���� (����) �Ķ���� ����
        p_R = 1; % ������ (���̽�) �Ķ���� ����

        [y_pred] = fn_CPM_3p_h(x_opt,Tout);

        idx_L=find(Tout < x_opt(3) );
        idx_R=find(Tout >= x_opt(3));
        
        yint_L = x_opt(1) + x_opt(2)*x_opt(3);
        yslp_L = - x_opt(2);
        
        yint_R = x_opt(1);
        yslp_R = 0;
        
    case '3p_c' % Y1(idx1) = b0 + b1*(Tout(idx1)-b2);
        p   = 3;
        p_L = 1;
        p_R = 2;
        [y_pred] = fn_CPM_3p_c(x_opt,Tout);

        idx_L=find(Tout <= x_opt(3) );
        idx_R=find(Tout > x_opt(3));
        
        % ------ ���� ���� ------------------------
        %yint_L = x_opt(1) - x_opt(2)*x_opt(3);
        %yslp_L = x_opt(2);
        %yint_R = x_opt(1);
        %yslp_R = 0;

        % ------ ���� ���� 220920 ------------------------
        yint_L = x_opt(1);  
        yslp_L = 0;
        yint_R = x_opt(1) - x_opt(2)*x_opt(3);
        yslp_R = x_opt(2);
    
    case '4p_h'
        % b0_0 : �����
        % b1_0 : ���� ��
        % b2_0 : ���� ��
        % b3_0 : ������
        % Y1(idx1) = b0 - b1*(Tout(idx1)-b3); 
        % Y2(idx2) = b0 - b2*(Tout(idx2)-b3);��

        p   = 4;
        p_L = 2;
        p_R = 2;

        [y_pred] = fn_CPM_4p_h(x_opt,Tout);
        idx_L=find(Tout <= x_opt(4));
        idx_R=find(Tout > x_opt(4));
        
        yint_L = x_opt(1) + x_opt(2)*x_opt(4);
        yslp_L = -x_opt(2);
        
        yint_R = x_opt(1) + x_opt(3)*x_opt(4);
        yslp_R = -x_opt(3);
        
    case '4p_c'
        % b0_0 : �����
        % b1_0 : ���� ��
        % b2_0 : ���� ��
        % b3_0 : ������
        %Y1(idx1) = b0 + b1*(Tout(idx1)-b3);
        %Y2(idx2) = b0 + b2*(Tout(idx2)-b3);

        p   = 4;
        p_L = 2;
        p_R = 2;

        [y_pred] = fn_CPM_4p_c(x_opt,Tout);
        idx_L=find(Tout <= x_opt(4));
        idx_R=find(Tout >  x_opt(4));
        
        yint_L = x_opt(1) - x_opt(2)*x_opt(4);
        yslp_L = x_opt(2);
        
        yint_R = x_opt(1) - x_opt(3)*x_opt(4);
        yslp_R = x_opt(3);
        
    case '5p'
        p   = 5;
        p_L = 2;
        p_R = 2;

        [y_pred] = fn_CPM_5p(x_opt,Tout);
        idx_L=find(Tout <= x_opt(4));
        idx_R=find(Tout >  x_opt(5));
        
        yint_L = x_opt(1) + x_opt(2)*x_opt(4);
        yslp_L = - x_opt(2);
        
        yint_R = x_opt(1) - x_opt(3)*x_opt(5);
        yslp_R = x_opt(3);

    otherwise
end

    %% RMSE 

    ns = length(Tout);    
    RMSE = sqrt( sum( (y_mea - y_pred).^2 , 'omitnan') / (ns - p));
    
    %% NMBE
    y_avg = mean(y_mea, 'omitnan');
    NMBE = sum((y_mea - y_pred), 'omitnan') / (ns - p) / y_avg * 100;
    
    %% CVRMSE
    CVRMSE = RMSE / abs(y_avg)*100;
    
    %% R2
    [R2, R2_adj]=fn_R2(y_pred,y_mea,p);
    
    % ���� b3 >= Tout
%     [R2_L, ~]=fn_R2(y_pred(idx_L),y_mea(idx_L),p_L);
        
    % ������ b4 < Tout
%     [R2_R, ~]=fn_R2(y_pred(idx_R),y_mea(idx_R),p_R);

    %% t-score, pval
    
    % ���� b3 >= Tout   
    [~, ~, ~, pval_b_L]=fn_t_score(Tout(idx_L), y_mea(idx_L), y_pred(idx_L), p_L, yint_L, yslp_L);
    
    % ������ b4 < Tout     
	[~, ~, ~, pval_b_R]=fn_t_score(Tout(idx_R), y_mea(idx_R), y_pred(idx_R), p_R, yint_R, yslp_R);

    % ��� setxor
    idx_A=1:length(Tout);
    C = setxor(idx_A,[idx_L,idx_R]);
	[~, ~, pval_c_C, ~]=fn_t_score(Tout(C), y_mea(C), y_pred(C), 1, x_opt(1), 0);


    %% �������
    % ttest_cell = num2cell([[t_c_L, pval_c_L, t_b_L, pval_b_L],[t_c_R, pval_c_R, t_b_R, pval_b_R],[t_c_C, pval_c_C, t_b_C, pval_b_C]]);

    % (210302) ��� ���� ����
    ttest_cell = num2cell([pval_b_L, pval_b_R, pval_c_C] );
    
    
    %% cook d
    [Cook_out_idx, D] = fn_cook_d(Tout, y_pred, y_mea, p);

    %% ǥ��ȭ ����
    [ZRE_out_idx, ZRE]=fn_ZRE(y_pred, y_mea, p);

       %% save stat
    if length(x_opt) < 5
        for m=1: 5 - length(x_opt) 
            x_opt = [x_opt, 0];
        end        
    end
    b0= x_opt(1);
    b1= x_opt(2);
    b2= x_opt(3);
    b3= x_opt(4);
    b4= x_opt(5);   
    
    % find nearest months    
    switch CPM_type
        case '1p'
            P_M1 = 0;
            P_M2 = 0;
        case '2p_h'
            P_M1 = 0;
            P_M2 = 0;
            
        case '2p_c'
            P_M1 = 0;
            P_M2 = 0;
            
        case '3p_h'
            [val,idx]=min( abs (Tout-b2) );
            P_M1 = idx; % ���� ���� ����� ��
            P_M2 = 0;

        case '3p_c'
            [val,idx]=min( abs (Tout-b2) );
            P_M1 = idx; % ���� ���� ����� ��
            P_M2 = 0;

        case '4p_h'
            [val,idx]=min( abs (Tout-b3) );
            P_M1 = idx; % ���� ���� ����� ��
            P_M2 = 0;
            
        case '4p_c'
            [val,idx]=min( abs (Tout-b3) );
            P_M1 = idx; % ���� ���� ����� ��
            P_M2 = 0;
            
        case '5p'
            [val1,idx1]=min( abs (Tout-b3) );
            [val2,idx2]=min( abs (Tout-b4) );
            P_M1 = idx1; % ���� ���� ����� ��
            P_M2 = idx2;
            
        otherwise
    end

%% ����
%     TC = [{ID}, {date_start},{date_end},{CPM_type}, num2cell([b0,b1,b2,b3,b4, ns, RMSE, NMBE, CVRMSE,  R2, R2_adj, R2_L, R2_R]), ttest_cell,...
%         {Cook_out_idx}, {ZRE_out_idx},{P_M1},{P_M2}];
% 	colnms={'ID','DATE_S','DATE_E','CPM_TY', 'b0','b1','b2','b3','b4', 'ns', 'RMSE', 'NMBE', 'CVRMSE', 'R2', 'R2_adj', 'R2_L', 'R2_R'...
%             't_c_L','pval_c_L', 't_b_L', 'pval_b_L',...
%             't_c_R','pval_c_R', 't_b_R', 'pval_b_R',...
%             't_c_C','pval_c_C', 't_b_C', 'pval_b_C',...
%             'Ckd_out_idx', 'ZRE_out_idx'...
%             'P_M1','P_M2'};

% (210302) ��� ���� ����
%     TC = [{ID}, {date_start},{date_end},{CPM_type}, num2cell([b0,b1,b2,b3,b4, ns, RMSE, NMBE, CVRMSE,  R2_adj,]), ttest_cell,...
%         {Cook_out_idx}, {ZRE_out_idx},{P_M1},{P_M2}];
% 	colnms={'ID','DATE_S','DATE_E','CPM_TY', 'b0','b1','b2','b3','b4', 'ns', 'RMSE', 'NMBE', 'CVRMSE', 'R2_adj',...
%             'pval_b_L','pval_b_R','pval_c_C',...
%             'Ckd_out_idx', 'ZRE_out_idx'...
%             'P_M1','P_M2'};

% (220824) R2 �߰���. ���ü��� ���� ��� ���� adj R2 ���ʿ�� ���� ������ ������ ���Ȥ�
    TC = [{ID}, {date_start},{date_end},{CPM_type}, num2cell([b0,b1,b2,b3,b4, ns, RMSE, NMBE, CVRMSE,  R2_adj,]), ttest_cell,...
        {Cook_out_idx}, {ZRE_out_idx},{P_M1},{P_M2},...
        {R2}];
	colnms={'ID','DATE_S','DATE_E','CPM_TY', 'b0','b1','b2','b3','b4', 'ns', 'RMSE', 'NMBE', 'CVRMSE', 'R2_adj',...
            'pval_b_L','pval_b_R','pval_c_C',...
            'Ckd_out_idx', 'ZRE_out_idx'...
            'P_M1','P_M2',...
            'R2'};

	T_stat= cell2table(TC,'variablenames',colnms);
    
end



    %% auto correlation coefficient fo residuals, p
% least-squares regression assumes that p is approximately zero.
% as p gets closer to one, this assumption becomes suspect and
% RMSE may underestimate the true uncertainty of the model
% RMSE ���� ��Ȯ�Ǽ��� �� �ݿ����� ���Ѵ�. 
% 
%     errs = y_pred - y_mea;
%     for m=2:length(errs)
%        pp1(m-1,1)=errs(m-1)*errs(m);
%        dw(m-1,1)=(errs(m-1)-errs(m))^2;
%        pp2(m-1,1)=errs(m-1)^2;
%     end
%      p = sum(pp1)/sum(pp2);
%     %% Curbin Watson statistic
% %     0 ���� �ڱ���
% %     2 �ڱ��� ����
% %     4 ���� �ڱ� ���
%     DW= dw / pp2 ; 
%     
%     %% ȸ�Ͱ���� �л�
%     % ������ �л�
% %     std_err = sqrt(  SSerr / (ns-p) );
    

function [R2, R2_adj] = fn_R2(y_pred,y_mea,p)
    ns = length(y_pred);   
    y_avg = mean(y_mea, 'omitnan') ;
    SSerr=sum( ( y_pred - y_mea ).^2 , 'omitnan') ;
    SStot=sum( ( y_mea - y_avg  ).^2 , 'omitnan') ;
    
%     R2 = 1 - SSerr/SStot;
    eee = 0.00001;
    R2 = 1 - SSerr/(SStot+ eee); % �ʹ� ���� ���̸� �߻���    
    R2_adj = 1 - (ns - 1)/(ns - p)*(1-R2^2);
end


function [t_c, t_b, pval_c, pval_b]=fn_t_score(Tout, y_mea, y_pred, p, yint, yslp)

    x = Tout;
    x_bar = mean(x);
    x_var = sum( (x - x_bar).^2 );
    ns = length(x);   
	RMSE = sqrt( sum( (y_mea - y_pred).^2 , 'omitnan') / (ns - p));
	Se_b0 = RMSE * sqrt( 1/ns + (x_bar^2/ x_var) );
    Se_b1 = RMSE / sqrt( x_var );

    % ���� ���̾�� �Ѵ�. 
%     t_c = abs(yint)/Se_b0;
%     t_b = abs(yslp)/Se_b1; 
    
    t_c = yint/Se_b0;
    t_b = yslp/Se_b1; 
    
    % degree of freedom
    df = ns - p;
    % Probability of larger t-statistic
    % ���� �����̹Ƿ�, �Ѱ輱���� ����� �ڿ� ���ش�. 
    
    pval_c = (1-tcdf(abs(t_c), df))*2;  
    pval_b = (1-tcdf(abs(t_b), df))*2;  
    
    % ���� ������ tcdf ���ʸ� ���� ���� �� *2 �ϸ� �Ǵµ�. �� ó�� �׳� ���밪���� ����.
    % pval�� ���� Ȯ�� alpha(=0.05) ���� ���� ��� H0�� �Ⱒ�Ѵ�. 
    
end




function [Cook_out_idx, D]=fn_cook_d(Tout, y_pred, y_mea, p)
    ns = length(Tout);
    mean_Tout = sum(Tout)/ns;
    h1 = (Tout-mean_Tout).^2;
    h2 = sum((Tout-mean_Tout).^2);
    h3 = 1/ns;
    h = (h1./h2)+h3;

    % Cook's d
%     ��� ����
%     https://kr.mathworks.com/help/stats/cooks-distance.html
    err = (y_pred - y_mea).^2;
%     RMSE = sqrt( sum( (y_mea - y_pred).^2 , 'omitnan') / (ns - p));
    MSE = sum( (y_mea - y_pred).^2 , 'omitnan') / (ns - p);
%     D = (err) ./(RMSE*p) .* (h./((1-h).^2));
    D = (err) ./(MSE*p) .* (h./((1-h).^2));
    
    % �Ϲ� ������ 
%     REF  = 4  / (ns-p-1);    
    
    % ���� ������
%     REF  = 1;
    
    % MATLAB ������
    REF = 3 * mean(D,'omitnan');

    idx = find(D > REF);
    Cook_out_idx = replace( mat2str(idx), ',', '/');

end





function [ZRE_out_idx, ZRE]=fn_ZRE(y_pred, y_mea, p)
    ns = length(y_pred);
    RMSE = sqrt( sum( (y_mea - y_pred).^2 , 'omitnan') / (ns - p));
    Sx= RMSE;
    
    e =(y_pred-y_mea);
    
    ZRE = (e-mean(e, 'omitnan')) / Sx;
    
    REF = 2.5;
    idx = find(ZRE > REF | ZRE < -REF);
%     newStr = replace(str,old,new)
    ZRE_out_idx = replace( mat2str(idx), ',', '/');
end

