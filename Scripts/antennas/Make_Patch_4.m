function Make_Patch_4(x,fC,freqname)


% Add paths to the required m-files.
hfssSetExePath;
tmpPrjFile = [pwd, '\Patch_4.aedt'];
tmpScriptFile = [pwd, '\Patch_4.vbs'];

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

% x=[2 2.5 26 28 6 6 0.8 0.8 0.8 0.5 0.5 0.5];

% Wsub=x(5);
% Lsub=x(6);

FeedS=x(1);
FeedWidth=x(2);
PatchWidth=x(4);
FeedLength=x(3)*PatchWidth;
PatchD=x(5);

Wsub=(PatchWidth+FeedLength);
Lsub=1.5*Wsub;
d=Lsub/2-PatchD-FeedS/2;

PatchBase=x(6);
SlotWidth1=x(7)*d;
SlotWidth2=x(8)*d;
SlotWidth3=x(9)*d;
Width1=x(10)*d;
Width2=x(11)*d;
Width3=x(12)*d;

FeedS=RoundNew(FeedS,decimalplaces);
FeedWidth=RoundNew(FeedWidth,decimalplaces);
FeedLength=RoundNew(FeedLength,decimalplaces);
PatchWidth=RoundNew(PatchWidth,decimalplaces);
Wsub=RoundNew(Wsub,decimalplaces);
Lsub=RoundNew(Lsub,decimalplaces);
PatchD=RoundNew(PatchD,decimalplaces);
PatchBase=RoundNew(PatchBase,decimalplaces);
SlotWidth1=RoundNew(SlotWidth1,decimalplaces);
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
hfssRectangle(fid, 'Patch1', 'Z', [Wsub-FeedLength, Lsub/2+FeedS/2, 0], PatchBase, Lsub/2-FeedS/2-PatchD, 'mm');
a=(PatchWidth-PatchBase)/2;
hfssPolygon(fid, 'Triangle1', [Wsub-FeedLength, Lsub/2+FeedS/2, 0; ...
                               Wsub-FeedLength, Lsub-PatchD, 0;   ...
                               Wsub-FeedLength-a, Lsub-PatchD 0;  ...
                               Wsub-FeedLength, Lsub/2+FeedS/2, 0], ...
                               'mm')

hfssPolygon(fid, 'Triangle2', [Wsub-FeedLength+PatchBase, Lsub/2+FeedS/2, 0; ...
                               Wsub-FeedLength+PatchBase, Lsub-PatchD, 0;   ...
                               Wsub-FeedLength+PatchBase+a, Lsub-PatchD 0;  ...
                               Wsub-FeedLength+PatchBase, Lsub/2+FeedS/2, 0], ...
                               'mm')                           
                           

%Draw the feed
hfssRectangle(fid, 'Feed', 'Z', [Wsub, Lsub/2+FeedS/2, 0], -FeedLength , FeedWidth, 'mm');
%Unite
hfssUnite(fid, {'Patch1','Triangle1','Triangle2','Feed'});
hfssSetColor(fid, 'Patch1', [255 , 128, 0]);
hfssSetTransparency(fid, {'Patch1'} , 0);
hfssAssignFiniteCondNew(fid,'FiniteCond1', 'Patch1', 'copper',  0);

%Slots
hfssRectangle(fid, 'Slot1', 'Z', [Wsub-FeedLength+PatchBase+a, Lsub-PatchD-Width1, 0], -PatchWidth , -SlotWidth1, 'mm');
hfssRectangle(fid, 'Slot2', 'Z', [Wsub-FeedLength+PatchBase+a, Lsub-PatchD-Width2-Width1-SlotWidth1, 0], -PatchWidth  , -SlotWidth2, 'mm');
hfssRectangle(fid, 'Slot3', 'Z', [Wsub-FeedLength+PatchBase+a, Lsub-PatchD-Width3-Width2-Width1-SlotWidth1-SlotWidth2, 0], -PatchWidth  , -SlotWidth3, 'mm');
% hfssRectangle(fid, 'Slot4', 'Z', [Wsub-FeedLength+Patchbase+a, Lsub-PatchD-7*SlotWidth, 0], -PatchWidth  , -SlotWidth, 'mm');
% hfssRectangle(fid, 'Slot5', 'Z', [Wsub-FeedLength+Patchbase+a, Lsub-PatchD-9*SlotWidth, 0], -PatchWidth  , -SlotWidth, 'mm');
% hfssRectangle(fid, 'Slot6', 'Z', [Wsub-FeedLength+Patchbase+a, Lsub-PatchD-11*SlotWidth, 0], -PatchWidth  , -SlotWidth, 'mm');
% hfssRectangle(fid, 'Slot7', 'Z', [Wsub-FeedLength+Patchbase+a, Lsub-PatchD-13*SlotWidth, 0], -PatchWidth  , -SlotWidth, 'mm');
% hfssRectangle(fid, 'Slot8', 'Z', [Wsub-FeedLength+Patchbase+a, Lsub-PatchD-15*SlotWidth, 0], -PatchWidth  , -SlotWidth, 'mm');
% hfssRectangle(fid, 'Slot9', 'Z', [Wsub-FeedLength+Patchbase+a, Lsub-PatchD-17*SlotWidth, 0], -PatchWidth  , -SlotWidth, 'mm');

%Subtract
% hfssSubtract(fid, {'Patch1'}, {'Slot1','Slot2','Slot3','Slot4','Slot5','Slot6','Slot7','Slot8','Slot9'});
hfssSubtract(fid, {'Patch1'}, {'Slot1','Slot2','Slot3'});

% Draw a ground plane.
hfssRectangle(fid, 'GroundPlane', 'Z', [0, 0, -Hsub], Wsub, Lsub, 'mm');
hfssSetColor(fid, 'Patch1', [255 , 128, 0]);
hfssSetTransparency(fid, {'GroundPlane'}, 0);
hfssAssignFiniteCondNew(fid,'FiniteCond2', 'GroundPlane', 'copper',  0);
% 
% 
% %Draw the substrate
hfssBox(fid, 'FR4', [0, 0, 0], [Wsub, Lsub, -Hsub], 'mm');
hfssAssignMaterial(fid, 'FR4', 'FR4_Epoxy');
hfssSetColor(fid, 'FR4', [140, 128, 179]);
hfssSetTransparency(fid, {'FR4'}, 0.6);

% Mirror
hfssDuplicateMirror(fid, {'Patch1'}, [Wsub, Lsub/2, 0], [0, 1, 0], 'mm');
hfssUnite(fid, {'Patch1','Patch1_1'});


% % Draw radiation boundaries.
hfssBox(fid, 'AirBox', [-Lambda,-Lambda, Lambda], ...
    [2*Lambda+Wsub,2*Lambda+Lsub,-2*Lambda-Hsub], 'mm'); 
hfssAssignRadiation(fid, 'ABC', 'AirBox');
hfssSetTransparency(fid, {'AirBox'}, 0.95);
% 
% 
% %Draw a wave port for the patch.
hfssRectangle(fid, 'Port', 'Z', [Wsub, (Lsub-FeedS)/2, 0], -FeedLength/10, FeedS,...
     'mm');
hfssAssignLumpedPort(fid, 'Port1', 'Port', [Wsub-FeedLength/20, (Lsub-FeedS)/2,0], ...
  	[Wsub-FeedLength/20, (Lsub+FeedS)/2, 0], 'mm');


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