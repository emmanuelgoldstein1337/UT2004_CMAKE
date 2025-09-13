//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MutBonusVehicles extends Mutator;

var array<string> ArcticStrongholdFactories;
var array<string> AridoomFactories;
var array<string> AscendancyFactories;
var array<string> CrossfireFactories;
var array<string> DawnFactories;
var array<string> DriaFactories;
var array<string> FrostbiteFactories;
var array<string> PrimevalFactories;
var array<string> RedPlanetFactories;
var array<string> SeveranceFactories;
var array<string> TorlanFactories;

var array< class<ONSVehicle> > ArcticStrongholdReplacements;
var array< class<ONSVehicle> > AridoomReplacements;
var array< class<ONSVehicle> > AscendancyReplacements;
var array< class<ONSVehicle> > CrossfireReplacements;
var array< class<ONSVehicle> > DawnReplacements;
var array< class<ONSVehicle> > DriaReplacements;
var array< class<ONSVehicle> > FrostbiteReplacements;
var array< class<ONSVehicle> > PrimevalReplacements;
var array< class<ONSVehicle> > RedPlanetReplacements;
var array< class<ONSVehicle> > SeveranceReplacements;
var array< class<ONSVehicle> > TorlanReplacements;

function PostBeginPlay()
{
	local ONSVehicleFactory Factory;
	local array<string> MapFactories;
	local array< class<ONSVehicle> > MapReplacements;
	local string MapName, Garbage;
	local int i;

    Divide(Level.GetLocalURL(), "?", MapName, Garbage);
    Divide(MapName, "/", Garbage, MapName);

    log("GetLocalURL: "$Level.GetLocalURL());
    log("MapName: "$MapName);

	switch(MapName)
	{
        case "ONS-ArcticStronghold":    MapFactories = ArcticStrongholdFactories;
                                        MapReplacements = ArcticStrongholdReplacements;
                                        break;

        case "ONS-Aridoom":             MapFactories = AridoomFactories;
                                        MapReplacements = AridoomReplacements;
                                        break;

        case "ONS-Ascendancy":          MapFactories = AscendancyFactories;
                                        MapReplacements = AscendancyReplacements;
                                        break;

        case "ONS-Crossfire":           MapFactories = CrossfireFactories;
                                        MapReplacements = CrossfireReplacements;
                                        break;

        case "ONS-Dawn":                MapFactories = DawnFactories;
                                        MapReplacements = DawnReplacements;
                                        break;

        case "ONS-Dria":                MapFactories = DriaFactories;
                                        MapReplacements = DriaReplacements;
                                        break;

        case "ONS-Frostbite":           MapFactories = FrostbiteFactories;
                                        MapReplacements = FrostbiteReplacements;
                                        break;

        case "ONS-Primeval":            MapFactories = PrimevalFactories;
                                        MapReplacements = PrimevalReplacements;
                                        break;

        case "ONS-RedPlanet":           MapFactories = RedPlanetFactories;
                                        MapReplacements = RedPlanetReplacements;
                                        break;

        case "ONS-Severance":           MapFactories = SeveranceFactories;
                                        MapReplacements = SeveranceReplacements;
                                        break;

        case "ONS-Torlan":              MapFactories = TorlanFactories;
                                        MapReplacements = TorlanReplacements;
                                        break;
    }

	foreach AllActors( class 'ONSVehicleFactory', Factory )
	{
        for (i=0; i<MapFactories.Length; i++)
        {
            if (String(Factory.Name) == MapFactories[i])
                Factory.VehicleClass = MapReplacements[i];
        }
	}

	Super.PostBeginPlay();
}

DefaultProperties
{
    bAddToServerPackages=True

    ArcticStrongholdFactories(0)="ONSTankFactory2"
    ArcticStrongholdReplacements(0)=class'ONSShockTank'
    ArcticStrongholdFactories(1)="ONSTankFactory1"
    ArcticStrongholdReplacements(1)=class'ONSShockTank'
    ArcticStrongholdFactories(2)="ONSRVFactory5"
    ArcticStrongholdReplacements(2)=class'ONSArtillery'
    ArcticStrongholdFactories(3)="ONSRVFactory6"
    ArcticStrongholdReplacements(3)=class'ONSArtillery'
    ArcticStrongholdFactories(4)="ONSAttackCraftFactory0"
    ArcticStrongholdReplacements(4)=class'ONSDualAttackCraft'

    AridoomFactories(0)="ONSTankFactory0"
    AridoomReplacements(0)=class'ONSShockTank'
    AridoomFactories(1)="ONSTankFactory1"
    AridoomReplacements(1)=class'ONSShockTank'
    AridoomFactories(2)="ONSTankFactory2"
    AridoomReplacements(2)=class'ONSArtillery'

    AscendancyFactories(0)="ONSTankFactory6"
    AscendancyReplacements(0)=class'ONSShockTank'
    AscendancyFactories(1)="ONSPRVFactory0"
    AscendancyReplacements(1)=class'ONSArtillery'
    AscendancyFactories(2)="ONSRVFactory5"
    AscendancyReplacements(2)=class'ONSDualAttackCraft'
    AscendancyFactories(3)="ONSTankFactory0"
    AscendancyReplacements(3)=class'ONSShockTank'
    AscendancyFactories(4)="ONSPRVFactory1"
    AscendancyReplacements(4)=class'ONSArtillery'
    AscendancyFactories(5)="ONSRVFactory11"
    AscendancyReplacements(5)=class'ONSDualAttackCraft'

    CrossfireFactories(0)="ONSHoverCraftFactory8"
    CrossfireReplacements(0)=class'ONSDualAttackCraft'
    CrossfireFactories(1)="ONSPRVFactory7"
    CrossfireReplacements(1)=class'ONSShockTank'
    CrossfireFactories(2)="ONSHoverCraftFactory9"
    CrossfireReplacements(2)=class'ONSDualAttackCraft'
    CrossfireFactories(3)="ONSPRVFactory10"
    CrossfireReplacements(3)=class'ONSShockTank'
    CrossfireFactories(4)="ONSRVFactory12"
    CrossfireReplacements(4)=class'ONSHoverTank'
    CrossfireFactories(5)="ONSPRVFactory1"
    CrossfireReplacements(5)=class'ONSArtillery'
    CrossfireFactories(6)="ONSPRVFactory6"
    CrossfireReplacements(6)=class'ONSArtillery'

    DawnFactories(0)="ONSAttackCraftFactory1"
    DawnReplacements(0)=class'ONSDualAttackCraft'
    DawnFactories(1)="ONSAttackCraftFactory0"
    DawnReplacements(1)=class'ONSDualAttackCraft'
    DawnFactories(2)="ONSTankFactory3"
    DawnReplacements(2)=class'ONSArtillery'
    DawnFactories(3)="ONSTankFactory4"
    DawnReplacements(3)=class'ONSArtillery'
    DawnFactories(4)="ONSRVFactory1"
    DawnReplacements(4)=class'ONSHoverBike'
    DawnFactories(5)="ONSRVFactory0"
    DawnReplacements(5)=class'ONSShockTank'
    DawnFactories(6)="ONSHoverCraftFactory3"
    DawnReplacements(6)=class'ONSShockTank'

    DriaFactories(0)="ONSPRVFactory3"
    DriaReplacements(0)=class'ONSShockTank'
    DriaFactories(1)="ONSPRVFactory5"
    DriaReplacements(1)=class'ONSShockTank'
    DriaFactories(2)="ONSAttackCraftFactory10"
    DriaReplacements(2)=class'ONSDualAttackCraft'
    DriaFactories(3)="ONSAttackCraftFactory14"
    DriaReplacements(3)=class'ONSDualAttackCraft'
    DriaFactories(4)="ONSTankFactory1"
    DriaReplacements(4)=class'ONSArtillery'
    DriaFactories(5)="ONSTankFactory3"
    DriaReplacements(5)=class'ONSArtillery'

    FrostbiteFactories(0)="ONSRVFactory3"
    FrostbiteReplacements(0)=class'ONSShockTank'
    FrostbiteFactories(1)="ONSRVFactory5"
    FrostbiteReplacements(1)=class'ONSShockTank'
    FrostbiteFactories(2)="ONSHoverCraftFactory3"
    FrostbiteReplacements(2)=class'ONSDualAttackCraft'

    PrimevalFactories(0)="ONSTankFactory0"
    PrimevalReplacements(0)=class'ONSShockTank'

    RedPlanetFactories(0)="ONSAttackCraftFactory5"
    RedPlanetReplacements(0)=class'ONSDualAttackCraft'
    RedPlanetFactories(1)="ONSAttackCraftFactory0"
    RedPlanetReplacements(1)=class'ONSDualAttackCraft'
    RedPlanetFactories(2)="ONSRVFactory1"
    RedPlanetReplacements(2)=class'ONSShockTank'
    RedPlanetFactories(3)="ONSRVFactory5"
    RedPlanetReplacements(3)=class'ONSShockTank'
    RedPlanetFactories(4)="ONSHoverCraftFactory10"
    RedPlanetReplacements(4)=class'ONSArtillery'

    SeveranceFactories(0)="ONSPRVFactory3"
    SeveranceReplacements(0)=class'ONSArtillery'
    SeveranceFactories(1)="ONSPRVFactory9"
    SeveranceReplacements(1)=class'ONSArtillery'
    SeveranceFactories(2)="ONSAttackCraftFactory0"
    SeveranceReplacements(2)=class'ONSDualAttackCraft'
    SeveranceFactories(3)="ONSAttackCraftFactory1"
    SeveranceReplacements(3)=class'ONSDualAttackCraft'
    SeveranceFactories(4)="ONSRVFactory21"
    SeveranceReplacements(4)=class'ONSShockTank'
    SeveranceFactories(5)="ONSRVFactory3"
    SeveranceReplacements(5)=class'ONSShockTank'

    TorlanFactories(0)="ONSAttackCraftFactory1"
    TorlanReplacements(0)=class'ONSDualAttackCraft'
    TorlanFactories(1)="ONSAttackCraftFactory2"
    TorlanReplacements(1)=class'ONSDualAttackCraft'
    TorlanFactories(2)="ONSRVFactory0"
    TorlanReplacements(2)=class'ONSShockTank'
    TorlanFactories(3)="ONSRVFactory1"
    TorlanReplacements(3)=class'ONSShockTank'
    TorlanFactories(4)="ONSPRVFactory2"
    TorlanReplacements(4)=class'ONSArtillery'
}
