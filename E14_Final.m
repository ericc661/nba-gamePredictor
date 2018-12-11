%% NBA Win Predictor on purely win-loss pct.
% by Eric Chen

%% simple W-L record algorithm on 17-18 season

n = 30; %number of teams
[num,txt,raw] = xlsread('NBATeamNames.xls'); %read in team names
TeamNames = txt(2:31,1); %30x1 cell with team names

currentWLs = zeros(n,2); %vector for current team WLs
%col 1 is Ws, col 2 is Ls, row number is team number

[num,txt,raw] = xlsread('NBA1718Season.xls'); %read in overall game log
raw = raw([2:end],:); %cut off title
gamelog = zeros(length(raw),8); 
%index: Game#    
%cols: 1) V team (index into TeamNames), 2) H team, 
%      3) V wins entering into game,   4) V L   5) H W    6)H L
%      7) predicted team to win coming in
%      8) actual team that won
%loop through raw season game log and make gamelog, while counting # of
%correct predictions

correctcount = 0; %to count correct predictions

for i = 1:length(raw)
    %1: identify & fill in correct visiting and home teams
    for j = 1:length(TeamNames)
        if strcmp(raw{i,3},TeamNames{j})==1 %assign correct vising team
            away = j;
            gamelog(i,1) = away; %j gives index into TeamNames for 
                                %correct visiting team
        end
        if strcmp(raw{i,5},TeamNames{j})==1 %same for home team
            home = j;
            gamelog(i,2) = home;
        end
    end
    
    %2: enter both teams' wins and losses COMING INTO the game
    gamelog(i,3) = currentWLs(away,1); %VW coming in
    gamelog(i,4) = currentWLs(away,2); %VL coming in
    gamelog(i,5) = currentWLs(home,1); %HW coming in
    gamelog(i,6) = currentWLs(home,2); %HL coming in
    
    %3: enter predicted team to win (whoever has higher win %)
            %for now: if win % same or first game, select home team
    %first if/else structure sifts out game 1
    if ( (gamelog(i,3) + gamelog(i,4) == 0)    || ...
            (gamelog(i,5) + gamelog(i,6) == 0)  )
        %if either team hasn't played a game, select home team to win
        gamelog(i,7) = home;
    else
        %if valid win percentages exist, predict based off those
        awaypct = gamelog(i,3)/(gamelog(i,3) + gamelog(i,4));
        homepct = gamelog(i,5)/(gamelog(i,5) + gamelog(i,6));
        if (awaypct == homepct) %if win pcts equal
            gamelog(i,7) = home;
        elseif (awaypct > homepct) %if away is better
            gamelog(i,7) = away;
        elseif (homepct > awaypct) %if home is better
            gamelog(i,7) = home;
        end
    end
   
    %4: enter who actually won the game (actual result) &
    %update currentWLs based on outcome of the game for both the 
            %visiting and home teams 
            
    if (raw{i,4}-raw{i,6}<0) %if away-home pts is negative
        gamelog(i,8) = home; %home team won
        currentWLs(home,1) = currentWLs(home,1)+1; %add win to home
        currentWLs(away,2) = currentWLs(away,2)+1; %add loss to away
    else
        gamelog(i,8) = away; %away team won
        currentWLs(home,2) = currentWLs(home,2)+1; %add loss to home
        currentWLs(away,1) = currentWLs(away,1)+1; %add win to away
    end
    
    %5: compare predicted result based on overall WLs and actual result;
    %count number of correctly predicted games
    if (gamelog(i,7)==gamelog(i,8))
        correctcount = correctcount + 1;
    end
    
end

fprintf('Using overall win %% as the sole predictor, %d out of %d' ...
    ,correctcount,length(gamelog));
fprintf(' games for this season\n');
fprintf('were predicted correctly, or %.3f%% \n', ...
        100*(correctcount/length(gamelog)))  



% % display team names to make sure correct
% for i = 1:length(OctGames)
%     fprintf('%d: Away team: %s \t Home team: %s\n', i, ... 
%                 TeamNames{OctGames(i,1)},TeamNames{OctGames(i,2)});
% end


%% try out last ___ W-L record as sole predictor
clear
records = zeros([30 82]); %create vector for 30 games' 82 games
                            %1 is win, 0 is loss
gamesplayed = zeros([30 1]); %vector for games each team has played
windsize = 10; %window size - i.e. we look at last windowsize games


[num,txt,raw] = xlsread('NBATeamNames.xls'); %read in team names
TeamNames = txt(2:31,1); %30x1 cell with team names        

[num,txt,raw] = xlsread('NBA1718Season.xls'); %read in overall game log
raw = raw([2:end],:); %cut off title

predact = zeros([length(raw) 2]); %col 1 is predicted team to win
                                  %col 2 is actual team that won

                                  
correctcount = 0; %count for # correctly predicted games
for i = 1:length(raw)
    %1: identify teams
    for j = 1:length(TeamNames)
        if strcmp(raw{i,3},TeamNames{j})==1 %assign correct vising team
            away = j;
            gamelog(i,1) = away; %j gives index into TeamNames for 
                                %correct visiting team
        end
        if strcmp(raw{i,5},TeamNames{j})==1 %same for home team
            home = j;
            gamelog(i,2) = home;
        end
    end
    
    %2: make window based on gamesplayed and records
    %note we haven't incremented gamesplayed yet, so 
    %values we use are COMING IN
    %also calculate win percentages for the windows
    if (gamesplayed(home)==0 || gamesplayed(away)==0)
        predact(i,1) = home; %pick home team if one team hasn't played
   
    else %if it's not first game can't immediately pick home
        if (gamesplayed(home)>windsize && gamesplayed(away)>windsize)
            homewind = records(home,(gamesplayed(home)-(windsize-1)):gamesplayed(home));
            %bc if we've played 11 games  & windsize 10 want window to be 2 
            %to 11
            awaywind = records(away,(gamesplayed(away)-(windsize-1)):gamesplayed(away));
        else %if window not quite big enough
            %just start from first game
            homewind = records(home,1:gamesplayed(home));
            awaywind = records(away,1:gamesplayed(away));
        end
        
        nwins = 0; %counter for wins
        for j = 1:length(homewind)
            if(homewind(j)==1) %if we see a win
                nwins = nwins + 1;
            end
        end
        homepct = nwins/length(homewind);
        %same thing for away
        nwins = 0; %counter for wins
        for j = 1:length(awaywind)
            if(awaywind(j)==1) %if we see a win
                nwins = nwins + 1;
            end
        end
        awaypct = nwins/length(awaywind);
         %3: actually predict the result and enter

        if (homepct >= awaypct) %predict home team if pcts equal or greater
            predact(i,1) = home; 
        else
          predact(i,1) = away;
        end
    end
    
    
    
    %at this point in time we pretend we "play the game" 
    %so the game has happened and we must now implement gamesplayed
    %because we will used gamesplayed as an index into records to update
    %the result of the game
    %4: increment gamesplayed - perhaps before step 4 of putting in records

    gamesplayed(home) = gamesplayed(home)+1;
    gamesplayed(away) = gamesplayed(away)+1;

    %5: calculate actual result, put in records
    if (raw{i,4}-raw{i,6}<0) %if away-home pts is negative
        predact(i,2) = home; %home team won
        records(home,gamesplayed(home)) = 1; %add win to home 
                                    %for this game column
        %don't need to do anything to away team, stays 0
    else
        predact(i,2) = away; %away team won
        records(away,gamesplayed(away)) = 1; %add win to home 
                                    %for this game column
        %don't need to do anything to home team, stays 0
    end
    
    %6: count # of games predicted correctply
    if predact(i,1)==predact(i,2)
        correctcount = correctcount + 1;
    end
end

%display results
fprintf('NBA 2017-18 regular season win predictor based off teams'' ');
fprintf('record in last %d games:\n', windsize);
fprintf('Correctly predicted %d of %d games, or %.2f%%\n', ...
    correctcount, length(predact),100*(correctcount/length(predact)));

%% find optimal window for WL
clear
%i.e. loop through all window sizes, 1 to 82
%i realize this program is inefficient but can't be bothered to increase
%the efficiency
[num,txt,raw] = xlsread('NBATeamNames.xls'); %read in team names
TeamNames = txt(2:31,1); %30x1 cell with team names        

[num,txt,raw] = xlsread('NBA1718Season.xls'); %read in overall game log
raw = raw([2:end],:); %cut off title

ratios = zeros([1 82]); %to hold ratios of success for each window size

for h = 1:82
    records = zeros([30 82]); %create vector for 30 games' 82 games
                            %1 is win, 0 is loss
    gamesplayed = zeros([30 1]); %vector for games each team has played
    windsize = h;
    predact = zeros([length(raw) 2]); %col 1 is predicted team to win
                                  %col 2 is actual team that won
    correctcount = 0;
    for i = 1:length(raw)
        %1: identify teams
        for j = 1:length(TeamNames)
            if strcmp(raw{i,3},TeamNames{j})==1 %assign correct vising team
                away = j;
                gamelog(i,1) = away; %j gives index into TeamNames for 
                                    %correct visiting team
            end
            if strcmp(raw{i,5},TeamNames{j})==1 %same for home team
                home = j;
                gamelog(i,2) = home;
            end
        end

        %2: make window based on gamesplayed and records
        %note we haven't incremented gamesplayed yet, so 
        %values we use are COMING IN
        %also calculate win percentages for the windows
        if (gamesplayed(home)==0 || gamesplayed(away)==0)
            predact(i,1) = home; %pick home team if one team hasn't played

        else %if it's not first game can't immediately pick home
            if (gamesplayed(home)>windsize && gamesplayed(away)>windsize)
                homewind = records(home,(gamesplayed(home)-(windsize-1)):gamesplayed(home));
                %bc if we've played 11 games  & windsize 10 want window to be 2 
                %to 11
                awaywind = records(away,(gamesplayed(away)-(windsize-1)):gamesplayed(away));
            else %if window not quite big enough
                %just start from first game
                homewind = records(home,1:gamesplayed(home));
                awaywind = records(away,1:gamesplayed(away));
            end

            nwins = 0; %counter for wins
            for j = 1:length(homewind)
                if(homewind(j)==1) %if we see a win
                    nwins = nwins + 1;
                end
            end
            homepct = nwins/length(homewind);
            %same thing for away
            nwins = 0; %counter for wins
            for j = 1:length(awaywind)
                if(awaywind(j)==1) %if we see a win
                    nwins = nwins + 1;
                end
            end
            awaypct = nwins/length(awaywind);
             %3: actually predict the result and enter

            if (homepct >= awaypct) %predict home team if pcts equal or greater
                predact(i,1) = home; 
            else
              predact(i,1) = away;
            end
        end



        %at this point in time we pretend we "play the game" 
        %so the game has happened and we must now implement gamesplayed
        %because we will used gamesplayed as an index into records to update
        %the result of the game
        %4: increment gamesplayed - perhaps before step 4 of putting in records

        gamesplayed(home) = gamesplayed(home)+1;
        gamesplayed(away) = gamesplayed(away)+1;

        %5: calculate actual result, put in records
        if (raw{i,4}-raw{i,6}<0) %if away-home pts is negative
            predact(i,2) = home; %home team won
            records(home,gamesplayed(home)) = 1; %add win to home 
                                        %for this game column
            %don't need to do anything to away team, stays 0
        else
            predact(i,2) = away; %away team won
            records(away,gamesplayed(away)) = 1; %add win to home 
                                        %for this game column
            %don't need to do anything to home team, stays 0
        end

        %6: count # of games predicted correctply
        if predact(i,1)==predact(i,2)
            correctcount = correctcount + 1;
        end
    end
    ratios(h) = correctcount/length(predact);
end

[correctpct, bestratio] = max(ratios) %find best window size & how good