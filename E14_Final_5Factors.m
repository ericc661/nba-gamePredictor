%%ENGR 014 Final project
%calculating five factors for each team
%by Eric Chen
%5/14/18

% 
% 
% %cols we need, rebounding is 2 factors
% %EFG: FG, 3P, FGA
% %TOV%: TOV, FGA, FTA 
% %ORB%: ORB, OPP DRB
% %DRB%: DRB, OPP ORB
% %FT factor: FT, FGA
% 
% %check later
% %so we need FG, 3P, FGA, TOV, FTA, ORB, OPP DRB, DRB,    OPP ORB, FT, DATE
% %columns:    9, 12, 10,  23,  16,  18, 36-35   , 19-18,  35,      15, 3
% 
% raw = raw([3:end],:); %cut off first 2 rows of nothing
% 
% %make matrix for raw stats used in 4 factors
% cutgamelog = zeros(length(raw),11); %should be 82x11
% cutgamelog(:,1) = num(:,9); %first column is FG
% cutgamelog(:,2) = num(:,12); %3P
% cutgamelog(:,3) = num(:,10); %FGA
% cutgamelog(:,4) = num(:,23);  %TOV
% cutgamelog(:,5) = num(:,16); %FTA
% cutgamelog(:,6) = num(:,18); %ORB
% cutgamelog(:,7) = num(:,36)-num(:,35); %OPP DRB
% cutgamelog(:,8) = num(:,19)-num(:,18); %DRB
% cutgamelog(:,9) = num(:,35); %OPP ORB
% cutgamelog(:,10) = num(:,15); %FT
% cutgamelog(:,11) = num(:,3); %THE DATE, important for indexing later
% 
% fivefacs = E14_Calc5Facs(cutgamelog);

%% Create 5 factors for 30 teams, 82 games
files = {'NBA1ATL.xls' 'NBA2BOS.xls' 'NBA3BKN.xls' 'NBA4CHA.xls' ...
    'NBA5CHI.xls' 'NBA6CLE.xls' 'NBA7DAL.xls' 'NBA8DEN.xls' ...
    'NBA9DET.xls' 'NBA10GSW.xls' 'NBA11HOU.xls' 'NBA12IND.xls' ...
    'NBA13LAC.xls' 'NBA14LAL.xls' 'NBA15MEM.xls' 'NBA16MIA.xls' ...
    'NBA17MIL.xls' 'NBA18MIN.xls' 'NBA19NOP.xls' 'NBA20NYK.xls'...
    'NBA21OKC.xls' 'NBA22ORL.xls' 'NBA23PHI.xls' 'NBA24PHO.xls'...
    'NBA25POR.xls' 'NBA26SAC.xls' 'NBA27SAS.xls' 'NBA28TOR.xls'...
    'NBA29UTA.xls' 'NBA30WAS.xls'}; %by Nick Pugliano
fivefacs = zeros([82 6 30]); %3rd dimension is team
for i = 1:30
    filename = files{i};
    [num,txt,raw] = xlsread(filename); %read in each season game log
    raw = raw([3:end],:); %cut off first 2 rows of nothing
    
    %make matrix for raw stats used in 5 factors
    cutgamelog = zeros(length(raw),11); %should be 82x11
    cutgamelog(:,1) = num(:,9); %first column is FG
    cutgamelog(:,2) = num(:,12); %3P
    cutgamelog(:,3) = num(:,10); %FGA
    cutgamelog(:,4) = num(:,23);  %TOV
    cutgamelog(:,5) = num(:,16); %FTA
    cutgamelog(:,6) = num(:,18); %ORB
    cutgamelog(:,7) = num(:,36)-num(:,35); %OPP DRB
    cutgamelog(:,8) = num(:,19)-num(:,18); %DRB
    cutgamelog(:,9) = num(:,35); %OPP ORB
    cutgamelog(:,10) = num(:,15); %FT
    cutgamelog(:,11) = num(:,3); %THE DATE, important for indexing later
    
    fivefacs(:,:,i) = E14_Calc5Facs(cutgamelog);
end

%% five-factor paired differences for each game
%also want the point differential
[num,txt,raw] = xlsread('NBATeamNames.xls'); %read in team names
TeamNames = txt(2:31,1); %30x1 cell with team names

[num,txt,raw] = xlsread('NBA1718Season.xls'); %read in overall game log
seasonlograw = raw(2:end,:); %cut off headers
seasonlognum = num(2:end,:); %cut off headers for numerical
%idea: make a count for each team to help with indexing

%for each game want 2 team numbers, 5 columns for factors, point diff,
    %first game flag

finaldata = zeros([length(seasonlograw) 9]);
gamecounts = zeros([30 1]); %vector for game counts
for i = 1:length(seasonlograw)
    %1: identify & fill in correct visiting and home teams
    for j = 1:length(TeamNames)
        if strcmp(seasonlograw{i,3},TeamNames{j})==1 %assign correct vising team
            away = j;
            finaldata(i,1) = away; %j gives index into TeamNames for 
                                %correct visiting team
        end
        if strcmp(seasonlograw{i,5},TeamNames{j})==1 %same for home team
            home = j;
            finaldata(i,2) = home;
        end
    end
    
    if (gamecounts(away)==0 || gamecounts(home)==0)
        finaldata(i,9) = 1;
    end
    
    %increment gamecounts, gives index into correct
    %five factor window
    gamecounts(away) = gamecounts(away)+1; 
    gamecounts(home) = gamecounts(home)+1;
    
    %get five factors and date for away then home for correct window
    %for this game
    facsdateaway = fivefacs(gamecounts(away),:,away); 
    facsdatehome = fivefacs(gamecounts(home),:,home); 
    
    %CALCULATE AND INPUT FIVE FACTOR DIFFERENTIAL
    %THIS IS AWAY TEAM MINUS HOME TEAM
    finaldata(i,3:7) = facsdateaway(1:5)-facsdatehome(1:5); %exclude date
    
    
    %CALCULATE POINT DIFFERENTIAL
    %this is away-home points
    finaldata(i,8) = seasonlognum(i,3)-seasonlognum(i,5);
    
    
end

%NOTE: paired differences for ith game INCLUDE stats for that game - 
%if you want data to predict the game then take the entry before

csvwrite('NBA1718_FinalData',finaldata);
