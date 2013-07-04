(***********************************************************
    %%_PROJECT_NAME_%%
    Duet Project Bootstrapper
    
    This file was automatically generated with:
    duet-bootstrap
    https://sourceforge.net/p/duet-bootstrap/wiki/Home/
************************************************************)

PROGRAM_NAME='%%_PROJECT_NAME_%%'
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(*           DEVICE NUMBER DEFINITIONS GO BELOW            *)
(***********************************************************)
DEFINE_DEVICE

vdvDuet = 41000:1:0;
vdvNull	= 0:0:0;

(***********************************************************)
(*                 STARTUP CODE GOES BELOW                 *)
(***********************************************************)
DEFINE_START

define_module '%%_MODULE_NAME_%%' duet(vdvDuet);

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*          DO NOT PUT ANY CODE BELOW THIS COMMENT         *)
(***********************************************************)
