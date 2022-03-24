function Make_Patch_10(x,fC,freqname)

fclose('all');
%delete('Patch_10.aedt');
%delete('Patch_10.aedt.lock');
%delete('Patch_10.log');
%delete('Patch_10.vbs');

% Add paths to the required m-files.
hfssSetExePath;
tmpPrjFile = [pwd, '\Patch_10.aedt'];
tmpScriptFile = [pwd, '\Patch_10.vbs'];

% Frequency.
r2=3e8;
freqlist=fC;
freqlist=freqlist/1e9; %covert to GHz
er=4.4;% for FR4
Lambda = r2/fC(1)*1000;
decimalplaces=2;

% Array parameters.
% Substrate parameters.
%Hsub  = (30/1000)*0.0254; %30mil
% t1  = 30*0.0254; %30mil
% e1     =1.05;  %Foam substrate
% t2     =10.0;    %Foam's height

% t1=1.6; %mm FR4
% t2=0;%air
Hsub =0.8; %Total heigth of substrate
%Patch dimensions
% Lp    =49e-3;
% Wp    =55.1e-3;

% x=[120 2 9.1 4 14.5 6 1.75 90 3 3 90];

Wb=x(1);
Yb=x(11);
% L=x(1);
% W=x(2);
% r1=x(2);
% r2=x(3);
% r3=x(4);
% r4=x(5);
% r5=x(6);
% xf=x(7);
% yf=x(8);
% r6=x(9);
% Wk=x(10);

L=2.8*Wb;
lg=sqrt(Yb^2-(Wb/2)^2);
W=2.8*lg;

r1=x(2)*lg;
r2=x(3)*lg;
r3=x(4)*lg;
r4=x(5)*lg;
r5=x(6)*lg;
xf=x(7);  
yf=x(8)*L;  
r6=x(9)*lg;
Wk=x(10);   


Wb=RoundNew(Wb,decimalplaces);
r1=RoundNew(r1,decimalplaces);
r2=RoundNew(r2,decimalplaces);
r3=RoundNew(r3,decimalplaces);
r4=RoundNew(r4,decimalplaces);
r5=RoundNew(r5,decimalplaces);
xf=RoundNew(xf,decimalplaces);
yf=RoundNew(yf,decimalplaces);
r6=RoundNew(r6,decimalplaces);
Wk=RoundNew(Wk,decimalplaces);
Yb=RoundNew(Yb,decimalplaces);
L=RoundNew(L,decimalplaces);
W=RoundNew(W,decimalplaces);

% Open a temporary script file.
fid = fopen(tmpScriptFile, 'wt');

% Create a new HFSS project.
hfssNewProject(fid);
hfssInsertDesign(fid, freqname);

%Set model units to mm
hfssSetUnit(fid, 'mm');

%Draw the feed
hfssRectangle(fid, 'Feed', 'Z', [(W+r1)/2, 0, 0], xf ,yf , 'mm');

leg=sqrt(Yb^2-(Wb/2)^2);
%Draw Triangle 
hfssPolygon(fid, 'Triangle', [(W+r1)/2+xf, yf, 0; ...
                              (W+r1)/2+xf-leg, yf+Wb/2, 0;   ...
                              (W+r1)/2+xf-leg, yf-Wb/2, 0;  ...
                              (W+r1)/2+xf, yf, 0], ...
                               'mm')
%Draw slots
% hfssRectangle(fid, 'Slot1', 'Z', [(W+r1)/2+xf-r1, yf+(Wb/60), 0], -Wk ,Wb/2 , 'mm');
% hfssRectangle(fid, 'Slot2', 'Z', [(W+r1)/2+xf-r1-Wk-r2, yf+(Wb/60), 0], -Wk ,Wb/2 , 'mm');
% hfssRectangle(fid, 'Slot3', 'Z', [(W+r1)/2+xf-r1-2*Wk-r2-r3, yf+(Wb/60), 0], -Wk ,Wb/2 , 'mm');
% hfssRectangle(fid, 'Slot4', 'Z', [(W+r1)/2+xf-r4, yf-(Wb/60), 0], -Wk ,-Wb/2 , 'mm');
% hfssRectangle(fid, 'Slot5', 'Z', [(W+r1)/2+xf-r4-Wk-r5, yf-(Wb/60), 0], -Wk ,-Wb/2 , 'mm');
% hfssRectangle(fid, 'Slot6', 'Z', [(W+r1)/2+xf-r4-2*Wk-r5-r6, yf-(Wb/60), 0], -Wk ,-Wb/2 , 'mm');

%Subtract
% hfssSubtract(fid, {'Triangle'}, {'Slot1', 'Slot2', 'Slot3', 'Slot4', 'Slot5', 'Slot6'});
%hfssUnite(fid, {'Triangle','Feed'});
% 
% %Mirror
% hfssDuplicateMirror(fid, {'Triangle'}, [W/2, 0, 0], [2, 0, 0], 'mm');
% hfssMove(fid, {'Triangle_1'}, [-r1, -yf*0.4/4.5, -Hsub], 'mm');
% hfssRectangle(fid, 'Cut', 'Z', [0, 0, -Hsub], W ,-L , 'mm');
% hfssSubtract(fid, {'Triangle_1'}, {'Cut'});
% 
% hfssUnite(fid, {'Triangle','Triangle_1'});
% hfssSetColor(fid, 'Triangle', [255 , 128, 0]);
% hfssSetTransparency(fid, {'Triangle'} , 0);
% hfssAssignFiniteCondNew(fid,'FiniteCond', 'Triangle', 'copper',  0);
% 
% %Draw the substrate
% hfssBox(fid, 'FR4', [0, 0, 0], [W, L, -Hsub], 'mm');
% hfssAssignMaterial(fid, 'FR4', 'FR4_Epoxy');
% hfssSetColor(fid, 'FR4', [140, 128, 179]);
% hfssSetTransparency(fid, {'FR4'}, 0.7);

% Draw radiation boundaries.
% hfssBox(fid, 'AirBox', [-Lambda,-Lambda, Lambda], ...
%     [2*Lambda+W,2*Lambda+L,-2*Lambda-Hsub], 'mm'); 
% hfssAssignRadiation(fid, 'ABC', 'AirBox');
% hfssSetTransparency(fid, {'AirBox'}, 0.95);
% 
% %Draw a wave port for the patch.
% hfssPolygon(fid, 'Port', [W/2-1.5*r1-xf, 0, -Hsub; ...
%                           W/2-1.5*r1, 0, -Hsub;   ...
%                           (W+r1)/2+xf, 0, 0;  ...
%                           (W+r1)/2, 0, 0;  ...
%                           W/2-1.5*r1-xf, 0, -Hsub], ...
%                                'mm')
% hfssAssignLumpedPort(fid, 'Port1', 'Port', [W/2-1.5*r1-xf/2, 0, -Hsub], ...
%   	[(W+r1)/2+xf/2, 0, 0], 'mm');
% 
% 
% setupstr1=['Setup',int2str(freqlist(1)*1000),'MHz'];
% % setupstr2=['Setup',int2str(freqlist(2)*1000),'MHz'];
% % setupstr3=['Setup',int2str(freqlist(3)*1000),'MHz'];
% % Insert solution and sweep.
% hfssInsertSolution(fid, setupstr1, fC(1)/1e9);
% % hfssInsertSolution(fid, setupstr2, fC(2)/1e9);
% % hfssInsertSolution(fid, setupstr3, fC(3)/1e9);
% 
% 
% hfssDiscreteSweep(fid, 'Dicrete1', setupstr1, freqlist);
% hfssSolveSetup(fid, setupstr1);
% % hfssSolveSetup(fid, setupstr2);
% % hfssSolveSetup(fid, setupstr3);
% 
% 
% hfssCreateReport(fid, 'Return Loss', 1, 1, setupstr1, 'Dicrete1',...
%                      [], 'Sweep', {'Freq'}, {'Freq',...
%                       'dB(S(Port1,Port1))'});                 
% hfssCreateReport(fid, 'VSWR', 1, 1, setupstr1, 'Dicrete1',...
%                  [], 'Sweep', {'Freq'}, {'Freq',...
%                   'VSWR(Port1)'});
% 
% hfssInsertFarFieldSphereSetup(fid, 'Radiation',[0, 180, 10],[-90, 90, 2]);
% 
% 
%                   
% hfssExportToFile(fid, 'Return Loss', 'SParams', 'txt'); % Saves in the same dir.
% hfssExportToFile(fid, 'VSWR', 'VSWR', 'txt'); % Saves in the same dir.
% hfssExportRadiationParametersToFile(fid,'AntParams.txt','Radiation',setupstr1,fC(1)/1e9);
% % hfssExportRadiationParametersToFile(fid,'AntParams2.txt','Radiation',setupstr2,fC(2)/1e9);
% % hfssExportRadiationParametersToFile(fid,'AntParams3.txt','Radiation',setupstr3,fC(3)/1e9);
% 
% 
%  % Save project and close file.
% hfssSaveProject(fid, tmpPrjFile, true);


fclose(fid);
% Open HFSS executing the script.
hfssExecuteScript(hfssExePath, tmpScriptFile, true, false);

end