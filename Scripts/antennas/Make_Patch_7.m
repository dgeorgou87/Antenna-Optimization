function Make_Patch_7(x,fC,freqname)

fclose('all');
% delete('Patch_7.aedt');
% delete('Patch_7.aedt.lock');
% delete('Patch_7.log');
% delete('Patch_7.vbs');

% Add paths to the required m-files.
hfssSetExePath;
tmpPrjFile = [pwd, '\Patch_7.aedt'];
tmpScriptFile = [pwd, '\Patch_7.vbs'];

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

% x=[81 53.5 95 75 14.7 1.5 8.5 8 19.8 14 8.2 17 14 14 9 1];
% 
% W=x(1);
% L=x(2);
% Sw=x(3);
% Sl=x(4);
% Se=x(5);
% Lw=x(6);
% g1=x(7);
% g2=x(8);
% a=x(9);
% b=x(10);
% c=x(11);
% d=x(12);
% e=x(13);
% f=x(14);
% j=x(15);
% m=x(16);

W=x(1);
L=x(2);
Sw=x(3)*W;
Sl=x(4)*L;
Se=x(5)*L;
Lw=x(6)*W;
g1=x(7)*W;
g2=x(8)*L;
a=x(9)*L;
b=x(10)*L;
c=x(11)*L;
d=x(12)*W;
e=x(13)*W;
f=x(14)*W;
j=x(15)*W;
m=x(16)*W;

Sw=RoundNew(Sw,decimalplaces);
Sl=RoundNew(Sl,decimalplaces);
W=RoundNew(W,decimalplaces);
L=RoundNew(L,decimalplaces);
Se=RoundNew(Se,decimalplaces);
Lw=RoundNew(Lw,decimalplaces);
g1=RoundNew(g1,decimalplaces);
g2=RoundNew(g2,decimalplaces);
a=RoundNew(a,decimalplaces);
b=RoundNew(b,decimalplaces);
c=RoundNew(c,decimalplaces);
d=RoundNew(d,decimalplaces);
e=RoundNew(e,decimalplaces);
f=RoundNew(f,decimalplaces);
j=RoundNew(j,decimalplaces);
m=RoundNew(m,decimalplaces);




% Open a temporary script file.
fid = fopen(tmpScriptFile, 'wt');

% Create a new HFSS project.
hfssNewProject(fid);
hfssInsertDesign(fid, freqname);

%Set model units to mm
hfssSetUnit(fid, 'mm');


%Draw the patch
hfssRectangle(fid, 'Patch', 'Z', [(Sw-W)/2, Se, 0], W, L, 'mm');
hfssRectangle(fid, 'Sub1', 'Z', [(Sw-g1)/2, 0, 0],g1 ,Se+g2 , 'mm');
hfssRectangle(fid, 'Sub2', 'Z', [(Sw-W)/2+m+j, Se+j, 0],m ,-j , 'mm');
hfssRectangle(fid, 'Sub3', 'Z', [(Sw-W)/2+m, Se+j, 0],d ,a+b+c , 'mm');
hfssRectangle(fid, 'Sub4', 'Z', [(Sw-W)/2+m+d, Se+j+c, 0],e ,b , 'mm');
hfssRectangle(fid, 'Sub5', 'Z', [(Sw-f)/2, Se+L, 0],f ,-f-(L-a-b-c-j) , 'mm');
hfssRectangle(fid, 'Sub6', 'Z', [(Sw+W)/2-m-j, Se+j, 0],-m ,-j , 'mm');
hfssRectangle(fid, 'Sub7', 'Z', [(Sw+W)/2-m, Se+j, 0],-d ,a+b+c , 'mm');
hfssRectangle(fid, 'Sub8', 'Z', [(Sw+W)/2-m-d, Se+j+c, 0],-e ,b , 'mm');

%Subtract
hfssSubtract(fid, {'Patch'},{'Sub1'});
hfssSubtract(fid, {'Patch'},{'Sub2'});
hfssSubtract(fid, {'Patch'},{'Sub3'});
hfssSubtract(fid, {'Patch'},{'Sub4'});
hfssSubtract(fid, {'Patch'},{'Sub5'});
hfssSubtract(fid, {'Patch'},{'Sub6'});
hfssSubtract(fid, {'Patch'},{'Sub7'});
hfssSubtract(fid, {'Patch'},{'Sub8'});
               
%Draw the feed
hfssRectangle(fid, 'Feed', 'Z', [(Sw-Lw)/2, 0, 0], Lw ,Se+g2 , 'mm');

%Unite
hfssUnite(fid,{'Patch','Feed'});

hfssSetColor(fid, 'Patch', [255 , 128, 0]);
hfssSetTransparency(fid, {'Patch'} , 0);
hfssAssignFiniteCondNew(fid,'FiniteCond1', 'Patch', 'copper',  0);

%Draw the substrate
hfssBox(fid, 'FR4', [0, 0, 0], [Sw, Sl, -Hsub], 'mm');
hfssAssignMaterial(fid, 'FR4', 'FR4_Epoxy');
hfssSetColor(fid, 'FR4', [140, 128, 179]);
hfssSetTransparency(fid, {'FR4'}, 0.6);

% Draw a ground plane.
hfssRectangle(fid, 'GroundPlane', 'Z', [0, 0, -Hsub],Sw ,Sl , 'mm');
hfssRectangle(fid, 'GroundPlaneSub', 'Z', [(Sw-g1)/2, 0, -Hsub],g1 ,Se+g2 , 'mm');
hfssSubtract(fid, {'GroundPlane'},{'GroundPlaneSub'});

hfssSetTransparency(fid, {'GroundPlane'}, 0);
hfssAssignFiniteCondNew(fid,'FiniteCond2', 'GroundPlane', 'copper',  0);

% Draw radiation boundaries.
hfssBox(fid, 'AirBox', [-Lambda,-Lambda, Lambda], ...
    [2*Lambda+W,2*Lambda+L,-2*Lambda-Hsub], 'mm'); 
hfssAssignRadiation(fid, 'ABC', 'AirBox');
hfssSetTransparency(fid, {'AirBox'}, 0.95);

%Draw a wave port for the patch.
hfssRectangle(fid, 'Port', 'Y', [Sw/2-f/2, 0, 0], -Hsub, f, 'mm');
hfssAssignLumpedPort(fid, 'Port1', 'Port', [Sw/2, 0, -Hsub], ...
  	[Sw/2, 0, 0], 'mm');


setupstr1=['Setup',int2str(freqlist(1)*1000),'MHz'];
% setupstr2=['Setup',int2str(freqlist(2)*1000),'MHz'];
% setupstr3=['Setup',int2str(freqlist(3)*1000),'MHz'];
% Insert solution and sweep.
hfssInsertSolution(fid, setupstr1, fC(1)/1e9);
% hfssInsertSolution(fid, setupstr2, fC(2)/1e9);
% hfssInsertSolution(fid, setupstr3, fC(3)/1e9);


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

 % Save project and close file.
hfssSaveProject(fid, tmpPrjFile, true);


fclose(fid);
% Open HFSS executing the script.
hfssExecuteScript(hfssExePath, tmpScriptFile, true, false);

end