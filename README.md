# nba-gamePredictor
NBA game predictor based on team win-loss record

This was the final project for my Experimentation for Engineering Design course. I chose to create an NBA game predictor in MATLAB that used teams' previous performances to predict future game outcomes. Though this was a group project, everything in this repository (excluding the project report linked in this file) is solely my work.

All the files beginning with NBA are data I pre-processed using 2017-18 season statistics from https://www.basketball-reference.com/.

The "E14_Final.m" uses a simple algorithm that compares teams' win-loss records and picks the team with the better record. It runs this on the entire 2017-18 season data and displays the percentage of games predicted correctly.

"E14_Final_5Factors.m" is a script that uses basic statistics to calculate "5 factors," or crucial basketball statistics that theoretically predict a team's success, over a certain window. This data was used (elsewhere) in a linear regression predictor that my group also worked on.

More information about the predictor using linear regression and the project in general can be found in our group's project report below:

https://docs.google.com/document/d/1PR2n0rYgYv1CB7cj8NAedTV9pvnwq33tk-7T8ioopZQ/edit?usp=sharing
