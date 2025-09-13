//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CicadaLockBeamEffect extends PainterBeamEffect;

simulated function Tick(float dt)
{
    if (Level.NetMode == NM_DedicatedServer)
    {
        return;
    }

	UpdateEffect(dt);

    if (TargetState == PTS_Marked)
    {
        if (Brightness == 40.0)
            PlaySound(MarkSound);
        SetBrightness( FMax(FMin(Brightness+dt*100.0, 250.0), 100.0) );
    }
    else
        SetBrightness( 40.0 );

    if (TargetState == PTS_Aquired)
        GotoState('Aquired');
    else if (TargetState == PTS_Cancelled)
        GotoState('Cancelled');

}

simulated function UpdateEffect(float dt)
{
    local Vector BeamDir;

	if (Owner!=None && ONSDualACSideGun(Owner)!=None)
	{
		StartEffect = ONSDualACSideGun(Owner).Location;
	}

    SetLocation(StartEffect);
    BeamDir = Normal(EndEffect - Location);
    SetRotation(Rotator(BeamDir));

    mSpawnVecA = EndEffect;

    if (Spot != None)
    {
        Spot.SetLocation(EndEffect - BeamDir*10.0);
    }
}

state Aquired
{
    simulated function Tick(float dt)
    {
        if (Level.NetMode != NM_DedicatedServer)
        {
        	UpdateEffect(dt);
            SetBrightness( 250.0 );
            mSizeRange[0] = FMin(mSizeRange[0]+dt*40.0, 16.0);
        }
		else
			disable('Tick');
    }

}

DefaultProperties
{

}
