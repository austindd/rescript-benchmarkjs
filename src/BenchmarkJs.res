type benchmark
type suite

type deferred = private {
  benchmark: benchmark,
  cycle: float,
  elapsed: float,
  timeStamp: float,
}

@bs.deriving(jsConverter)
type eventType = [#abort | #complete | #cycle | #error | #reset | #start]

type event = private {
  aborted: bool,
  cancelled: bool,
  currentTarget: benchmark,
  target: benchmark,
  timeStamp: float,
  @as("type") type_: eventType,
}

let __noop1 = _ => ()
let __noop1U = (. _) => ()

let __noop0 = () => ()
let __noop0U = (. ()) => ()

type rawConfig = {
  defer: bool,
  async: bool,
  delay: float,
  initCount: int,
  maxTime: float,
  minSamples: int,
  minTime: float,
  onAbort: event => unit,
  onComplete: event => unit,
  onCycle: event => unit,
  onError: event => unit,
  onReset: event => unit,
  onStart: event => unit,
  setup: unit => unit,
  teardown: unit => unit,
}

type benchmarkConfig = {
  async: bool,
  delay: float,
  initCount: int,
  maxTime: float,
  minSamples: int,
  minTime: float,
  onAbort: event => unit,
  onComplete: event => unit,
  onCycle: event => unit,
  onError: event => unit,
  onReset: event => unit,
  onStart: event => unit,
  setup: unit => unit,
  teardown: unit => unit,
}

/**
The default options that are copied for each `Benchmark` instance, as
identified in the source code here:
https://github.com/bestiejs/benchmark.js/blob/2.0.0/benchmark.js#L2126
 */
let defaultConfig = {
  async: false,
  delay: 0.005,
  initCount: 1,
  maxTime: 5.,
  minSamples: 5,
  minTime: 0.,
  onAbort: __noop1,
  onComplete: __noop1,
  onCycle: __noop1,
  onError: __noop1,
  onReset: __noop1,
  onStart: __noop1,
  setup: __noop0,
  teardown: __noop0,
}

let rawConfig_deferred = (.
  {
    async,
    delay,
    initCount,
    maxTime,
    minSamples,
    minTime,
    onAbort,
    onComplete,
    onCycle,
    onError,
    onReset,
    onStart,
    setup,
    teardown,
  }: benchmarkConfig,
): rawConfig => {
  defer: true,
  async: async,
  delay: delay,
  initCount: initCount,
  maxTime: maxTime,
  minSamples: minSamples,
  minTime: minTime,
  onAbort: onAbort,
  onComplete: onComplete,
  onCycle: onCycle,
  onError: onError,
  onReset: onReset,
  onStart: onStart,
  setup: setup,
  teardown: teardown,
}

let rawConfig = (.
  {
    async,
    delay,
    initCount,
    maxTime,
    minSamples,
    minTime,
    onAbort,
    onComplete,
    onCycle,
    onError,
    onReset,
    onStart,
    setup,
    teardown,
  }: benchmarkConfig,
): rawConfig => {
  defer: false,
  async: async,
  delay: delay,
  initCount: initCount,
  maxTime: maxTime,
  minSamples: minSamples,
  minTime: minTime,
  onAbort: onAbort,
  onComplete: onComplete,
  onCycle: onCycle,
  onError: onError,
  onReset: onReset,
  onStart: onStart,
  setup: setup,
  teardown: teardown,
}

let defaultRawConfig = rawConfig(. defaultConfig)
let defaultRawConfig_deferred = rawConfig_deferred(. defaultConfig)

type suiteConfig = {
  onAbort: event => unit,
  onComplete: event => unit,
  onCycle: event => unit,
  onError: event => unit,
  onReset: event => unit,
  onStart: event => unit,
}

let defaultSuiteConfig = {
  onAbort: __noop1,
  onComplete: __noop1,
  onCycle: __noop1,
  onError: __noop1,
  onReset: __noop1,
  onStart: __noop1,
}

type times = {
  cycle: float,
  elapsed: float,
  period: float,
  timeStamp: float,
}

type stats = {
  deviation: float,
  mean: float,
  moe: float,
  rme: float,
  sample: array<float>,
  sem: float,
  variance: float,
}

let eventTypeFromString: string => option<eventType> = eventTypeFromJs
let eventTypeToString: eventType => string = eventTypeToJs

module Benchmark = {
  type t = benchmark

  module Internal = {
    @bs.module("benchmark") @bs.new
    external makeWithConfig: (string, (. unit) => unit, rawConfig) => t = "Benchmark"
    @bs.module("benchmark") @bs.new
    external makeWithConfig_deferred: (string, (. deferred) => unit, rawConfig) => t = "Benchmark"
  }

  let make: (~config: benchmarkConfig=?, string, (. unit) => unit) => t = (~config=?, name, fn) =>
    switch config {
    | None => Internal.makeWithConfig(name, fn, defaultRawConfig)
    | Some(c) => Internal.makeWithConfig(name, fn, rawConfig(. c))
    }

  let makeDeferred: (~config: benchmarkConfig=?, string, (. deferred) => unit) => t = (
    ~config=?,
    name,
    fn,
  ) =>
    switch config {
    | None => Internal.makeWithConfig_deferred(name, fn, defaultRawConfig_deferred)
    | Some(c) => Internal.makeWithConfig_deferred(name, fn, rawConfig_deferred(. c))
    }

  @bs.send external run: t => t = "run"
  @bs.send external clone: t => t = "clone"
  @bs.get external aborted: t => bool = "aborted"
  @bs.get external compiled: (t, . unit) => unit = "compiled"
  @bs.get external cycles: t => int = "cycles"
  @bs.get external count: t => int = "count"
  @bs.get @return(nullable) external error: t => option<Js.Exn.t> = "error"
  @bs.get external hz: t => float = "hz"
  @bs.get external running: t => bool = "running"
  @bs.get external stats: t => stats = "stats"
  @bs.get external times: t => times = "times"
  @bs.get external name: t => string = "name"
  @bs.send external abort: t => unit = "abort"
  @bs.send external toString: t => string = "toString"
  @bs.send external compare: t => int = "compare"
  @bs.send external reset: t => unit = "reset"

  type config = benchmarkConfig
  let defaultConfig = defaultConfig
}

module Event = {
  type t = event
  type eventType = eventType
  @bs.module("benchmark") @bs.scope("Benchmark") @bs.new external make: string => t = "Event"
  @bs.module("benchmark") @bs.scope("Benchmark") @bs.new external fromEvent: t => t = "Event"
  @bs.get external aborted: t => bool = "aborted"
  @bs.get external cancelled: t => bool = "cancelled"
  @bs.get external currentTarget: t => benchmark = "currentTarget"
  @bs.get external target: t => benchmark = "target"
  @bs.get external timeStamp: t => int = "timeStamp"
  @bs.get external type_: t => eventType = "type"
}

module Suite = {
  type t = suite

  module Internal = {
    @bs.module("benchmark") @bs.scope("Benchmark") @bs.new
    external makeWithConfig: (string, suiteConfig) => t = "Suite"
    @bs.send external addWithConfig: (t, string, (. unit) => unit, rawConfig) => t = "add"
    @bs.send
    external addWithConfig_deferred: (t, string, (. deferred) => unit, rawConfig) => t = "add"
    @bs.val @bs.scope(("Array", "prototype", "push"))
    external addBenchmark: (t, benchmark) => unit = "call"
    @bs.val @bs.scope(("Array", "prototype", "push"))
    external addBenchmarkArray: (t, array<benchmark>) => unit = "apply"
  }

  let make: (~config: suiteConfig=?, string) => t = (~config=?, name) =>
    switch config {
    | None => Internal.makeWithConfig(name, defaultSuiteConfig)
    | Some(c) => Internal.makeWithConfig(name, c)
    }

  let add: (~config: benchmarkConfig=?, t, string, (. unit) => unit) => t = (~config=?, suite, name, fn) =>
    switch config {
    | None => Internal.addWithConfig(suite, name, fn, defaultRawConfig)
    | Some(c) => Internal.addWithConfig(suite, name, fn, rawConfig(. c))
    }

  let addDeferred: (~config: benchmarkConfig=?, t, string, (. deferred) => unit) => t = (
    ~config=?,
    suite,
    name,
    fn,
  ) =>
    switch config {
    | None => Internal.addWithConfig_deferred(suite, name, fn, defaultRawConfig_deferred)
    | Some(c) => Internal.addWithConfig_deferred(suite, name, fn, rawConfig_deferred(. c))
    }

  @bs.send external run: t => t = "run"
  @bs.send external clone: t => t = "clone"

  @bs.send external emit: (t, eventType) => t = "emit"
  @bs.send external emitEventObject: (t, event) => t = "emit"
  @bs.send external listeners: t => array<event => unit> = "listeners"
  @bs.send external listenersByEvent: (t, eventType) => array<event => unit> = "listeners"
  @bs.send external removeListener: (t, eventType, @bs.uncurry (event => unit)) => t = "off"
  @bs.send external removeListenersByEvent: (t, eventType) => t = "off"
  @bs.send external removeAllListeners: t => t = "off"
  @bs.send external addListener: (t, eventType, @bs.uncurry (event => unit)) => t = "on"

  @bs.get @bs.scope("options") external name: t => string = "name"
  @bs.get external aborted: t => bool = "aborted"
  @bs.get external length: t => int = "length"
  @bs.get external running: t => bool = "running"

  @bs.send external onAbort: (t, @bs.as("abort") _, @bs.uncurry (event => unit)) => t = "on"
  @bs.send external onComplete: (t, @bs.as("complete") _, @bs.uncurry (event => unit)) => t = "on"
  @bs.send external onCycle: (t, @bs.as("cycle") _, @bs.uncurry (event => unit)) => t = "on"
  @bs.send external onError: (t, @bs.as("error") _, @bs.uncurry (event => unit)) => t = "on"
  @bs.send external onReset: (t, @bs.as("reset") _, @bs.uncurry (event => unit)) => t = "on"
  @bs.send external onStart: (t, @bs.as("start") _, @bs.uncurry (event => unit)) => t = "on"
  @bs.send external abort: t => t = "abort"
  @bs.send external reset: t => t = "reset"

  let addExisting: (t, benchmark) => t = (suite, benchmark) => {
    Internal.addBenchmark(suite, benchmark)
    suite
  }
  let addExistingU: (. t, benchmark) => t = (. suite, benchmark) => {
    Internal.addBenchmark(suite, benchmark)
    suite
  }

  @bs.val @bs.scope(("Array", "prototype", "slice"))
  external toArray: t => array<benchmark> = "call"
  let toList: t => list<benchmark> = suite => toArray(suite)->Belt.List.fromArray

  let fromArray: (~config: suiteConfig=?, ~name: string, array<benchmark>) => t = (
    ~config=?,
    ~name,
    benchArray,
  ) => {
    let suite = switch config {
    | None => make(name)
    | Some(opt) => make(name, ~config=opt)
    }
    Belt.Array.reduceU(benchArray, suite, addExistingU)
  }

  let fromList: (~config: suiteConfig=?, ~name: string, list<benchmark>) => t = (
    ~config=?,
    ~name,
    benchList,
  ) => {
    let suite = switch config {
    | None => make(name)
    | Some(opt) => make(name, ~config=opt)
    }
    Belt.List.reduceU(benchList, suite, addExistingU)
  }

  @bs.send external filter: (t, benchmark => bool) => t = "filter"
  @bs.send external filterByFastest: (t, @bs.as("fastest") _) => t = "filter"
  @bs.send external filterBySlowest: (t, @bs.as("slowest") _) => t = "filter"
  @bs.send external filterBySuccessful: (t, @bs.as("successful") _) => t = "filter"

  let addList: (t, list<benchmark>) => t = (suite, benchmarkList) => {
    Internal.addBenchmarkArray(suite, Belt.List.toArray(benchmarkList))
    suite
  }

  let addArray: (t, array<benchmark>) => t = (suite, benchmarkArray) => {
    Internal.addBenchmarkArray(suite, benchmarkArray)
    suite
  }

  type config = suiteConfig
  let defaultConfig = defaultSuiteConfig
}

module Utils = {
  @bs.module("benchmark") @bs.scope("Benchmark")
  external formatNumber: float => string = "formatNumber"

  /**
   * [ filterBenchmarks(benchmarkArray, predicate) ]
   * Filters an array of benchmark objects based on the return value of the predicate function.
   */
  @bs.module("benchmark") @bs.scope("Benchmark")
  external filterBenchmarks: (array<benchmark>, benchmark => bool) => array<benchmark> = "filter"

  @bs.module("benchmark") @bs.scope("Benchmark")
  external filterByFastest: (array<benchmark>, @bs.as("fastest") _) => array<benchmark> = "filter"

  @bs.module("benchmark") @bs.scope("Benchmark")
  external filterBySlowest: (array<benchmark>, @bs.as("slowest") _) => array<benchmark> = "filter"

  @bs.module("benchmark") @bs.scope("Benchmark")
  external filterBySuccessful: (array<benchmark>, @bs.as("successful") _) => array<benchmark> =
    "filter"
}

module Platform = {
  module Os = {
    /* * [ architecture ] The orchitecture of the operating system. */
    @bs.module("benchmark") @bs.scope(("Benchmark", "platform", "os")) @bs.val @return(nullable)
    external architecture: option<string> = "architecture"

    /* * [ family ] The operating system family. */
    @bs.module("benchmark") @bs.scope(("Benchmark", "platform", "os")) @bs.val @return(nullable)
    external family: option<string> = "family"

    /* * [ version ] The version name/number of the operating system. */
    @bs.module("benchmark") @bs.scope(("Benchmark", "platform", "os")) @bs.val @return(nullable)
    external version: option<string> = "version"

    /* * [ toString ] Returns the description of the OS, or an empty string if the description is unavailable. */
    @bs.module("benchmark") @bs.scope(("Benchmark", "platform", "os")) @bs.val
    external toString: unit => string = "toString"
  }

  /* * [ description ] A short string describing the host operating system and runtime platform. */
  @bs.module("benchmark") @bs.scope(("Benchmark", "platform")) @bs.val @bs.return(nullable)
  external description: option<string> = "description"

  /* * [ layout ] The host platform's JS interpreter engine. E.g. "WebKit", "V8", "SpiderMonkey". */
  @bs.module("benchmark") @bs.scope(("Benchmark", "platform")) @bs.val @bs.return(nullable)
  external layout: option<string> = "layout"

  /* * [ product ] The host device name. E.g. "iPad", "Android Galaxy S3". */
  @bs.module("benchmark") @bs.scope(("Benchmark", "platform")) @bs.val @bs.return(nullable)
  external product: option<string> = "product"

  /* * [ name ] The name of the host platfrom or browser. E.g. "Safari", "Node", "Firefox". */
  @bs.module("benchmark") @bs.scope(("Benchmark", "platform")) @bs.val @bs.return(nullable)
  external name: option<string> = "name"

  /* * [ manufacturer ] The name of the device manufacturer. E.g. "HP", "Apple", "Microsoft". */
  @bs.module("benchmark") @bs.scope(("Benchmark", "platform")) @bs.val @bs.return(nullable)
  external manufacturer: option<string> = "manufacturer"

  /* * [ prerelease ] The aplph/beta release indicator. */
  @bs.module("benchmark") @bs.scope(("Benchmark", "platform")) @bs.val @bs.return(nullable)
  external prerelease: option<string> = "prerelease"

  /* * [ version ] The version of the host operating system. */
  @bs.module("benchmark") @bs.scope(("Benchmark", "platform")) @bs.val @bs.return(nullable)
  external version: option<string> = "version"

  /* * [ toString() ] Returns the [ description ] property (string) or an empty string if the description is not available. */
  @bs.module("benchmark") @bs.scope(("Benchmark", "platform")) @bs.val
  external toString: unit => string = "toString"
}

module Support = {
  /* * [ browser ] Will be set to [ true ] if the code is running in a web browser context. */
  @bs.module("benchmark") @bs.scope(("Benchmark", "support")) external browser: bool = "browser"

  /* * [ timeout ] Will be set to [ true ] if the Timers API is made available by the host. */
  @bs.module("benchmark") @bs.scope(("Benchmark", "support")) external timeout: bool = "timeout"

  /**
   * [ decompilation ]
   * Will be set to [ true ] if the host runtime supports features that enable code decompilation.
   * If true, Benchmark.js will decompile and recompile the benchmark code between cycles in order
   * to prevent periodic runtime optimizations from interfering with benchmark stats over the course
   * of a run.
   */
  @bs.module("benchmark") @bs.scope(("Benchmark", "support"))
  external decompilation: bool = "decompilation"
}
