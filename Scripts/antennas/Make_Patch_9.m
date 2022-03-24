function Make_Patch_9(x,fC,freqname)

fclose('all');
%delete('Patch_9.aedt');
%delete('Patch_9.aedt.lock');
%delete('Patch_9.log');
%delete('Patch_9.vbs');

% Add paths to the required m-files.
hfssSetExePath;
tmpPrjFile = [pwd, '\Patch_9.aedt'];
tmpScriptFile = [pwd, '\Patch_9.vbs'];

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

%x=[12 27.5 17.5 42.5 18 21.5 20 55 3];

% L=x(1);
% W=x(2);
a=x(1);
b=x(2);
c=x(3);
gL=x(4);
d=x(5);
L1=x(6);
L2=x(7);
fL=x(8);
fW=x(9);

W=(L1+a+c)*3;
L=(fL+b+d)*1.5;

L=RoundNew(L,decimalplaces);
W=RoundNew(W,decimalplaces);
a=RoundNew(a,decimalplaces);
b=RoundNew(b,decimalplaces);
c=RoundNew(c,decimalplaces);
gL=RoundNew(gL,decimalplaces);
d=RoundNew(d,decimalplaces);
L1=RoundNew(L1,decimalplaces);
L2=RoundNew(L2,decimalplaces);
fL=RoundNew(fL,decimalplaces);
fW=RoundNew(fW,decimalplaces);

% Open a temporary script file.
fid = fopen(tmpScriptFile, 'wt');

% Create a new HFSS project.
hfssNewProject(fid);
hfssInsertDesign(fid, freqname);

%Set model units to mm
hfssSetUnit(fid, 'mm');

%Draw the feed
hfssRectangle(fid, 'Feed', 'Z', [(W-fW)/2, 0, 0], fW ,fL , 'mm');

%Draw the patch
hfssRectangle(fid, 'Patch', 'Z', [(W-fW)/2, fL , 0], -L1, -fW, 'mm');
hfssRectangle(fid, 'Patch1', 'Z', [(W-fW)/2-L1, fL-fW , 0], fW ,fW+L2, 'mm');
hfssRectangle(fid, 'Patch2', 'Z', [(W-fW)/2-L1+fW, fL+L2 , 0], -a, -fW, 'mm');
hfssRectangle(fid, 'Patch3', 'Z', [(W-fW)/2-L1+fW-a, fL+L2 , 0], fW, -b, 'mm');
hfssRectangle(fid, 'Patch4', 'Z', [(W-fW)/2-L1+2*fW-a, fL+L2-b-fW , 0], -c, fW, 'mm');
hfssRectangle(fid, 'Patch5', 'Z', [(W-fW)/2-L1+2*fW-a-c, fL+L2-b-fW , 0], fW, d, 'mm');

hfssUnite(fid, {'Patch','Feed','Patch1','Patch2','Patch3','Patch4','Patch5'});
hfssSetColor(fid, 'Patch', [255 , 128, 0]);
hfssSetTransparency(fid, {'Patch'} , 0);

hfssDuplicateMirror(fid, {'Patch'}, [W/2, 0, 0], [2, 0, 0], 'mm');
hfssAssignFiniteCondNew(fid,'FiniteCond1', 'Patch', 'copper',  0);
hfssAssignFiniteCondNew(fid,'FiniteCond2', 'Patch_1', 'copper',  0);

hfssMove(fid, {'Patch_1'}, [0, 0, -Hsub], 'mm');

%Draw the substrate
hfssBox(fid, 'FR4', [0, 0, 0], [W, L, -Hsub], 'mm');
hfssAssignMaterial(fid, 'FR4', 'FR4_Epoxy');
hfssSetColor(fid, 'FR4', [140, 128, 179]);
hfssSetTransparency(fid, {'FR4'}, 0.6);


% Draw a ground plane.
hfssRectangle(fid, 'GroundPlane', 'Z', [0, 0, -Hsub],W ,gL , 'mm');
hfssSetColor(fid, 'GroundPlane', [255 , 128, 0]);
hfssSetTransparency(fid, {'GroundPlane'}, 0.7);
hfssAssignFiniteCondNew(fid,'FiniteCond3', 'GroundPlane', 'copper',  0);

% Draw radiation boundaries.
hfssBox(fid, 'AirBox', [-Lambda,-Lambda, Lambda], ...
    [2*Lambda+W,2*Lambda+L,-2*Lambda-Hsub], 'mm'); 
hfssAssignRadiation(fid, 'ABC', 'AirBox');
hfssSetTransparency(fid, {'AirBox'}, 0.95);

%Draw a wave port for the patch.
hfssRectangle(fid, 'Port', 'Y', [(W-fW)/2, 0, 0], -Hsub, fW, 'mm');
hfssAssignLumpedPort(fid, 'Port1', 'Port', [W/2, 0, -Hsub], ...
  	[W/2, 0, 0], 'mm');


setupstr1=['Setup',int2str(freqlist(1)*1000),'MHz'];
% setupstr2=['Setup',int2str(freqlist(2)*1000),'MHz'];
% setupstr3=['Setup',int2str(freqlist(3)*1000),'MHz'];
% Insert solution and sweep.
hfssInsertSolution(fid, setupstr1, fC(1)/1e9);
% hfssInsertSolution(fid, setupstr2, fC(2)/1e9);
% hfssInsertSolution(fid, setupstr3, fC(3)/1e9);


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
hfssExportRadiationParametersToFile(fid,'AntParams.txt','Radiation',setupstr1,fC(1)/1e9);
% hfssExportRadiationParametersToFile(fid,'AntParams2.txt','Radiation',setupstr2,fC(2)/1e9);
% hfssExportRadiationParametersToFile(fid,'AntParams3.txt','Radiation',setupstr3,fC(3)/1e9);


 % Save project and close file.
hfssSaveProject(fid, tmpPrjFile, true);


fclose(fid);
% Open HFSS executing the script.
hfssExecuteScript(hfssExePath, tmpScriptFile, true, true);

end