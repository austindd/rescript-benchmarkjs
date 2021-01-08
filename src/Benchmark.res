type benchmark
type suite

type deferred = private {
  benchmark: benchmark,
  cycle: float,
  elapsed: float,
  timeStamp: float,
}

type event

@bs.deriving(jsConverter)
type eventType = [#abort | #complete | #cycle | #error | #reset | #start]

let __noopU = (. _) => ()
// let __noopDeferredU = (. deferred) => ()

type __config<'a> = {
  fn: 'a,
  async: bool,
  defer: bool,
  delay: float,
  id: option<string>,
  initCount: int,
  maxTime: float,
  minSamples: int,
  minTime: float,
  name: option<string>,
  onAbort: option<(. event) => unit>,
  onComplete: option<(. event) => unit>,
  onCycle: option<(. event) => unit>,
  onError: option<(. event) => unit>,
  onReset: option<(. event) => unit>,
  onStart: option<(. event) => unit>,
  setup: option<(. unit) => unit>,
  teardown: option<(. unit) => unit>,
}

type __deferredConfig = __config<(. deferred) => unit>

type __normalConfig = __config<(. unit) => unit>

type config = {
  async: bool,
  delay: float,
  id: option<string>,
  initCount: int,
  maxTime: float,
  minSamples: int,
  minTime: float,
  name: option<string>,
  onAbort: option<(. event) => unit>,
  onComplete: option<(. event) => unit>,
  onCycle: option<(. event) => unit>,
  onError: option<(. event) => unit>,
  onReset: option<(. event) => unit>,
  onStart: option<(. event) => unit>,
  setup: option<(. unit) => unit>,
  teardown: option<(. unit) => unit>,
}

/**
The default options that are copied for each `Benchmark` instance, as
identified in the source code here:
https://github.com/bestiejs/benchmark.js/blob/2.0.0/benchmark.js#L2126
 */
let defaultConfig = {
  async: false,
  delay: 0.005,
  id: None,
  initCount: 1,
  maxTime: 5.,
  minSamples: 5,
  minTime: 0.,
  name: None,
  onAbort: None,
  onComplete: None,
  onCycle: None,
  onError: None,
  onReset: None,
  onStart: None,
  setup: None,
  teardown: None,
}

let __useDeferredConfig = (
  fn: (. deferred) => unit,
  {
    async,
    delay,
    id,
    initCount,
    maxTime,
    minSamples,
    minTime,
    name,
    onAbort,
    onComplete,
    onCycle,
    onError,
    onReset,
    onStart,
    setup,
    teardown,
  }: config,
): __deferredConfig => {
  fn: fn,
  defer: true,
  async: async,
  delay: delay,
  id: id,
  initCount: initCount,
  maxTime: maxTime,
  minSamples: minSamples,
  minTime: minTime,
  name: name,
  onAbort: onAbort,
  onComplete: onComplete,
  onCycle: onCycle,
  onError: onError,
  onReset: onReset,
  onStart: onStart,
  setup: setup,
  teardown: teardown,
}

let __useNormalConfig = (
  fn: (. unit) => unit,
  {
    async,
    delay,
    id,
    initCount,
    maxTime,
    minSamples,
    minTime,
    name,
    onAbort,
    onComplete,
    onCycle,
    onError,
    onReset,
    onStart,
    setup,
    teardown,
  }: config,
): __normalConfig => {
  fn: fn,
  defer: false,
  async: async,
  delay: delay,
  id: id,
  initCount: initCount,
  maxTime: maxTime,
  minSamples: minSamples,
  minTime: minTime,
  name: name,
  onAbort: onAbort,
  onComplete: onComplete,
  onCycle: onCycle,
  onError: onError,
  onReset: onReset,
  onStart: onStart,
  setup: setup,
  teardown: teardown,
}

type suiteConfig = {
  name: option<string>,
  onAbort: option<(. event) => unit>,
  onComplete: option<(. event) => unit>,
  onCycle: option<(. event) => unit>,
  onError: option<(. event) => unit>,
  onReset: option<(. event) => unit>,
  onStart: option<(. event) => unit>,
}

let defaultSuiteConfig = {
  name: None,
  onAbort: None,
  onComplete: None,
  onCycle: None,
  onError: None,
  onReset: None,
  onStart: None,
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
    @bs.module("benchmark") @bs.new external make: (string, (. unit) => unit) => t = "Benchmark"
    @bs.module("benchmark") @bs.new
    external makeDeferred: (string, __deferredConfig) => t = "Benchmark"
    @bs.module("benchmark") @bs.new
    external makeNormal: (string, __normalConfig) => t = "Benchmark"
    @bs.get external getConfig: t => config = "options"
    @bs.get external fn: (t, . unit) => unit = "fn"
    @bs.get external setup: (t, . unit) => unit = "setup"
    @bs.get external teardown: (t, . unit) => unit = "teardown"
  }

  let make: (~name: string, ~config: config=?, (. unit) => unit) => t = (~name, ~config=?, fn) =>
    switch config {
    | None => Internal.makeNormal(name, __useNormalConfig(fn, defaultConfig))
    | Some(c) => Internal.makeNormal(name, __useNormalConfig(fn, c))
    }

  let makeDeferred: (~name: string, ~config: config=?, (. deferred) => unit) => t = (
    ~name,
    ~config=?,
    fn,
  ) =>
    switch config {
    | None => Internal.makeDeferred(name, __useDeferredConfig(fn, defaultConfig))
    | Some(c) => Internal.makeDeferred(name, __useDeferredConfig(fn, c))
    }

  @bs.send external run: t => t = "run"
  @bs.send external clone: t => t = "clone"

  @bs.get external aborted: t => bool = "aborted"
  @bs.get external compiled: (t, . unit) => unit = "compiled"
  @bs.get external cycles: t => int = "cycles"
  @bs.get external count: t => int = "count"
  @bs.get external error: t => Js.nullable<Js.Exn.t> = "error"
  @bs.get external hz: t => float = "hz"
  @bs.get external running: t => bool = "running"
  @bs.get external stats: t => stats = "stats"
  @bs.get external time: t => times = "time"
  @bs.get external name: t => string = "name"
  @bs.send external abort: t => unit = "abort"
  @bs.send external toString: t => string = "toString"
  @bs.send external compare: t => int = "compare"
  @bs.send external reset: t => unit = "reset"
}

module Deferred = {
  type t = deferred
  @bs.get external benchmark: t => benchmark = "benchmark"
  @bs.get external cycle: t => float = "cycle"
  @bs.get external elapsed: t => float = "elapsed"
  @bs.get external timeStamp: t => float = "timeStamp"
}

module Event = {
  type t = event
  type eventType = eventType

  @bs.module("benchmark") @bs.scope("Benchmark") @bs.new external make: string => t = "Event"
  @bs.module("benchmark") @bs.scope("Benchmark") @bs.new external fromEvent: t => t = "Event"
  @bs.get external aborted: t => bool = "aborted"
  @bs.get external cancelled: t => bool = "cancelled"
  @bs.get external currentTarget: t => benchmark = "currentTarget"
  @bs.get external result: t => 'a = "result"
  @bs.get external target: t => benchmark = "target"
  @bs.get external timeStamp: t => int = "timeStamp"
  @bs.get external type_: t => eventType = "type"
}

module Suite = {
  type t = suite

  module Internal = {
    @bs.module("benchmark") @bs.scope("Benchmark") @bs.new external make: string => t = "Suite"
    @bs.module("benchmark") @bs.scope("Benchmark") @bs.new
    external makeWithConfig: (string, suiteConfig) => t = "Suite"
    @bs.send external add: (t, string, (. unit) => unit) => t = "add"
    @bs.send external addNormal: (t, string, __normalConfig) => t = "add"
    @bs.send external addDeferred: (t, string, __deferredConfig) => t = "add"
    @bs.val @bs.scope(("Array", "prototype", "push"))
    external addBenchmark: (. t, benchmark) => unit = "call"
    @bs.val @bs.scope(("Array", "prototype", "push"))
    external addBenchmarkArray: (. t, array<benchmark>) => unit = "apply"
    @bs.send external run: t => t = "run"
    @bs.send external runWithConfig: (t, suiteConfig) => t = "run"
    @bs.send external clone: t => t = "clone"
    @bs.send external cloneWithConfig: (t, suiteConfig) => t = "clone"
  }

  let make: (~config: suiteConfig=?, string) => t = (~config=?, name) =>
    switch config {
    | None => Internal.make(name)
    | Some(c) => Internal.makeWithConfig(name, c)
    }

  let add: (t, ~name: string, ~config: config=?, (. unit) => unit) => t = (
    suite,
    ~name,
    ~config=?,
    fn,
  ) =>
    switch config {
    | None => Internal.add(suite, name, fn)
    | Some(c) => Internal.addNormal(suite, name, __useNormalConfig(fn, c))
    }

  let addDeferred: (t, ~name: string, ~config: config=?, (. deferred) => unit) => t = (
    suite,
    ~name,
    ~config=?,
    fn,
  ) =>
    switch config {
    | None => Internal.addDeferred(suite, name, __useDeferredConfig(fn, defaultConfig))
    | Some(c) => Internal.addDeferred(suite, name, __useDeferredConfig(fn, c))
    }

  let run: (~config: suiteConfig=?, t) => t = (~config=?, suite) =>
    switch config {
    | None => Internal.run(suite)
    | Some(c) => Internal.runWithConfig(suite, c)
    }

  let clone: (~config: suiteConfig=?, t) => t = (~config=?, suite) =>
    switch config {
    | None => Internal.clone(suite)
    | Some(c) => Internal.cloneWithConfig(suite, c)
    }

  @bs.send external emit: (t, eventType) => t = "emit"
  @bs.send external emitEventObject: (t, event) => t = "emit"
  @bs.send external listeners: t => array<(. event) => unit> = "listeners"
  @bs.send external listenersByEvent: (t, eventType) => array<(. event) => unit> = "listeners"
  @bs.send external removeListener: (t, eventType, (. event) => unit) => t = "off"
  @bs.send external removeListenersByEvent: (t, eventType) => t = "off"
  @bs.send external removeAllListeners: t => t = "off"
  @bs.send external addListener: (t, eventType, (. event) => unit) => t = "on"

  @bs.get @bs.scope("options") external name: t => string = "name"
  @bs.get external aborted: t => bool = "aborted"
  @bs.get external length: t => int = "length"
  @bs.get external running: t => bool = "running"

  let onAbort: (t, (. event) => unit) => t = (suite, handler) => addListener(suite, #abort, handler)
  let onComplete: (t, (. event) => unit) => t = (suite, handler) =>
    addListener(suite, #complete, handler)
  let onCycle: (t, (. event) => unit) => t = (suite, handler) => addListener(suite, #cycle, handler)
  let onError: (t, (. event) => unit) => t = (suite, handler) => addListener(suite, #error, handler)
  let onReset: (t, (. event) => unit) => t = (suite, handler) => addListener(suite, #reset, handler)
  let onStart: (t, (. event) => unit) => t = (suite, handler) => addListener(suite, #start, handler)

  @bs.send external abort: t => t = "abort"
  @bs.send external reset: t => t = "reset"

  let addBenchmark: (t, benchmark) => t = (suite, benchmark) => {
    Internal.addBenchmark(. suite, benchmark)
    suite
  }
  let addBenchmarkU: (. t, benchmark) => t = (. suite, benchmark) => {
    Internal.addBenchmark(. suite, benchmark)
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
    Belt.Array.reduceU(benchArray, suite, addBenchmarkU)
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
    Belt.List.reduceU(benchList, suite, addBenchmarkU)
  }

  @bs.send external filter: (t, benchmark => bool) => t = "filter"
  @bs.send external filterByFastest: (t, @bs.as("fastest") _) => t = "filter"
  @bs.send external filterBySlowest: (t, @bs.as("slowest") _) => t = "filter"
  @bs.send external filterBySuccessful: (t, @bs.as("successful") _) => t = "filter"

  let addBenchmarkList: (t, list<benchmark>) => t = (suite, benchmarkList) => {
    Internal.addBenchmarkArray(. suite, Belt.List.toArray(benchmarkList))
    suite
  }

  let addBenchmarkArray: (t, array<benchmark>) => t = (suite, benchmarkArray) => {
    Internal.addBenchmarkArray(. suite, benchmarkArray)
    suite
  }
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
