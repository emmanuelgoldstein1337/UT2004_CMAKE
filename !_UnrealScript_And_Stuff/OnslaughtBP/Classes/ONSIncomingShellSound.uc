//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSIncomingShellSound extends Actor;

var() float SoundLength;
var() sound ShellSound;

function StartTimer(float TimeToImpact)
{
    SetTimer(TimeToImpact - SoundLength, false);
}

function Timer()
{
    PlaySound(ShellSound, SLOT_None, 2.0, false, 500.0);
	Destroy();
}

DefaultProperties
{
    DrawType=DT_None
    bNoDelete=false
    LifeSpan=8.0
    RemoteRole=ROLE_None
    SoundLength=3.0
    ShellSound=sound'ONSBPSounds.Artillery.ShellIncoming1'
}
