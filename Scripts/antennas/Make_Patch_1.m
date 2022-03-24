function Make_Patch_1(x,fC,freqname)


% Add paths to the required m-files.
hfssSetExePath;
tmpPrjFile = [pwd, '\Patch_1.aedt'];
tmpScriptFile = [pwd, '\Patch_1.vbs'];

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
% Lp    =49e-3;
% Wp    =55.1e-3;

%x=[20 60   0.15 0.15 0.15 0.3 0.3 0.3    0.2 0.15 0.15 0.2 0.10 0.15  0.4 0.1 0.4];
W=x(1);
L=x(2);

Ls1=x(3)*L;
Ls2=x(4)*L;
Ls3=x(5)*L;
Ws1=x(6)*W;
Ws2=x(7)*W;
Ws3=x(8)*W;

L1=x(9)*L;
L2=x(10)*L;
L3=x(11)*L;
W1=x(12)*W;
W2=x(13)*W;
W3=x(14)*W;

% Wsub=(2+x(15))*W;
% Lsub=(1.5+x(16))*L;
Wsub=W+Lambda/2;
Lsub=L+Lambda/2;

yfeed=x(15)*L;
Wfeed=x(16)*L;

Wground=Wsub*x(17);


Ls1=RoundNew(Ls1,decimalplaces);
Ls2=RoundNew(Ls2,decimalplaces);
Ls3=RoundNew(Ls3,decimalplaces);
Ws1=RoundNew(Ws1,decimalplaces);
Ws2=RoundNew(Ws2,decimalplaces);
Ws3=RoundNew(Ws3,decimalplaces);

L1=RoundNew(L1,decimalplaces);
L2=RoundNew(L2,decimalplaces);
L3=RoundNew(L3,decimalplaces);
W1=RoundNew(W1,decimalplaces);
W2=RoundNew(W2,decimalplaces);
W3=RoundNew(W3,decimalplaces);

Wsub=RoundNew(Wsub,decimalplaces);
Lsub=RoundNew(Lsub,decimalplaces);

yfeed=RoundNew(yfeed,decimalplaces);
Wfeed=RoundNew(Wfeed,decimalplaces);

Wground=RoundNew(Wground,decimalplaces);



% Open a temporary script file.
fid = fopen(tmpScriptFile, 'wt');

% Create a new HFSS project.
hfssNewProject(fid);
hfssInsertDesign(fid, freqname);

%Set model units to mm
hfssSetUnit(fid, 'mm');


%Draw the patch
hfssRectangle(fid, 'Patch', 'Z', [0, 0, 0], W, L, 'mm');

%Draw the feed
hfssRectangle(fid, 'Feed', 'Z', [W, yfeed, 0], Wsub/2-W/2 ,Wfeed , 'mm');

hfssUnite(fid, {'Patch','Feed'});

%Slots
hfssRectangle(fid, 'Slot1', 'Z', [W1, L1, 0], Ws1, Ls1, 'mm');
hfssRectangle(fid, 'Slot2', 'Z', [W2, L1+Ls1+L2, 0], Ws2, Ls2, 'mm');
hfssRectangle(fid, 'Slot3', 'Z', [W3, L1+Ls1+L2+Ls2+L3, 0], Ws3, Ls3, 'mm');

%Subtract
hfssSubtract(fid, {'Patch'},{'Slot1'});
hfssSubtract(fid, {'Patch'},{'Slot2'});
hfssSubtract(fid, {'Patch'},{'Slot3'});

hfssSetColor(fid, 'Patch', [255 , 128, 0]);
hfssSetTransparency(fid, {'Patch'} , 0);
hfssAssignFiniteCondNew(fid,'FiniteCond1', 'Patch', 'copper',  0);

% Draw a ground plane.
hfssRectangle(fid, 'GroundPlane', 'Z', [W/2+Wsub/2, -Lsub/2+L/2, -Hsub],-Wground ,Lsub , 'mm');
hfssSetColor(fid, 'Patch', [255 , 128, 0]);
hfssSetTransparency(fid, {'GroundPlane'}, 0);
hfssAssignFiniteCondNew(fid,'FiniteCond2', 'GroundPlane', 'copper',  0);


%Draw the substrate
hfssBox(fid, 'FR4', [-Wsub/2+W/2, -Lsub/2+L/2, 0], [Wsub, Lsub, -Hsub], 'mm');
hfssAssignMaterial(fid, 'FR4', 'FR4_Epoxy');
hfssSetColor(fid, 'FR4', [140, 128, 179]);
hfssSetTransparency(fid, {'FR4'}, 0.6);

% Draw radiation boundaries.
hfssBox(fid, 'AirBox', [-Wsub/2+W/2-Lambda,-Lsub/2+L/2-Lambda, Lambda], ...
    [2*Lambda+Wsub,2*Lambda+Lsub,-2*Lambda-Hsub], 'mm'); 
hfssAssignRadiation(fid, 'ABC', 'AirBox');
hfssSetTransparency(fid, {'AirBox'}, 0.95);


%Draw a wave port for the patch.
hfssRectangle(fid, 'Port', 'X', [Wsub/2+W/2, yfeed, 0], Wfeed, -Hsub,...
     'mm');
hfssAssignLumpedPort(fid, 'Port1', 'Port', [Wsub/2+W/2, yfeed+Wfeed/2, -Hsub], ...
  	[Wsub/2+W/2, yfeed+Wfeed/2, 0], 'mm');


setupstr1=['Setup',int2str(freqlist(1)*1000),'MHz'];
% Insert solution and sweep.
hfssInsertSolution(fid, setupstr1, fC(1)/1e9);
%hfssDiscreteSweep(fid, 'Sweep2to3GHz', 'Setup2_4GHz', [2, 3]);
% hfssInterpolatingSweep(fid, 'Sweep0_8to3GHz', 'Setup0_9GHz', ...
%    fStart, fStop, 1001);
hfssDiscreteSweep(fid, 'Dicrete1', setupstr1, freqlist);
hfssSolveSetup(fid, setupstr1);

%Solving a given soltuion setup
%hfssSolveSetup(fid, 'Setup0_9GHz');

hfssCreateReport(fid, 'Return Loss', 1, 1, setupstr1, 'Dicrete1',...
                     [], 'Sweep', {'Freq'}, {'Freq',...
                      'dB(S(Port1,Port1))'});                 
hfssCreateReport(fid, 'VSWR', 1, 1, setupstr1, 'Dicrete1',...
                 [], 'Sweep', {'Freq'}, {'Freq',...
                  'VSWR(Port1)'});

hfssInsertFarFieldSphereSetup(fid, 'Radiation',[0, 180, 10],[-90, 90, 2]);


                  
hfssExportToFile(fid, 'Return Loss', 'SParams', 'txt'); % Saves in the same dir.
hfssExportToFile(fid, 'VSWR', 'VSWR', 'txt'); % Saves in the same dir.
%hfssExportRadiationParametersToFile(fid,'AntParams.txt','Radiation',setupstr1,fC(1)/1e9);
% hfssExportRadiationParametersToFile(fid,'AntParams2.txt','Radiation',setupstr2,fC(2)/1e9);
% hfssExportRadiationParametersToFile(fid,'AntParams3.txt','Radiation',setupstr3,fC(3)/1e9);


 % Save project and close file.
hfssSaveProject(fid, tmpPrjFile, true);


fclose(fid);
% Open HFSS executing the script.
hfssExecuteScript(hfssExePath, tmpScriptFile, true, true);

end