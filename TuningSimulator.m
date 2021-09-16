function TuningSimulator(varargin)
% Training Simulator to tune and match an NMR probe.
%
% 8/26/2021 Dr. Kosuke Ohgo
% 
% Please read README_TuningSimulator.docx or .pdf for detail.

% MIT License
%
% Copyright (c) 2021 Kosuke Ohgo
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.

global fig1 
global x_p_ini y_p_ini
global size_no
global v_T v_M
global ui_Check1 ui_Check2 ui_Check3 ui_Check4
global h1 h2 h3 h4
global x_p_vec y_p_vec
global min_record
global M_ang_Quad
global ui_T_ls ui_T_ll ui_T_rs ui_T_rl
global ui_M_ls ui_M_ll ui_M_rs ui_M_rl
global T_ui_T T_ui_M
global init_switch max_z_mat
       
if nargin==0
    action='initialize';
else
    action=varargin{1};
end

switch action
    case 'initialize'
        close all
        
       %% Initial parameters
        init_switch=1;
        size_no=180;
        x_p_ini=(rand-0.5)*2*size_no;%x_p: somewhere in [-size_no -size_no], rand: [0 1] => (rand-0.5)*2: [-1 1]
        y_p_ini=(rand-0.5)*2*size_no;%y_p: somewhere in [-size_no -size_no], rand: [0 1] => (rand-0.5)*2: [-1 1]
        x_p_vec=[];
        y_p_vec=[];
        min_record=1;
        M_ang_Quad=floor(4*rand);%randm number from [0 1 2 3]
        v_T=0;
        v_M=0;
        
        fig1=figure;
        set(fig1,'position',[1    41   1366   651])
        figure(fig1)
        
        %% Setup UI
        %% Pushbutton for Tuning
        ui_offset_x1=80;ui_offset_y1=0;
        uicontrol('style','text','position',[100+ui_offset_x1 50+ui_offset_y1 50 20],'string','Tuning','horizontalalignment','left','BackgroundColor',[0.8 0.8 0.8]); 
        ui_T_ls=uicontrol('style','pushbutto','position',[200+ui_offset_x1 35+ui_offset_y1 30 30],...
        'string','<','callback','TuningSimulator(''ui_pb'',1)');

        ui_offset_x1=80;ui_offset_y1=-35;
        ui_T_ll=uicontrol('style','pushbutto','position',[200+ui_offset_x1 35+ui_offset_y1 30 30],...
        'string','<<','callback','TuningSimulator(''ui_pb'',2)');
    
        ui_offset_x1=160;ui_offset_y1=0;
        ui_T_rs=uicontrol('style','pushbutto','position',[200+ui_offset_x1 35+ui_offset_y1 30 30],...
        'string','>','callback','TuningSimulator(''ui_pb'',3)');

        ui_offset_x1=160;ui_offset_y1=-35;
        ui_T_rl=uicontrol('style','pushbutto','position',[200+ui_offset_x1 35+ui_offset_y1 30 30],...
        'string','>>','callback','TuningSimulator(''ui_pb'',4)');
    
        ui_offset_x1=mean([80 160]);
        ui_offset_y1=0;
        T_ui_T=uicontrol('style','text','position',[200+ui_offset_x1 35+ui_offset_y1 30 30],'string',sprintf('%d',v_T),...
                  'horizontalalignment','right','BackgroundColor',[1 1 1]*1);    
    
       %% Refreshing      
        ui_offset_x1=600;ui_offset_y1=0;
        uicontrol('style','pushbutto','position',[200+ui_offset_x1 35+ui_offset_y1 100 30],...
        'string','Refresh','callback','TuningSimulator(''initialize'')');
    
        %% Pushbutton for Matching
        ui_offset_x2=300;
        ui_offset_x1=80+ui_offset_x2;ui_offset_y1=0;
        uicontrol('style','text','position',[100+ui_offset_x1 50+ui_offset_y1 50 20],'string','Matching','horizontalalignment','left','BackgroundColor',[0.8 0.8 0.8]); 
        ui_M_ls=uicontrol('style','pushbutto','position',[200+ui_offset_x1 35+ui_offset_y1 30 30],...
        'string','<','callback','TuningSimulator(''ui_pb'',5)');

        ui_offset_x1=80+ui_offset_x2;ui_offset_y1=-35;
        ui_M_ll=uicontrol('style','pushbutto','position',[200+ui_offset_x1 35+ui_offset_y1 30 30],...
        'string','<<','callback','TuningSimulator(''ui_pb'',6)');
    
        ui_offset_x1=160+ui_offset_x2;ui_offset_y1=0;
        ui_M_rs=uicontrol('style','pushbutto','position',[200+ui_offset_x1 35+ui_offset_y1 30 30],...
        'string','>','callback','TuningSimulator(''ui_pb'',7)');

        ui_offset_x1=160+ui_offset_x2;ui_offset_y1=-35;
        ui_M_rl=uicontrol('style','pushbutto','position',[200+ui_offset_x1 35+ui_offset_y1 30 30],...
        'string','>>','callback','TuningSimulator(''ui_pb'',8)');
    
        ui_offset_x1=mean([80 160])+ui_offset_x2;
        ui_offset_y1=0;
        T_ui_M=uicontrol('style','text','position',[200+ui_offset_x1 35+ui_offset_y1 30 30],'string',sprintf('%d',v_M),...
                  'horizontalalignment','right','BackgroundColor',[1 1 1]*1);   
        
       %% Checkbox1
        ui_offset_x1=200;ui_offset_y1=600;
        ui_Check1=uicontrol('style','checkbox','position',[ui_offset_x1 5+ui_offset_y1 20 20],...
        'Value',1','callback','TuningSimulator(''plot'')');
            
        %% Checkbox2
        ui_offset_x1=800;ui_offset_y1=600;
        ui_Check2=uicontrol('style','checkbox','position',[ui_offset_x1 5+ui_offset_y1 20 20],...
        'Value',1','callback','TuningSimulator(''plot'')');

        %% Checkbox3        
        ui_offset_x1=200;ui_offset_y1=300;
        ui_Check3=uicontrol('style','checkbox','position',[ui_offset_x1 5+ui_offset_y1 20 20],...
        'Value',1','callback','TuningSimulator(''plot'')');

        %% Checkbox4            
        ui_offset_x1=800;ui_offset_y1=300;
        ui_Check4=uicontrol('style','checkbox','position',[ui_offset_x1 5+ui_offset_y1 20 20],...
        'Value',1','callback','TuningSimulator(''plot'')');
        
        TuningSimulator('plot')         
    
    case 'ui_pb'
        s_step=1;
        l_step=10;
        pb_v=varargin{2};
        if pb_v==1
            v_T=v_T-s_step;
        elseif pb_v==2
            v_T=v_T-l_step;            
        elseif pb_v==3
            v_T=v_T+s_step;            
        elseif pb_v==4
            v_T=v_T+l_step;                        
        elseif pb_v==5
            v_M=v_M-s_step;            
        elseif pb_v==6
            v_M=v_M-l_step;                        
        elseif pb_v==7
            v_M=v_M+s_step;                        
        elseif pb_v==8
            v_M=v_M+l_step;                        
        end
        
        set(T_ui_T,'string',sprintf('%d',v_T));        
        set(T_ui_M,'string',sprintf('%d',v_M));        
   
        TuningSimulator('plot')        
        
    case 'plot'
        
        figure(fig1)
        
%        http://web.mit.edu/speclab/www/Facility/TIPS/tune.html => No longer available
        
       %% Parameters for interactions between Tuning and Matching
        T_ang = 5;
        % At T_ang = 0,tuning just change the frequency in the sweep mode.
        % To add some degree of interaction between tuning and matching,
        % set T_ang around 5.
        
        M_ang = 150;
        % At M_ang=90 (with obj_ang = 90), matching just change the depth in the sweep mode.
        % To consider the interaction between tune and match (i.e, the effect of matching to the frequency),
        % set M_ang around 150.
        
        % If you want to change the direction of matching for each simulation.        
        %         if M_ang_Quad == 0
        %             M_ang = M_ang;
        %         elseif M_ang_Quad == 1
        %             M_ang = (180-M_ang);
        %         elseif M_ang_Quad == 2
        %             M_ang = M_ang+180;
        %         elseif M_ang_Quad == 3
        %             M_ang = -M_ang;            
        %         end
                
       %% Center of the map
        x_p=x_p_ini+cosd(T_ang)*v_T+cosd(M_ang)*v_M;
        y_p=y_p_ini+sind(T_ang)*v_T+sind(M_ang)*v_M;
        
        x_p_vec=cat(1,x_p_vec,x_p);
        y_p_vec=cat(1,y_p_vec,y_p);
        
        %% Create the Tuning-Matching concave (z_mat)
        x_vec=[-size_no:1:size_no];
        y_vec=[-size_no:1:size_no];
        [x_mat,y_mat]=meshgrid(x_vec,y_vec);
        
        % 2D pseudo-Lorentzian
        % Shape parameters
        obj_ang=90;% Rotation of concave
        w1 = 8; % Width of Lorentzian along the impedance
        w2_cnst = 1.2;% Narrowest width of the wobble curve at the best matching condition
        w2_coef = 0.02;% If the impedance is far from the best matching condition, the wobble curve gets broader
        w2 = w2_cnst + w2_coef*abs(y_mat-y_p);% Broad Lorentzian at the offset matching condition
        z_mat=...
        -1./...,
            (w1*w2+...,
            (( cosd(obj_ang)*(x_mat-x_p)+sind(obj_ang)*(y_mat-y_p)).^2/w1^2)...,
            +(((-sind(obj_ang)*(x_mat-x_p)+cosd(obj_ang)*(y_mat-y_p)).^2)./w2.^2)...,
            );
            
       if init_switch==1
           max_z_mat=max(max(abs(z_mat)));
           % At the initial condition, the deepst part of the object is located somewhere in the range of x_mat and y_mat.
           % Use this deepest value for normalization
       end
       z_mat=z_mat/max_z_mat;% Normalization, range:[-1 0]
       z_mat=z_mat+1;% Offset, range:[0 1]
       
        %% 2D plot
        if get(ui_Check1,'Value')==1
            h1=subplot(2,2,1);
            contour(x_mat,y_mat,z_mat,[0:0.1:1])
            hold on
            plot(x_vec,zeros(size(x_vec)),'b')
            plot(zeros(size(y_vec)),y_vec,'k--')
            plot(x_p_vec,y_p_vec,'r')
            hold off
            xlim([-1 1]*size_no)
            ylim([-1 1]*size_no)
            title('Bring the deepest part to the center of the cross')
            set(gca,'ytick',[])
        else
            delete(h1);
        end

        
        %% Reflection, large scale

        min_z_mat2reflect=z_mat(size_no+1,size_no+1);
        if min_record >= min_z_mat2reflect 
            min_record = min_z_mat2reflect;
        end
        
        if get(ui_Check3,'Value')==1
            h3=subplot(2,2,3);
            plot([0 1],min_z_mat2reflect*[1 1],'-r')
            hold on
            plot([0 1],min_record*[1 1],'--c')
            plot([0 1],[0 0],'-k')
            hold off
            ylim([-0.1 1.1])
            title('Reflection (tunerp)')
            set(gca,'xtick',[])
        else
            delete(h3);
        end
        
        %% Reflection, small scale
        if get(ui_Check4,'Value')==1        
            h4=subplot(2,2,4);
            plot([0 1],min_z_mat2reflect*[1 1],'-r')
            hold on
            plot([0 1],min_record*[1 1],'--c')
            plot([0 1],[0 0],'-k')
            hold off
            ylim([-0.1 0.3])
            title('Reflection (tunerp)')
            set(gca,'xtick',[])
        else
            delete(h4);
        end
        
        %% Mtune
        if get(ui_Check2,'Value')==1
            h2=subplot(2,2,2);
            plot(x_vec,z_mat(size_no+1,:),'b')
            ylim([-1.1 0.1]+1)
            hold on
            plot([0 0],[-1.1 0.1]+1,'k--')
            plot(0,min_z_mat2reflect,'ro')
            plot(0,min_record,'co')            
            hold off
            xlim([-1 1]*size_no)
            title('Sweep mode (mtune)')
        else
            delete(h2);
        end

        %% Reflection value
        ui_offset_x1=850;
        ui_offset_y1=280;
        uicontrol('style','text','position',[260+ui_offset_x1 30+ui_offset_y1 40 20],'string',sprintf('%4.2f',min_z_mat2reflect),...
                  'horizontalalignment','left','BackgroundColor',[1 1 1]*1); 
                     
        ui_offset_x1=850;
        ui_offset_y1=300;
        uicontrol('style','text','position',[260+ui_offset_x1 30+ui_offset_y1 40 20],'string','Value',...
                 'horizontalalignment','left','BackgroundColor',[1 0 0]); 
                     
        ui_offset_x1=900;
        ui_offset_y1=280;
        uicontrol('style','text','position',[260+ui_offset_x1 30+ui_offset_y1 40 20],'string',sprintf('%4.2f',min_record),...
                  'horizontalalignment','left','BackgroundColor',[1 1 1]*1); 

        ui_offset_x1=900;
        ui_offset_y1=300;
        uicontrol('style','text','position',[260+ui_offset_x1 30+ui_offset_y1 40 20],'string','Min',...
                 'horizontalalignment','left','BackgroundColor',[0 1 1]); 
             
         %% Increase init_switch
         init_switch=init_switch+1;
                     
end