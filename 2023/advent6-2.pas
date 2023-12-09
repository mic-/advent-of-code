{
    Advents of Code 2023 - Day 6: Wait For It, part 2
    Mic, 2023
}

program advent6_2(input, output, stdErr);
{$mode objFPC}

uses strutils, sysutils;

// E.g. 'Time:      7  15   30' -> 71530
function GetMergedNumber(inputLine: String): Int64;
var
    parts: Array of AnsiString;
    merged: String = '';
    i: Integer;
begin
    parts := SplitString(inputLine, ' ');
    for i := 1 to Length(parts) do
    begin
        if Length(parts[i]) > 0
        then merged := merged + parts[i];
    end;
    GetMergedNumber := StrToInt64(merged);
end;


// Only returns the positive root
function SolveQuadratic(p: Double; q: Double): Double;
var
    pHalf: Double = 0;
begin
    pHalf := p / 2;
    SolveQuadratic := Sqrt((pHalf*pHalf) - q) - pHalf;
end;


function WaysToWin(raceTime: Int64; distanceToBeat: Int64): Int64;
var
    optimalPressTime: Double = 0;
    maxDistance: Double = 0;
    shortestPressTimeToWin: Double = 0;
    longestPressTimeToWin: Double = 0;
begin
    optimalPressTime := raceTime / 2.0;
    maxDistance := optimalPressTime * (raceTime - optimalPressTime);
    shortestPressTimeToWin := optimalPressTime - SolveQuadratic(1.0, -(maxDistance - (distanceToBeat + 1)));
    longestPressTimeToWin := optimalPressTime + (optimalPressTime - shortestPressTimeToWin);
    WaysToWin := Round(longestPressTimeToWin) + 1 - Round(shortestPressTimeToWin);
end;


var
    inputFile: Text;
    timeString: String;
    distanceString: String;

begin
    if ParamCount() = 0 then
    begin
        writeln('Usage: advent6-2 input.txt');
        exit;
    end;

    Writeln('The input filename is ', paramStr(1));
    AssignFile(inputFile, paramStr(1));
    Reset(inputFile);
    Readln(inputFile, timeString);
    Readln(inputFile, distanceString);
    Close(inputFile);

    Writeln('Number of ways to win the race: ', WaysToWin(GetMergedNumber(timeString), GetMergedNumber(distanceString)));
end.