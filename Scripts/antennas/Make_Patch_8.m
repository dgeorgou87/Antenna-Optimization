function Make_Patch_8(x,fC,freqname)

%fclose('all');
% delete('Patch_8.aedt');
% delete('Patch_8.aedt.lock');
% delete('Patch_8.log');
% delete('Patch_8.vbs');

% Add paths to the required m-files.
hfssSetExePath;
tmpPrjFile = [pwd, '\Patch_8.aedt'];
tmpScriptFile = [pwd, '\Patch_8.vbs'];

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
Hsub =0.8; %Total heigth of substrate
%Patch dimensions
% Lp    =49e-3;
% Wp    =55.1e-3;

%x=[26 45 40 18 5.5 4.5 2.82 19.1 0.8 3.5 1 10/34 2.25];
%8*Cd+14*R=L3  CD=2.5*R

Wpatch=x(1);
Wsub2=x(2)*Wpatch;
Wsub1=x(3)*Wsub2;
SL=x(4)*Wpatch;
SW=x(5)*SL;
G=x(6)*SL;
Tc=x(7)*Wpatch;
L1=x(8)*Wsub2;
W1=x(9);
L2=x(10)*SW;
W2=x(11)*SW;
R=x(12);
Wfeed=x(13)*Wsub2;


% Wsub1=x(3);
% SL=x(4);
% SW=x(5);
% G=x(6);
% Tc=x(7);
% L1=x(8);
% W1=x(9);
% L2=x(10);
% W2=x(11);
% R=x(12);
% Wfeed=x(13);



Cd=2.5*R;
L3=8*Cd+14*R;

Wsub1=RoundNew(Wsub1,decimalplaces);
Wsub2=RoundNew(Wsub2,decimalplaces);
Wpatch=RoundNew(Wpatch,decimalplaces);
SL=RoundNew(SL,decimalplaces);
SW=RoundNew(SW,decimalplaces);
G=RoundNew(G,decimalplaces);
Tc=RoundNew(Tc,decimalplaces);
L1=RoundNew(L1,decimalplaces);
W1=RoundNew(W1,decimalplaces);
L2=RoundNew(L2,decimalplaces);
W2=RoundNew(W2,decimalplaces);
L3=RoundNew(L3,decimalplaces);
R=RoundNew(R,decimalplaces);
Cd=RoundNew(Cd,decimalplaces);
Wfeed=RoundNew(Wfeed,decimalplaces);




% Open a temporary script file.
fid = fopen(tmpScriptFile, 'wt');

% Create a new HFSS project.
hfssNewProject(fid);
hfssInsertDesign(fid, freqname);

%Set model units to mm
hfssSetUnit(fid, 'mm');


%Draw the patch
hfssRectangle(fid, 'Patch', 'Z', [(Wsub2-Wpatch)/2, Wsub1-Wsub2+(Wsub2-Wpatch)/2 , 0], Wpatch, Wpatch, 'mm');

leg=Tc/sqrt(2);

%Draw the triangle 1
hfssPolygon(fid, 'Triangle1', [(Wsub2+Wpatch)/2, Wsub1-Wsub2+(Wsub2-Wpatch)/2, 0; ...
                               (Wsub2+Wpatch)/2, leg+Wsub1-Wsub2+(Wsub2-Wpatch)/2, 0;   ...
                               (Wsub2+Wpatch)/2-leg, Wsub1-Wsub2+(Wsub2-Wpatch)/2, 0;  ...
                               (Wsub2+Wpatch)/2, Wsub1-Wsub2+(Wsub2-Wpatch)/2, 0], ...
                               'mm')

%Draw the triangle 2
hfssPolygon(fid, 'Triangle2', [(Wsub2-Wpatch)/2, Wsub1-Wsub2+(Wsub2+Wpatch)/2, 0; ...
                               (Wsub2-Wpatch)/2+leg, Wsub1-Wsub2+(Wsub2+Wpatch)/2, 0;   ...
                               (Wsub2-Wpatch)/2, Wsub1-Wsub2+(Wsub2+Wpatch)/2-leg, 0;  ...
                               (Wsub2-Wpatch)/2, Wsub1-Wsub2+(Wsub2+Wpatch)/2, 0], ...
                               'mm')

%Subtract
hfssSubtract(fid, {'Patch'},[{'Triangle1'},{'Triangle2'}]);

%Draw the patch 2
hfssRectangle(fid, 'Patch2', 'Z', [0, 0, 0], SW, SW, 'mm');
hfssRectangle(fid, 'Sub1', 'Z', [(SW-W2)/2, SW, 0], W2, -L2, 'mm');
hfssSubtract(fid, {'Patch2'},{'Sub1'});

hfssCircle(fid, 'Circle', 'Z', [-(L3-SW)/2-R, -(L3-SW)/2-R, 0], R, 'mm');
hfssDuplicateAlongLine(fid, {'Circle'}, [0 Cd+2*R 0], 9 , 'mm');
hfssDuplicateAlongLine(fid, {'Circle'}, [Cd+2*R 0 0], 9 , 'mm');
hfssDuplicateAlongLine(fid, {'Circle_16'}, [0 Cd+2*R 0], 9 , 'mm');
hfssDuplicateAlongLine(fid, {'Circle_8'}, [Cd+2*R 0 0], 8 , 'mm');
hfssUnite(fid, {'Circle', 'Circle_1', 'Circle_2', 'Circle_3', 'Circle_4', 'Circle_5', 'Circle_6', 'Circle_7' , 'Circle_8',...
               'Circle_8_1', 'Circle_8_2', 'Circle_8_3', 'Circle_8_4', 'Circle_8_5', 'Circle_8_6', 'Circle_8_7',...
               'Circle_9', 'Circle_10', 'Circle_11', 'Circle_12', 'Circle_13', 'Circle_14', 'Circle_15', 'Circle_16',...
               'Circle_16_1', 'Circle_16_2', 'Circle_16_3', 'Circle_16_4', 'Circle_16_5', 'Circle_16_6', 'Circle_16_7', 'Circle_16_8'});


hfssUnite(fid, {'Patch2','Circle'})

hfssRectangle(fid, 'Leg', 'Z', [-(SL-SW)/2, -(SL-SW)/2, 0], W1, SL, 'mm');
hfssRectangle(fid, 'Leg1', 'Z', [-(SL-SW)/2, -(SL-SW)/2, 0], SL, W1, 'mm');
hfssRectangle(fid, 'Leg2', 'Z', [-(SL-SW)/2+SL, -(SL-SW)/2, 0], -W1, SL, 'mm');
hfssRectangle(fid, 'Leg3', 'Z', [-(SL-SW)/2, -(SL-SW)/2+SL, 0], SL, -W1, 'mm');

hfssRectangle(fid, 'Gap', 'Z', [-(SL-SW)/2, -(SL-SW)/2+(SL-G)/2, 0], W1, G, 'mm');
hfssRectangle(fid, 'Gap1', 'Z', [-(SL-SW)/2+(SL-G)/2, -(SL-SW)/2, 0], G, W1, 'mm');
hfssRectangle(fid, 'Gap2', 'Z', [-(SL-SW)/2+SL, -(SL-SW)/2+(SL-G)/2, 0], -W1, G, 'mm');
hfssRectangle(fid, 'Gap3', 'Z', [-(SL-SW)/2+(SL-G)/2, -(SL-SW)/2+SL, 0], G, -W1, 'mm');

hfssSubtract(fid, {'Leg'},{'Gap'});
hfssSubtract(fid, {'Leg1'},{'Gap1'});
hfssSubtract(fid, {'Leg2'},{'Gap2'});
hfssSubtract(fid, {'Leg3'},{'Gap3'});

hfssUnite(fid, {'Patch2','Leg','Leg1','Leg2','Leg3'});


hfssRotate(fid, {'Patch2'}, 'Z', 45);
hyp=sqrt(2*(SW^2));
hfssMove(fid, {'Patch2'}, [Wsub2/2,Wsub1-Wsub2+Wsub2/2-hyp/2, 0], 'mm');
hfssSubtract(fid, {'Patch'},{'Patch2'});


hfssSetColor(fid, 'Patch', [126 , 96, 0]);
hfssSetTransparency(fid, {'Patch'} , 0);
hfssAssignFiniteCondNew(fid,'FiniteCond1', 'Patch', 'copper',  0);

%Draw the feed
hfssRectangle(fid, 'Feed', 'Z', [(Wsub2-Wfeed)/2, 0, -Hsub], Wfeed ,L1 , 'mm');
hfssSetColor(fid, 'Feed', [126 , 96, 0]);
hfssSetTransparency(fid, {'Feed'}, 0);
hfssAssignFiniteCondNew(fid,'FiniteCond', 'Feed', 'copper',  0);

%Draw the substrate 1
hfssBox(fid, 'FR4a', [0, 0, -Hsub], [Wsub2, Wsub1, -Hsub], 'mm');
hfssAssignMaterial(fid, 'FR4a', 'FR4_Epoxy');
hfssSetColor(fid, 'FR4a', [252, 192, 0]);
hfssSetTransparency(fid, {'FR4a'}, 0);

%Draw the substrate 2
hfssBox(fid, 'FR4b', [0, Wsub1-Wsub2, 0], [Wsub2, Wsub2, -Hsub], 'mm');
hfssAssignMaterial(fid, 'FR4b', 'FR4_Epoxy');
hfssSetColor(fid, 'FR4b', [197, 91, 16]);
hfssSetTransparency(fid, {'FR4b'}, 0);

% Draw a ground plane.
hfssRectangle(fid, 'GroundPlane', 'Z', [0, 0, -2*Hsub],Wsub2 ,Wsub1 , 'mm');
hfssSetColor(fid, 'GroundPlane', [126 , 96, 0]);
hfssSetTransparency(fid, {'GroundPlane'}, 0);
hfssAssignFiniteCondNew(fid,'FiniteCond2', 'GroundPlane', 'copper',  0);

% Draw radiation boundaries.
hfssBox(fid, 'AirBox', [-Lambda,-Lambda, Lambda], ...
    [2*Lambda+Wsub1,2*Lambda+Wsub1,-2*Lambda-2*Hsub], 'mm'); 
hfssAssignRadiation(fid, 'ABC', 'AirBox');
hfssSetTransparency(fid, {'AirBox'}, 0.95);

%Draw a wave port for the patch.
hfssRectangle(fid, 'Port', 'Y', [(Wsub2-Wfeed)/2, 0, -Hsub], -Hsub, Wfeed, 'mm');
hfssAssignLumpedPort(fid, 'Port1', 'Port', [Wsub2/2, 0, -2*Hsub], ...
  	[Wsub2/2, 0, -Hsub], 'mm');


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