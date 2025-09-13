// ifdef WITH_LIPSinc

class ACTION_PlayLIPSinc extends ScriptedAction;

var(Action)		name			LIPSincAnimName;
var(Action)		float			Volume;
var(Action)		float			Radius;
var(Action)		float			Pitch;

function bool InitActionFor(ScriptedController C)
{
	C.Pawn.PlayLIPSincAnim(LIPSincAnimName, Volume, Radius, Pitch);
	return false;
}

function string GetActionString()
{
	return ActionString;
}

defaultproperties
{
	ActionString="Play LIPSinc"
	Volume=1.0
	Radius=80.0
	Pitch=1.0
}

// endif
