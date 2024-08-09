Class pkg.isc.perf.ui.rest.models.CoverageRoutinePaths Extends (%RegisteredObject, %JSON.Adaptor)
{

/// list of routine + test paths
Property covpaths As list Of pkg.isc.perf.ui.rest.models.CoverageRoutinePath;

/// aggregate coverage percent
Property CoveragePercent As %Decimal;

/// link to the unit test suite that were run
Property UnitTestURL As %String;

}
