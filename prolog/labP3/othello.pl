/* ------------------------------------------------------- */
%
%    D7012E Declarative languages
%    Luleå University of Technology
%
%    Student full name: <TO BE FILLED IN BEFORE THE GRADING> 
%    Student user id  : <TO BE FILLED IN BEFORE THE GRADING> 
%
/* ------------------------------------------------------- */



%do not change the follwoing line!
:- ensure_loaded('play.pl').
:- ensure_loaded('testboards.pl').
%:- ensure_loaded('stupid.pl').
:- ensure_loaded('rndBoard.pl').

% DO NOT CHANGE THIS BLOCK OF COMMENTS.
%
% /* ------------------------------------------------------ */
%               IMPORTANT! PLEASE READ THIS SUMMARY:
%       This files gives you some useful helpers (set &get).
%       Your job is to implement several predicates using
%       these helpers. Feel free to add your own helpers if
%       needed, as long as you write comments (documentation)
%       for all of them. 
%
%       Implement the following predicates at their designated
%       space in this file. You might like to have a look at
%       the file  ttt.pl  to see how the implementations is
%       done for game tic-tac-toe.
%
%          * initialize(InitialState,InitialPlyr).
%          * winner(State,Plyr) 
%          * tie(State)
%          * terminal(State) 
%          * moves(Plyr,State,MvList)
%          * nextState(Plyr,Move,State,NewState,NextPlyr)
%          * validmove(Plyr,State,Proposed)
%          * h(State,Val)  (see question 2 in the handout)
%          * lowerBound(B)
%          * upperBound(B)
% /* ------------------------------------------------------ */







% /* ------------------------------------------------------ */

% DO NOT CHANGE THIS BLOCK OF COMMENTS.
%
% We use the following State Representation: 
% [Row0, Row1 ... Rown] (ours is 6x6 so n = 5 ).
% each Rowi is a LIST of 6 elements '.' or '1' or '2' as follows: 
%    . means the position is  empty
%    1 means player one has a stone in this position
%    2 means player two has a stone in this position. 





% DO NOT CHANGE THE COMMENT BELOW.
%
% given helper: Inital state of the board

initBoard([ [.,.,.,.,.,.], 
            [.,.,.,.,.,.],
	    [.,.,1,2,.,.], 
	    [.,.,2,1,.,.], 
            [.,.,.,.,.,.], 
	    [.,.,.,.,.,.] ]).

% DO NOT CHANGE THIS BLOCK OF COMMENTS.
%
%%%%%%%%%%%%%%%%%% IMPLEMENT: initialize(...)%%%%%%%%%%%%%%%%%%%%%
%%% Using initBoard define initialize(InitialState,InitialPlyr). 
%%%  holds iff InitialState is the initial state and 
%%%  InitialPlyr is the player who moves first. 

initialize(Board, 1) :- initBoard(Board).
%initialize(Board, 1) :- testBoard1(Board).
%initialize(Board, 1) :- testBoard2(Board).
%initialize(Board, 1) :- testBoard3(Board).
%initialize(Board, 1) :- rndBoardXYZ(Board).

% DO NOT CHANGE THIS BLOCK OF COMMENTS.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%winner(...)%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% define winner(State,Plyr) here.  
%     - returns winning player if State is a terminal position and
%     Plyr has a higher score than the other player 
winner(State, Plyr) :-
    terminal(State),
    calculateStones(State, 1, P1Stones),
    calculateStones(State, 2, P2Stones),
    P1Stones \= P2Stones,
    ((P1Stones < P2Stones) -> 
        Plyr = 1
    ; 
        Plyr = 2
    ).

% DO NOT CHANGE THIS BLOCK OF COMMENTS.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%tie(...)%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% define tie(State) here. 
%    - true if terminal State is a "tie" (no winner) 
tie(State) :-
    terminal(State),
    calculateStones(State, 1, P1Stones),
    calculateStones(State, 2, P2Stones),
    P1Stones == P2Stones.

% DO NOT CHANGE THIS BLOCK OF COMMENTS.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%terminal(...)%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% define terminal(State). 
%   - true if State is a terminal   
terminal(State) :-
    moves(1, State, P1Moves),
    moves(2, State, P2Moves),
    member(n, P1Moves),
    member(n, P2Moves).

% DO NOT CHANGE THIS BLOCK OF COMMENTS.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%showState(State)%%%%%%%%%%%%%%%%%%%%%%%%%%
%% given helper. DO NOT  change this. It's used by play.pl
%%

showState( G ) :- 
	printRows( G ). 
 
printRows( [] ). 
printRows( [H|L] ) :- 
	printList(H),
	nl,
	printRows(L). 

printList([]).
printList([H | L]) :-
	write(H),
	write(' '),
	printList(L).

% DO NOT CHANGE THIS BLOCK OF COMMENTS.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%moves(Plyr,State,MvList)%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
%% define moves(Plyr,State,MvList). 
%   - returns list MvList of all legal moves Plyr can make in State
%
moves(Plyr, State, MvList) :-
    checkMoves(Plyr, State, [0, 0], List),
    sort(List, SortedList),
    length(SortedList, Length),
    ((Length == 0) -> 
        MvList = [n]
    ;
        MvList = SortedList
    ).

% Find all moves in the state
checkMoves(_, _, [_,6], []) :- !.
checkMoves(Plyr, State, [X, Y], Return) :-
    X < 6,
    Y < 6,
    NextY is Y + 1,
    checkMovesRow(Plyr, State, [X, Y], RecReturn), 
    checkMoves(Plyr, State, [X, NextY], RecReturn2),
    append(RecReturn2, RecReturn, Return).

% Find all possible moves in a row       
checkMovesRow(_, _, [6, _], []).
checkMovesRow(Plyr, State, [X, Y], Return) :-
    X < 6,
    NextX is X + 1,
    (validmove(Plyr, State, [X, Y]) ->
        checkMovesRow(Plyr, State, [NextX, Y], RecReturn),
        append(RecReturn, [[X, Y]], Return)
    ;
        checkMovesRow(Plyr, State, [NextX, Y], Return)
    ).

% DO NOT CHANGE THIS BLOCK OF COMMENTS.
%
%%%%%%%%%%%%%%nextState(Plyr,Move,State,NewState,NextPlyr)%%%%%%%%%%%%%%%%%%%%
%% 
%% define nextState(Plyr,Move,State,NewState,NextPlyr). 
%   - given that Plyr makes Move in State, it determines NewState (i.e. the next 
%     state) and NextPlayer (i.e. the next player who will move).
%
nextState(Plyr, Move, State, NewState, NextPlyr) :-
    nextPlayer(Plyr, NextPlyr),
    Move = n,
    NewState = State.

nextState(Plyr, Move, State, NewState, NextPlyr) :-
    flipS(Plyr, Move, State, StateS),
    flipSW(Plyr, Move, StateS, StateSW),
    flipW(Plyr, Move, StateSW, StateW),
    flipNW(Plyr, Move, StateW, StateNW),
    flipN(Plyr, Move, StateNW, StateN),
    flipNE(Plyr, Move, StateN, StateNE),
    flipE(Plyr, Move, StateNE, StateE),
    flipSE(Plyr, Move, StateE, NewState),
    nextPlayer(Plyr, NextPlyr).

nextPlayer(1,2).
nextPlayer(2,1).

% Generalized function for use with flipX
flip(Plyr, Coord, State, NewState, _) :-
    playerAtPos(Plyr, State, Coord),
    NewState = State.
flip(Plyr, [X, Y], State, NewState, [DeltaX, DeltaY]) :-
    deltaPoints([X, Y], [DeltaX, DeltaY], [NextX, NextY]),
    otherPlayerAtPos(Plyr, State, [X, Y]),
    set(State, SetState, [X, Y], Plyr),
    flip(Plyr, [NextX, NextY], SetState, NewState, [DeltaX, DeltaY]).

% Flips stones towards a direction X if the move is valid
flipS(Plyr, [X, Y], State, NewState) :-
    (validMoveFromS(Plyr, State, [X, Y]) ->
        set(State, NextState, [X, Y], Plyr),
        deltaPoints([X, Y], [0, 1], [SX, SY]),
        flip(Plyr, [SX, SY], NextState, NewState, [0,1])
    ;
        NewState = State
    ).

flipSW(Plyr, [X, Y], State, NewState) :-
    (validMoveFromSW(Plyr, State, [X, Y]) ->
        set(State, NextState, [X, Y], Plyr),
        deltaPoints([X, Y], [-1, 1], [SWX, SWY]),
        flip(Plyr, [SWX, SWY], NextState, NewState, [-1, 1])
    ;
        NewState = State
    ).

flipW(Plyr, [X, Y], State, NewState) :-
    (validMoveFromW(Plyr, State, [X, Y]) ->
        set(State, NextState, [X, Y], Plyr),
        deltaPoints([X, Y], [-1, 0], [WX, WY]),
        flip(Plyr, [WX, WY], NextState, NewState, [-1,0])
    ;
        NewState = State
    ).

flipNW(Plyr, [X, Y], State, NewState) :-
    (validMoveFromNW(Plyr, State, [X, Y]) ->
        set(State, NextState, [X, Y], Plyr),
        deltaPoints([X, Y], [-1, -1], [NWX, NWY]),
        flip(Plyr, [NWX, NWY], NextState, NewState, [-1, -1])
    ;
        NewState = State
    ).


flipN(Plyr, [X, Y], State, NewState) :-
    (validMoveFromN(Plyr, State, [X, Y]) ->
        set(State, NextState, [X, Y], Plyr),
        deltaPoints([X, Y], [0, -1], [NX, NY]),
        flip(Plyr, [NX, NY], NextState, NewState, [0, - 1])
    ;
        NewState = State
    ).

flipNE(Plyr, [X, Y], State, NewState) :-
    (validMoveFromNE(Plyr, State, [X, Y]) ->
        set(State, NextState, [X, Y], Plyr),
        deltaPoints([X, Y], [1, -1], [NEX, NEY]),
        flip(Plyr, [NEX, NEY], NextState, NewState, [1, -1])
    ;
        NewState = State
    ).

flipE(Plyr, [X, Y], State, NewState) :-
    (validMoveFromE(Plyr, State, [X, Y]) ->
        set(State, NextState, [X, Y], Plyr),
        deltaPoints([X, Y], [1, 0], [EX, EY]),
        flip(Plyr, [EX, EY], NextState, NewState, [1, 0])
    ;
        NewState = State
    ).

flipSE(Plyr, [X, Y], State, NewState) :-
    (validMoveFromSE(Plyr, State, [X, Y]) ->
        set(State, NextState, [X, Y], Plyr),
        deltaPoints([X, Y], [1, 1], [SEX, SEY]),
        flip(Plyr, [SEX, SEY], NextState, NewState, [1, 1])
    ;
        NewState = State
    ).

% DO NOT CHANGE THIS BLOCK OF COMMENTS.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%validmove(Plyr,State,Proposed)%%%%%%%%%%%%%%%%%%%%
%% 
%% define validmove(Plyr,State,Proposed). 
%   - true if Proposed move by Plyr is valid at State.
validmove(Plyr, State, n) :-
    moves(Plyr, State, Moves),
    member(n, Moves).
validmove(Plyr, State, [X, Y]) :-
    emptySquare(State, [X, Y]),
    (
        validMoveFromS(Plyr, State, [X, Y]);
        validMoveFromSW(Plyr, State, [X, Y]);
        validMoveFromW(Plyr, State, [X, Y]);
        validMoveFromNW(Plyr, State, [X, Y]);
        validMoveFromN(Plyr, State, [X, Y]);
        validMoveFromNE(Plyr, State, [X, Y]);
        validMoveFromE(Plyr, State, [X, Y]);
        validMoveFromSE(Plyr, State, [X, Y])
    ).

% Check if the move is valid from any of X directions
% First by checking if the other player has its square at next pos
% then by checking recursively that they have more stones in that dir
% Stops when it finds that the player has a stone somewhere.
validMoveFromSE(Plyr, State, [X, Y]) :-
    canMove(Plyr, State, [X, Y], [1, 1]).

validMoveFromS(Plyr, State, [X, Y]) :-
    canMove(Plyr, State, [X, Y], [0, 1]).

validMoveFromSW(Plyr, State, [X, Y]) :-
    canMove(Plyr, State, [X, Y], [-1, 1]).

validMoveFromW(Plyr, State, [X, Y]) :-
    canMove(Plyr, State, [X, Y], [-1, 0]).

validMoveFromNW(Plyr, State, [X, Y]) :-
    canMove(Plyr, State, [X, Y], [-1, -1]).

validMoveFromN(Plyr, State, [X, Y]) :-
    canMove(Plyr, State, [X, Y], [0, -1]).

validMoveFromNE(Plyr, State, [X, Y]) :-
    canMove(Plyr, State, [X, Y], [1, -1]).

validMoveFromE(Plyr, State, [X, Y]) :-
    canMove(Plyr, State, [X, Y], [1, 0]). 

% Checks if a move is possible from direction X
canMove(Plyr, State, [X, Y], [DeltaX, DeltaY]) :-
    deltaPoints([X, Y], [DeltaX, DeltaY], [NewX, NewY]),
    deltaPoints([NewX, NewY], [DeltaX, DeltaY], [NewX2, NewY2]),
    otherPlayerAtPos(Plyr, State, [NewX, NewY]),
    playerAtPos(Plyr, State, [NewX2, NewY2]),
    !.
canMove(Plyr, State, [X, Y], [DeltaX, DeltaY]) :-
    deltaPoints([X, Y], [DeltaX, DeltaY], [NewX, NewY]),
    otherPlayerAtPos(Plyr, State, [NewX, NewY]),
    canMove(Plyr, State, [NewX, NewY], [DeltaX, DeltaY]).


% DO NOT CHANGE THIS BLOCK OF COMMENTS.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%h(State,Val)%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
%% define h(State,Val). 
%   - given State, returns heuristic Val of that state
%   - larger values are good for Max, smaller values are good for Min
%   NOTE1. If State is terminal h should return its true value.
%   NOTE2. If State is not terminal h should be an estimate of
%          the value of state (see handout on ideas about
%          good heuristics.
% h for tie states
h(State, Val) :-
    tie(State),
    Val = 0.

% h for non-terminal and terminal states excl ties
h(State, Val) :-
    calculateStones(State, 1, P1Score),
    calculateStones(State, 2, P2Score),
    Val is P2Score - P1Score.

% Winning states
h(State, Val) :-
    winner(State, 1),
    Val = -39.

h(State, Val) :-
    winner(State, 2),
    Val = 39.


% DO NOT CHANGE THIS BLOCK OF COMMENTS.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%lowerBound(B)%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
%% define lowerBound(B).  
%   - returns a value B that is less than the actual or heuristic value
%     of all states.
lowerBound(-40).

% DO NOT CHANGE THIS BLOCK OF COMMENTS.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%upperBound(B)%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
%% define upperBound(B). 
%   - returns a value B that is greater than the actual or heuristic value
%     of all states.
upperBound(40).

% DO NOT CHANGE THIS BLOCK OF COMMENTS.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                       %
%                                                                       %
%                Given   UTILITIES                                      %
%                   do NOT change these!                                %
%                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get(Board, Point, Element)
%    : get the contents of the board at position column X and row Y
% set(Board, NewBoard, [X, Y], Value):
%    : set Value at column X row Y in Board and bind resulting grid to NewBoard
%
% The origin of the board is in the upper left corner with an index of
% [0,0], the upper right hand corner has index [5,0], the lower left
% hand corner has index [0,5], the lower right hand corner has index
% [5,5] (on a 6x6 board).
%
% Example
% ?- initBoard(B), showState(B), get(B, [2,3], Value). 
%. . . . . . 
%. . . . . . 
%. . 1 2 . . 
%. . 2 1 . . 
%. . . . . . 
%. . . . . . 
%
%B = [['.', '.', '.', '.', '.', '.'], ['.', '.', '.', '.', '.', '.'], 
%     ['.', '.', 1, 2, '.', '.'], ['.', '.', 2, 1, '.'|...], 
%     ['.', '.', '.', '.'|...], ['.', '.', '.'|...]]
%Value = 2 
%Yes
%?- 
%
% Setting values on the board
% ?- initBoard(B),  showState(B),set(B, NB1, [2,4], 1),
%         set(NB1, NB2, [2,3], 1),  showState(NB2). 
%
% . . . . . . 
% . . . . . . 
% . . 1 2 . . 
% . . 2 1 . . 
% . . . . . . 
% . . . . . .
% 
% . . . . . . 
% . . . . . . 
% . . 1 2 . . 
% . . 1 1 . . 
% . . 1 . . . 
% . . . . . .
%
%B = [['.', '.', '.', '.', '.', '.'], ['.', '.', '.', '.', '.', '.'], ['.', '.', 
%1, 2, '.', '.'], ['.', '.', 2, 1, '.'|...], ['.', '.', '.', '.'|...], ['.', '.',
% '.'|...]]
%NB1 = [['.', '.', '.', '.', '.', '.'], ['.', '.', '.', '.', '.', '.'], ['.', '.'
%, 1, 2, '.', '.'], ['.', '.', 2, 1, '.'|...], ['.', '.', 1, '.'|...], ['.', '.
%', '.'|...]]
%NB2 = [['.', '.', '.', '.', '.', '.'], ['.', '.', '.', '.', '.', '.'], ['.', '.'
%, 1, 2, '.', '.'], ['.', '.', 1, 1, '.'|...], ['.', '.', 1, '.'|...], ['.', 
%'.', '.'|...]]

% DO NOT CHANGE THIS BLOCK OF COMMENTS.
%
% get(Board, Point, Element): get the value of the board at position
% column X and row Y (indexing starts at 0).
% Do not change get:

get( Board, [X, Y], Value) :- 
	nth0( Y, Board, ListY), 
	nth0( X, ListY, Value).

% DO NOT CHANGE THIS BLOCK OF COMMENTS.
%
% set( Board, NewBoard, [X, Y], Value): set the value of the board at position
% column X and row Y to Value (indexing starts at 0). Returns the new board as
% NewBoard. Do not change set:

set( [Row|RestRows], [NewRow|RestRows], [X, 0], Value) :-
    setInList(Row, NewRow, X, Value). 

set( [Row|RestRows], [Row|NewRestRows], [X, Y], Value) :-
    Y > 0, 
    Y1 is Y-1, 
    set( RestRows, NewRestRows, [X, Y1], Value). 

% DO NOT CHANGE THIS BLOCK OF COMMENTS.
%
% setInList( List, NewList, Index, Value): given helper to set. Do not
% change setInList:

setInList( [_|RestList], [Value|RestList], 0, Value). 

setInList( [Element|RestList], [Element|NewRestList], Index, Value) :- 
	Index > 0, 
	Index1 is Index-1, 
	setInList( RestList, NewRestList, Index1, Value). 

% Get all stone locations for a player
% I'm not proud of this, but it works
getStones(State, Plyr, Stones) :-
    getStonesHelper(State, Plyr, 0, Stones).

getStonesHelper([],_,_,[]).
getStonesHelper([Row|List], Plyr, Y, Return) :-
    NewY is Y + 1,
    getStonesInRow(Row, Plyr, 0, Y, RowReturn),
    getStonesHelper(List, Plyr, NewY, RecReturn),
    append(RecReturn, RowReturn, Return).

% Get stones in a row
getStonesInRow([], _, _, _, []).
getStonesInRow([Val|Row], Plyr, X, Y, Return) :- 
    NewX is X + 1,
    ((Val = Plyr) -> 
        getStonesInRow(Row, Plyr, NewX, Y, List), 
        append(List, [[X, Y]], Return)
    ;  
        getStonesInRow(Row, Plyr, NewX, Y, List),
        append(List, [], Return)
    ).

% Calculate Number of stones for a Player in State
calculateStones([],_,0).
calculateStones([Row|List], Plyr, Number) :-
    calcStonesInRow(Row, Plyr, RowNum),
    calculateStones(List, Plyr, ListNum),
    Number is RowNum + ListNum.

% Calculate how many stones a player has at a row
calcStonesInRow([],_,0).
calcStonesInRow(Row, Plyr, Number) :-
    include(=(Plyr), Row, List),
    length(List, Number).

% Check if player is at position
playerAtPos(Plyr, State, [X, Y]) :-
    get(State, [X, Y], Val),
    Plyr = Val.

% Check that the X and Y are within the board
checkConstraints(X, Y) :-
    X >= 0,
    X < 6,
    Y >= 0,
    Y < 6.

deltaPoints([X, Y], [DeltaX, DeltaY], [NewX, NewY]) :-
    NewX is X + DeltaX,
    NewY is Y + DeltaY,
    checkConstraints(NewX, NewY).

% Check if other player is at position
otherPlayerAtPos(Plyr, State, [X, Y]) :-
    get(State, [X, Y], Val),
    Val \= Plyr,
    Val \= '.'.

emptySquare(State, [X, Y]) :-
    get(State, [X, Y], Val),
    Val = '.'.

%% Tests
test1 :-
    testBoard1(B1),
    moves(1, B1, L1),
    moves(2, B1, L2),
    write("P1: "),
    writeln(L1),
    write("P2: "),
    writeln(L2).

testStateBoard1(Plyr, Move) :-
    testBoard1(B1),
    nextState(Plyr, Move, B1, NextState, _),
    showState(B1),
    writeln("------------"),
    showState(NextState).

test2 :-
    testBoard2(B2),
    moves(1, B2, L1),
    moves(2, B2, L2),
    write("P1: "),
    writeln(L1),
    write("P2: "),
    writeln(L2).

test3 :-
    testBoard3(B3),
    moves(1, B3, L1),
    moves(2, B3, L2),
    write("P1: "),
    writeln(L1),
    write("P2: "),
    writeln(L2).



