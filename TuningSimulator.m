% ------------------------------------------------------------------------
% File Name   : TuningSimulator.m
% Description : Training Simulator to tune and match an NMR probe.
% Requirement : MATLAB
% Developer   : Dr. Kosuke Ohgo
% ULR         : https://github.com/ohgo1977/TuningSimulator
% Version     : 1.1.0
%
% Please read the manual (README_TuningSimulator.pdf) for details.
%
% ------------------------------------------------------------------------
%
% MIT License
%
% Copyright (c) 2025 Kosuke Ohgo
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
%
% Revision Information
% Version 1.1.0
% December 17, 2025
% - Introducing fig.UserData to replace all global parameters used in the previous 1.0.0. 
%
% Version 1.0.0
% September 11, 2021
% - Initial Submission

if nargin==0
    action='initialize';
else
    action=varargin{end};
end

switch action
    case 'initialize'
        close all
   
        fig=figure;
        set(fig,'position',[1    41   1366   651])

        %% Initial parameters
        fig.UserData.init_switch=1;
        fig.UserData.size_no=180;
        fig.UserData.x_p_ini=(rand-0.5)*2*fig.UserData.size_no;%x_p: somewhere in [-fig.UserData.size_no -fig.UserData.size_no], rand: [0 1] => (rand-0.5)*2: [-1 1]
        fig.UserData.y_p_ini=(rand-0.5)*2*fig.UserData.size_no;%y_p: somewhere in [-fig.UserData.size_no -fig.UserData.size_no], rand: [0 1] => (rand-0.5)*2: [-1 1]
        fig.UserData.x_p_vec=[];
        fig.UserData.y_p_vec=[];
        fig.UserData.min_record=1;
        fig.UserData.M_ang_Quad=floor(4*rand);%randm number from [0 1 2 3]
        fig.UserData.v_T=0;
        fig.UserData.v_M=0;
        
        
        %% Setup UI
        %% Pushbutton for Tuning
        ui_offset_x1=80;ui_offset_y1=0;
        uicontrol('style','text','position',[100+ui_offset_x1 50+ui_offset_y1 50 20],'string','Tuning','horizontalalignment','left','BackgroundColor',[0.8 0.8 0.8]); 
        fig.UserData.ui_T_ls=uicontrol('style','pushbutto','position',[200+ui_offset_x1 35+ui_offset_y1 30 30],...
        'string','<','callback',{@TuningSimulator,1,'ui_pb'});

        ui_offset_x1=80;ui_offset_y1=-35;
        fig.UserData.ui_T_ll=uicontrol('style','pushbutto','position',[200+ui_offset_x1 35+ui_offset_y1 30 30],...
        'string','<<','callback',{@TuningSimulator,2,'ui_pb'});
    
        ui_offset_x1=160;ui_offset_y1=0;
        fig.UserData.ui_T_rs=uicontrol('style','pushbutto','position',[200+ui_offset_x1 35+ui_offset_y1 30 30],...
        'string','>','callback',{@TuningSimulator,3,'ui_pb'});

        ui_offset_x1=160;ui_offset_y1=-35;
        fig.UserData.ui_T_rl=uicontrol('style','pushbutto','position',[200+ui_offset_x1 35+ui_offset_y1 30 30],...
        'string','>>','callback',{@TuningSimulator,4,'ui_pb'});
    
        ui_offset_x1=mean([80 160]);
        ui_offset_y1=0;
        fig.UserData.T_ui_T=uicontrol('style','text','position',[200+ui_offset_x1 35+ui_offset_y1 30 30],'string',sprintf('%d',fig.UserData.v_T),...
                  'horizontalalignment','right','BackgroundColor',[1 1 1]*1);    
    
       %% Refreshing      
        ui_offset_x1=600;ui_offset_y1=0;
        uicontrol('style','pushbutto','position',[200+ui_offset_x1 35+ui_offset_y1 100 30],...
        'string','Refresh','callback',{@TuningSimulator,'initialize'});
    
        %% Pushbutton for Matching
        ui_offset_x2=300;
        ui_offset_x1=80+ui_offset_x2;ui_offset_y1=0;
        uicontrol('style','text','position',[100+ui_offset_x1 50+ui_offset_y1 50 20],'string','Matching','horizontalalignment','left','BackgroundColor',[0.8 0.8 0.8]); 
        fig.UserData.ui_M_ls=uicontrol('style','pushbutto','position',[200+ui_offset_x1 35+ui_offset_y1 30 30],...
        'string','<','callback',{@TuningSimulator,5,'ui_pb'});

        ui_offset_x1=80+ui_offset_x2;ui_offset_y1=-35;
        fig.UserData.ui_M_ll=uicontrol('style','pushbutto','position',[200+ui_offset_x1 35+ui_offset_y1 30 30],...
        'string','<<','callback',{@TuningSimulator,6,'ui_pb'});
    
        ui_offset_x1=160+ui_offset_x2;ui_offset_y1=0;
        fig.UserData.ui_M_rs=uicontrol('style','pushbutto','position',[200+ui_offset_x1 35+ui_offset_y1 30 30],...
        'string','>','callback',{@TuningSimulator,7,'ui_pb'});

        ui_offset_x1=160+ui_offset_x2;ui_offset_y1=-35;
        fig.UserData.ui_M_rl=uicontrol('style','pushbutto','position',[200+ui_offset_x1 35+ui_offset_y1 30 30],...
        'string','>>','callback',{@TuningSimulator,8,'ui_pb'});
    
        ui_offset_x1=mean([80 160])+ui_offset_x2;
        ui_offset_y1=0;
        fig.UserData.T_ui_M=uicontrol('style','text','position',[200+ui_offset_x1 35+ui_offset_y1 30 30],'string',sprintf('%d',fig.UserData.v_M),...
                  'horizontalalignment','right','BackgroundColor',[1 1 1]*1);   
        
       %% Checkbox1
        ui_offset_x1=200;ui_offset_y1=600;
        fig.UserData.ui_Check1=uicontrol('style','checkbox','position',[ui_offset_x1 5+ui_offset_y1 20 20],...
        'Value',1','callback',{@TuningSimulator,'plot'});
        
        %% Checkbox2
        ui_offset_x1=800;ui_offset_y1=600;
        fig.UserData.ui_Check2=uicontrol('style','checkbox','position',[ui_offset_x1 5+ui_offset_y1 20 20],...
        'Value',1','callback',{@TuningSimulator,'plot'});

        %% Checkbox3        
        ui_offset_x1=200;ui_offset_y1=300;
        fig.UserData.ui_Check3=uicontrol('style','checkbox','position',[ui_offset_x1 5+ui_offset_y1 20 20],...
        'Value',1','callback',{@TuningSimulator,'plot'});

        %% Checkbox4            
        ui_offset_x1=800;ui_offset_y1=300;
        fig.UserData.ui_Check4=uicontrol('style','checkbox','position',[ui_offset_x1 5+ui_offset_y1 20 20],...
        'Value',1','callback',{@TuningSimulator,'plot'});
        
        TuningSimulator(fig,'plot')         
    
    case 'ui_pb'
        % The 1st input argument from the callback is src. 
        fig=ancestor(varargin{1},"figure","toplevel");
        s_step=1;
        l_step=10;
        pb_v=varargin{end-1};

        if pb_v==1
            fig.UserData.v_T=fig.UserData.v_T-s_step;
        elseif pb_v==2
            fig.UserData.v_T=fig.UserData.v_T-l_step;            
        elseif pb_v==3
            fig.UserData.v_T=fig.UserData.v_T+s_step;            
        elseif pb_v==4
            fig.UserData.v_T=fig.UserData.v_T+l_step;                        
        elseif pb_v==5
            fig.UserData.v_M=fig.UserData.v_M-s_step;            
        elseif pb_v==6
            fig.UserData.v_M=fig.UserData.v_M-l_step;                        
        elseif pb_v==7
            fig.UserData.v_M=fig.UserData.v_M+s_step;                        
        elseif pb_v==8
            fig.UserData.v_M=fig.UserData.v_M+l_step;                        
        end
        
        set(fig.UserData.T_ui_T,'string',sprintf('%d',fig.UserData.v_T));        
        set(fig.UserData.T_ui_M,'string',sprintf('%d',fig.UserData.v_M));        
   
        TuningSimulator(fig,'plot')        

        
    case 'plot'
        % The 1st input argument from the callback is src.
        % If src is fig, ancestor() returns fig.
        % Thus, this branch can be used as a function and a callback-function.
        fig=ancestor(varargin{1},"figure","toplevel");

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
        %         if fig.UserData.M_ang_Quad == 0
        %             M_ang = M_ang;
        %         elseif fig.UserData.M_ang_Quad == 1
        %             M_ang = (180-M_ang);
        %         elseif fig.UserData.M_ang_Quad == 2
        %             M_ang = M_ang+180;
        %         elseif fig.UserData.M_ang_Quad == 3
        %             M_ang = -M_ang;            
        %         end
                
       %% Center of the map
        x_p=fig.UserData.x_p_ini+cosd(T_ang)*fig.UserData.v_T+cosd(M_ang)*fig.UserData.v_M;
        y_p=fig.UserData.y_p_ini+sind(T_ang)*fig.UserData.v_T+sind(M_ang)*fig.UserData.v_M;
        
        fig.UserData.x_p_vec=cat(1,fig.UserData.x_p_vec,x_p);
        fig.UserData.y_p_vec=cat(1,fig.UserData.y_p_vec,y_p);
        
        %% Create the Tuning-Matching concave (z_mat)
        x_vec=[-fig.UserData.size_no:1:fig.UserData.size_no];
        y_vec=[-fig.UserData.size_no:1:fig.UserData.size_no];
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
            
       if fig.UserData.init_switch==1
           fig.UserData.max_z_mat=max(max(abs(z_mat)));
           % At the initial condition, the deepst part of the object is located somewhere in the range of x_mat and y_mat.
           % Use this deepest value for normalization
       end
       z_mat=z_mat/fig.UserData.max_z_mat;% Normalization, range:[-1 0]
       z_mat=z_mat+1;% Offset, range:[0 1]
       
        %% 2D plot
        if get(fig.UserData.ui_Check1,'Value')==1
            fig.UserData.h1=subplot(2,2,1);
            contour(x_mat,y_mat,z_mat,[0:0.1:1])
            hold on
            plot(x_vec,zeros(size(x_vec)),'b')
            plot(zeros(size(y_vec)),y_vec,'k--')
            plot(fig.UserData.x_p_vec,fig.UserData.y_p_vec,'r')
            hold off
            xlim([-1 1]*fig.UserData.size_no)
            ylim([-1 1]*fig.UserData.size_no)
            title('Bring the deepest part to the center of the cross')
            set(gca,'ytick',[])
        else
            delete(fig.UserData.h1);
        end

        
        %% Reflection, large scale
        min_z_mat2reflect=z_mat(fig.UserData.size_no+1,fig.UserData.size_no+1);
        if fig.UserData.min_record >= min_z_mat2reflect 
            fig.UserData.min_record = min_z_mat2reflect;
        end
        
        if get(fig.UserData.ui_Check3,'Value')==1
            fig.UserData.h3=subplot(2,2,3);
            plot([0 1],min_z_mat2reflect*[1 1],'-r')
            hold on
            plot([0 1],fig.UserData.min_record*[1 1],'--c')
            plot([0 1],[0 0],'-k')
            hold off
            ylim([-0.1 1.1])
            title('Reflection (tunerp)')
            set(gca,'xtick',[])
        else
            delete(fig.UserData.h3);
        end
        
        %% Reflection, small scale
        if get(fig.UserData.ui_Check4,'Value')==1        
            fig.UserData.h4=subplot(2,2,4);
            plot([0 1],min_z_mat2reflect*[1 1],'-r')
            hold on
            plot([0 1],fig.UserData.min_record*[1 1],'--c')
            plot([0 1],[0 0],'-k')
            hold off
            ylim([-0.1 0.3])
            title('Reflection (tunerp)')
            set(gca,'xtick',[])
        else
            delete(fig.UserData.h4);
        end
        
        %% Mtune
        if get(fig.UserData.ui_Check2,'Value')==1
            fig.UserData.h2=subplot(2,2,2);
            plot(x_vec,z_mat(fig.UserData.size_no+1,:),'b')
            ylim([-1.1 0.1]+1)
            hold on
            plot([0 0],[-1.1 0.1]+1,'k--')
            plot(0,min_z_mat2reflect,'ro')
            plot(0,fig.UserData.min_record,'co')            
            hold off
            xlim([-1 1]*fig.UserData.size_no)
            title('Sweep mode (mtune)')
        else
            delete(fig.UserData.h2);
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
        uicontrol('style','text','position',[260+ui_offset_x1 30+ui_offset_y1 40 20],'string',sprintf('%4.2f',fig.UserData.min_record),...
                  'horizontalalignment','left','BackgroundColor',[1 1 1]*1); 

        ui_offset_x1=900;
        ui_offset_y1=300;
        uicontrol('style','text','position',[260+ui_offset_x1 30+ui_offset_y1 40 20],'string','Min',...
                 'horizontalalignment','left','BackgroundColor',[0 1 1]); 
             
         %% Increase fig.UserData.init_switch
         fig.UserData.init_switch=fig.UserData.init_switch+1;
                     
end