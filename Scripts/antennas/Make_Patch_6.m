function Make_Patch_6(x,fC,freqname)

% fclose('all');
%delete('Patch_6.aedt');
%delete('Patch_6.aedt.lock');
%delete('Patch_6.log');
%delete('Patch_6.vbs');

% Add paths to the required m-files.
hfssSetExePath;
tmpPrjFile = [pwd, '\Patch_6.aedt'];
tmpScriptFile = [pwd, '\Patch_6.vbs'];

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

% t1=1.6; %mm FR4
% t2=0;%air
Hsub =1.6; %Total heigth of substrate
%Patch dimensions
% Lp    =49e-3;
% Wp    =55.1e-3;

% x=[50 58 25.65 20.65 19    7 6 7.5 7.5   4 5 12    3 3 1.5 16.15   10.58 3.62  10.96 9.19 10.42 4.27 10.8 5.74 15.4 17.25 2.47 2];

W=x(1);
L=x(2);
Wg1=x(3)*W;
Wg2=x(4)*W;
Lg=x(5)*L;
t1=x(6)*L;
t2=x(7)*W;
t3=x(8)*L;
t4=x(9)*W;
s1=x(10)*L;
s2=x(11)*W;
s3=x(12)*Wg1;
Wf=x(13)*W;
Lf=x(14)*Lg;
Wf1=x(15)*W;
Lf1=x(16)*Lg;
W1=x(17)*W;
L1=x(18)*L;
W3=x(19)*W;
W2=x(20)*W;
L2=x(21)*L;
L3=x(22)*L;
L4=x(23)*L;
L5=x(24)*L;
L6=x(25)*L;
W4=x(26)*W;
W5=x(27)*W;
W6=x(28)*W;

% Wg1=x(3);
% Wg2=x(4);
% Lg=x(5);
% 
% t1=x(6);
% t2=x(7);
% t3=x(8);
% t4=x(9);
% 
% s1=x(10);
% s2=x(11);
% s3=x(12);
% 
% Wf=x(13);
% Lf=x(14);
% Wf1=x(15);
% Lf1=x(16);
% 
% W1=x(17);
% L1=x(18);
% 
% W3=x(19);
% W2=x(20);
% L2=x(21);
% L3=x(22);
% L4=x(23);
% L5=x(24);
% L6=x(25);
% W4=x(26);
% W5=x(27);
% W6=x(28);

W=RoundNew(W,decimalplaces);
L=RoundNew(L,decimalplaces);
Wg1=RoundNew(Wg1,decimalplaces);
Wg2=RoundNew(Wg2,decimalplaces);
Lg=RoundNew(Lg,decimalplaces);
t1=RoundNew(t1,decimalplaces);
t2=RoundNew(t2,decimalplaces);
t3=RoundNew(t3,decimalplaces);
t4=RoundNew(t4,decimalplaces);
s1=RoundNew(s1,decimalplaces);
s2=RoundNew(s2,decimalplaces);
s3=RoundNew(s3,decimalplaces);
Wf=RoundNew(Wf,decimalplaces);
Lf=RoundNew(Lf,decimalplaces);
Wf1=RoundNew(Wf1,decimalplaces);
Lf1=RoundNew(Lf1,decimalplaces);

W1=RoundNew(W1,decimalplaces);
L1=RoundNew(L1,decimalplaces);
W3=RoundNew(W3,decimalplaces);
W2=RoundNew(W2,decimalplaces);
L2=RoundNew(L2,decimalplaces);
L3=RoundNew(L3,decimalplaces);
L4=RoundNew(L4,decimalplaces);
L5=RoundNew(L5,decimalplaces);
L6=RoundNew(L6,decimalplaces);
W4=RoundNew(W4,decimalplaces);
W5=RoundNew(W5,decimalplaces);
W6=RoundNew(W6,decimalplaces);

% Open a temporary script file.
fid = fopen(tmpScriptFile, 'wt');

% Create a new HFSS project.
hfssNewProject(fid);
hfssInsertDesign(fid, freqname);

%Set model units to mm
hfssSetUnit(fid, 'mm');


%Draw the patch G1
hfssRectangle(fid, 'Patch1', 'Z', [0, 0, 0], Wg1, Lg, 'mm');
%Draw the patch G2
hfssRectangle(fid, 'Patch2', 'Z', [W-Wg2, 0, 0], Wg2, Lg, 'mm');
%Draw Triangle 1
hfssPolygon(fid, 'Triangle1', [0, Lg, 0; ...
                               0, Lg+t3, 0;   ...
                               t4, Lg, 0;  ...
                               0, Lg, 0], ...
                               'mm')
%Draw Triangle 2
hfssPolygon(fid, 'Triangle2', [W-t2, Lg, 0; ...
                               W-t2, Lg+t1, 0;   ...
                               W, Lg, 0;  ...
                               W-t2, Lg, 0], ...
                               'mm')   
                           
%Draw Patch S
hfssRectangle(fid, 'PatchS', 'Z', [s3, Lg, 0], s2, -s1, 'mm');

%Subtract
hfssSubtract(fid, {'Patch1'},{'PatchS'});

                    
%Draw the feed
hfssRectangle(fid, 'Feed1', 'Z', [Wg1+(W-Wg1-Wg2-Wf)/2, 0, 0], Wf ,Lf , 'mm');
hfssRectangle(fid, 'Feed2', 'Z', [Wg1+(W-Wg1-Wg2-Wf1)/2, Lf, 0], Wf1 ,Lf1 , 'mm');

%Unite
hfssUnite(fid,{'Patch1','Patch2','Triangle1','Triangle2','Feed1','Feed2'});

%E-shaped patch
hfssRectangle(fid, 'E1', 'Z', [0, 0, 0], W1 ,L1 , 'mm');
hfssRectangle(fid, 'E2', 'Z', [0, L1, 0], L5+W3-W2 ,L2 , 'mm');
hfssRectangle(fid, 'E3', 'Z', [L5+W3-W2, L1+L2, 0], W2 ,-L3 , 'mm');

hfssRectangle(fid, 'E4', 'Z', [0, L1+L2, 0], L5 ,L6 , 'mm');
hfssRectangle(fid, 'E5', 'Z', [L5, L1+L2+L6, 0], W4 ,L4-L6 , 'mm');
hfssRectangle(fid, 'E6', 'Z', [L5+W4, L1+L2+L6, 0], W5 ,-W6 , 'mm');

hfssUnite(fid,{'E1','E2','E3','E4','E5','E6'});

hfssRotate(fid, {'E1'},'Z', 45);
hfssMove(fid, {'E1'}, [Wg1+(W-Wg1-Wg2)/2, Lf1+Lf-0.65*Wf1, 0], 'mm');

hfssUnite(fid,{'Patch1','E1'});
       
hfssSetColor(fid, 'Patch1', [255 , 128, 0]);
hfssSetTransparency(fid, {'Patch1'} , 0);
hfssAssignFiniteCondNew(fid,'FiniteCond1', 'Patch1', 'copper',  0);

% Draw a ground plane.
% hfssRectangle(fid, 'GroundPlane', 'Z', [0, 0, -Hsub],W ,L , 'mm');
% hfssSetTransparency(fid, {'GroundPlane'}, 0);
% hfssAssignFiniteCondNew(fid,'FiniteCond2', 'GroundPlane', 'copper',  0);


%Draw the substrate
hfssBox(fid, 'FR4', [0, 0, 0], [W, L, -Hsub], 'mm');
hfssAssignMaterial(fid, 'FR4', 'FR4_Epoxy');
hfssSetColor(fid, 'FR4', [140, 128, 179]);
hfssSetTransparency(fid, {'FR4'}, 0.6);

% Draw radiation boundaries.
hfssBox(fid, 'AirBox', [-Lambda,0, Lambda], ...
    [2*Lambda+W,Lambda+L,-2*Lambda-Hsub], 'mm'); 
hfssAssignRadiation(fid, 'ABC', 'AirBox');
hfssSetTransparency(fid, {'AirBox'}, 0.95);


%Draw a wave port for the patch.
hfssRectangle(fid, 'Port', 'Y', [Wg1, 0, -Hsub], 2*Hsub, W-Wg1-Wg2,...
     'mm');
hfssAssignWavePortNew(fid, 'Port1', 'Port', 1, false, [W/2, 0, -Hsub], [W/2, 0, 7*Hsub], 'mm');



setupstr1=['Setup',int2str(freqlist(1)*1000),'MHz'];
% setupstr2=['Setup',int2str(freqlist(2)*1000),'MHz'];
% setupstr3=['Setup',int2str(freqlist(3)*1000),'MHz'];
% Insert solution and sweep.
hfssInsertSolution(fid, setupstr1, fC(1)/1e9);
% hfssInsertSolution(fid, setupstr2, fC(2)/1e9);
% hfssInsertSolution(fid, setupstr3, fC(3)/1e9);

% hfssInterpolatingSweep(fid, 'InterpolatingSweep1', setupstr1, 1, 8, 1000, 101, 0.5)
hfssDiscreteSweep(fid, 'Dicrete1', setupstr1, freqlist);
hfssSolveSetup(fid, setupstr1);
% hfssSolveSetup(fid, setupstr2);
% hfssSolveSetup(fid, setupstr3);


hfssCreateReport(fid, 'Return Loss', 1, 1, setupstr1, 'Dicrete1',...
                     [], 'Sweep', {'Freq'}, {'Freq',...
                      'dB(S(Port1,Port1))'});                 
hfssCreateReport(fid, 'VSWR', 1, 1, setupstr1, 'Dicrete1',...
                 [], 'Sweep', {'Freq'}, {'Freq',...
                  'VSWR(Port1)'});

hfssInsertFarFieldSphereSetup(fid, 'Radiation',[0, 180, 10],[-90, 90, 2]);


                  
hfssExportToFile(fid, 'Return Loss', 'SParams', 'txt'); % Saves in the same dir.
hfssExportToFile(fid, 'VSWR', 'VSWR', 'txt'); % Saves in the same dir.
% hfssExportRadiationParametersToFile(fid,'AntParams.txt','Radiation',setupstr1,fC(1)/1e9);
% hfssExportRadiationParametersToFile(fid,'AntParams2.txt','Radiation',setupstr2,fC(2)/1e9);
% hfssExportRadiationParametersToFile(fid,'AntParams3.txt','Radiation',setupstr3,fC(3)/1e9);


 % Save project and close file.
hfssSaveProject(fid, tmpPrjFile, true);


fclose(fid);
% Open HFSS executing the script.
hfssExecuteScript(hfssExePath, tmpScriptFile, true, true);

end