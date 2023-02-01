/// Slashco Stuff
/// The amount of fuel generators require.
GLOBAL_VAR_INIT(required_fuel, 4)
/// How many generators are active?
GLOBAL_VAR_INIT(active_generators, 0)
/// How many generators are required?
GLOBAL_VAR_INIT(required_generators, 2)
/// Have we spawned the generators?
GLOBAL_VAR_INIT(generators_spawned, FALSE)
/// Every possible generator spawn point.
GLOBAL_LIST_EMPTY(genstart)
/// Every possible plasma sheet spawn point.
GLOBAL_LIST_EMPTY(sheetstart)
