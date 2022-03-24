function Make_Patch_5_best

fC = [868e6 1800e6 2100e6];
freqlist=fC;
freqlist=freqlist/1e9; %covert to GHz
freqname=['Patch_5_',int2str(freqlist(1)*1000),'MHz_',int2str(freqlist(2)*1000),'MHz_',int2str(freqlist(3)*1000),'MHz_'];


% Add paths to the required m-files.
hfssSetExePath;
tmpPrjFile = [pwd, '\Patch_5.aedt'];
tmpScriptFile = [pwd, '\Patch_5.vbs'];

% Frequency.
c=3e8;
freqlist=fC;
freqlist=freqlist/1e9; %covert to GHz
er=4.4;% for FR4
Lambda = c/fC(1)*1000;
decimalplaces=2;

% Array parameters.
% Substrate parameters.
%Hsub  = (30/1000)*0.0254; %30mil
% t1  = 30*0.0254; %30mil
% e1     =1.05;  %Foam substrate
% t2     =10.0;    %Foam's height

t1=1.6; %mm FR4
t2=0;%air
Hsub =t1+t2; %Total heigth of substrate

%Patch dimensions
x=[34.037960, 93.348576, 0.100622, 0.381007, 0.249967, 0.215435, 0.068232, 0.213846, 0.923876, 0.095476, 0.055496];
W=x(1);
L=x(2);
% 
% Wsub=2.8*W;
% Lsub=2.8*L;
% 
% Wf=x(3);
% Lf=x(4);
% 
% R1=x(5);
% R2=x(6);
% R3=x(7);
% R4=x(8);
% 
% Lg=x(9);
% L1=x(10);
% L2=x(11);

Wf=x(3)*W;
Lf=x(4)*L;

R1=x(5)*W;
R2=x(6)*W;
R3=x(7)*W;
R4=x(8)*W;

Lg=x(9)*Lf;

L1=x(10)*Lf;
L2=x(11)*Lf;

Wsub=2*W;
Lsub=(L+Lf)*1.5;

W=RoundNew(W,decimalplaces);
L=RoundNew(L,decimalplaces);
Wf=RoundNew(Wf,decimalplaces);
Lf=RoundNew(Lf,decimalplaces);

R1=RoundNew(R1,decimalplaces);
R2=RoundNew(R2,decimalplaces);
R3=RoundNew(R3,decimalplaces);
R4=RoundNew(R4,decimalplaces);

Lg=RoundNew(Lg,decimalplaces);
L1=RoundNew(L1,decimalplaces);
L2=RoundNew(L2,decimalplaces);


Wsub=RoundNew(Wsub,decimalplaces);
Lsub=RoundNew(Lsub,decimalplaces);
% Open a temporary script file.
fid = fopen(tmpScriptFile, 'wt');

% Create a new HFSS project.
hfssNewProject(fid);
hfssInsertDesign(fid, freqname);

%Set model units to mm
hfssSetUnit(fid, 'mm');


%Draw the patch
hfssRectangle(fid, 'Patch', 'Z', [Wsub/2-W/2, Lf, 0], W, L, 'mm');

%Draw the feed
hfssRectangle(fid, 'Feed', 'Z', [Wsub/2-Wf/2, 0, 0], Wf ,Lf , 'mm');

hfssUnite(fid, {'Patch','Feed'});

%Circles
hfssCircle(fid, 'Circle1', 'Z', [Wsub/2-W/2, Lf+L, 0], R1, 'mm');
hfssCircle(fid, 'Circle2', 'Z', [Wsub/2+W/2, Lf+L, 0], R2, 'mm');
hfssCircle(fid, 'Circle3', 'Z', [Wsub/2-W/2, Lf, 0], R3, 'mm');
hfssCircle(fid, 'Circle4', 'Z', [Wsub/2+W/2, Lf, 0], R4, 'mm');

%Subtract
hfssSubtract(fid, {'Patch'}, {'Circle1','Circle2','Circle3','Circle4'});

hfssSetColor(fid, 'Patch', [255 , 128, 0]);
hfssSetTransparency(fid, {'Patch'} , 0);
hfssAssignFiniteCondNew(fid,'FiniteCond1', 'Patch', 'copper',  0);

%Triangle
hfssPolygon(fid, 'Triangle', [Wsub/2-Wf/2, Lg, -Hsub; ...
                               Wsub/2-Wf/2, Lg-L2, -Hsub;   ...
                               Wsub/2, Lg-L1-L2, -Hsub;  ...
                               Wsub/2+Wf/2, Lg-L2, -Hsub;
                               Wsub/2+Wf/2,Lg, -Hsub;
                               Wsub/2-Wf/2, Lg, -Hsub], ...
                               'mm')



% Draw a ground plane.
hfssRectangle(fid, 'GroundPlane', 'Z', [0, 0, -Hsub], Wsub ,Lg , 'mm');

%Subtract
hfssSubtract(fid, {'GroundPlane'}, {'Triangle'});

hfssSetColor(fid, 'Patch', [255 , 128, 0]);
hfssSetTransparency(fid, {'GroundPlane'}, 0);
hfssAssignFiniteCondNew(fid,'FiniteCond2', 'GroundPlane', 'copper',  0);

%Draw the substrate
hfssBox(fid, 'FR4', [0, 0, 0], [Wsub, Lsub, -Hsub], 'mm');
hfssAssignMaterial(fid, 'FR4', 'FR4_Epoxy');
hfssSetColor(fid, 'FR4', [140, 128, 179]);
hfssSetTransparency(fid, {'FR4'}, 0.6);

% Draw radiation boundaries.
hfssBox(fid, 'AirBox', [-Lambda,-Lambda, Lambda], ...
    [2*Lambda+Wsub,2*Lambda+Lsub,-2*Lambda-Hsub], 'mm'); 
hfssAssignRadiation(fid, 'ABC', 'AirBox');
hfssSetTransparency(fid, {'AirBox'}, 0.95);


%Draw a wave port for the patch.
hfssRectangle(fid, 'Port', 'Y', [Wsub/2-Wf/2, 0, 0], -Hsub, Wf,...
     'mm');
hfssAssignLumpedPort(fid, 'Port1', 'Port', [Wsub/2, 0, -Hsub], ...
  	[Wsub/2, 0, 0], 'mm');


setupstr1=['Setup',int2str(freqlist(1)*1000),'MHz'];
setupstr2=['Setup',int2str(freqlist(2)*1000),'MHz'];
setupstr3=['Setup',int2str(freqlist(3)*1000),'MHz'];
% Insert solution and sweep.
hfssInsertSolution(fid, setupstr1, fC(1)/1e9);
hfssInsertSolution(fid, setupstr2, fC(2)/1e9);
hfssInsertSolution(fid, setupstr3, fC(3)/1e9);


hfssInterpolatingSweep(fid, 'InterpolatingSweep1', setupstr1, 0.5, 3, 2000, 101, 0.5)
hfssSolveSetup(fid, setupstr1);
hfssSolveSetup(fid, setupstr2);
hfssSolveSetup(fid, setupstr3);


hfssCreateReport(fid, 'Return Loss', 1, 1, setupstr1, 'InterpolatingSweep1',...
                     [], 'Sweep', {'Freq'}, {'Freq',...
                      'dB(S(Port1,Port1))'});                 
hfssCreateReport(fid, 'VSWR', 1, 1, setupstr1, 'InterpolatingSweep1',...
                 [], 'Sweep', {'Freq'}, {'Freq',...
                  'VSWR(Port1)'});

hfssInsertFarFieldSphereSetup(fid, 'Radiation',[0, 180, 10],[-90, 90, 2]);


                  
hfssExportToFile(fid, 'Return Loss', 'SParams', 'txt'); % Saves in the same dir.
hfssExportToFile(fid, 'VSWR', 'VSWR', 'txt'); % Saves in the same dir.
hfssExportRadiationParametersToFile(fid,'AntParams.txt','Radiation',setupstr1,fC(1)/1e9);
hfssExportRadiationParametersToFile(fid,'AntParams2.txt','Radiation',setupstr2,fC(2)/1e9);
hfssExportRadiationParametersToFile(fid,'AntParams3.txt','Radiation',setupstr3,fC(3)/1e9);


 % Save project and close file.
hfssSaveProject(fid, tmpPrjFile, true);


fclose(fid);
% Open HFSS executing the script.
hfssExecuteScript(hfssExePath, tmpScriptFile, true, false);

end