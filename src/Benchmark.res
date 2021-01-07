type benchmark
type suite
type suiteOptions
type deferred
type event
type testFn = (. unit) => unit
type setupFn = (. unit) => unit
type teardownFn = (. unit) => unit
type eventHandler = (. event) => unit
type eventType = [#abort | #complete | #cycle | #error | #reset | #start]
type options
type times
type stats
type platform
type support

let eventTypeFromString: string => option<eventType> = str =>
  switch str {
  | "abort" => Some(#abort)
  | "complete" => Some(#complete)
  | "cycle" => Some(#cycle)
  | "error" => Some(#error)
  | "reset" => Some(#reset)
  | "start" => Some(#start)
  | _ => None
  }

let eventTypeToString: eventType => string = eventType =>
  switch eventType {
  | #abort => "abort"
  | #complete => "complete"
  | #cycle => "cycle"
  | #error => "error"
  | #reset => "reset"
  | #start => "start"
  }

module Benchmark = {
  type t = benchmark

  module Internal = {
    @bs.module("benchmark") @bs.new external make: (string, testFn) => t = "Benchmark"
    @bs.module("benchmark") @bs.new
    external makeWithOptions: (string, testFn, options) => t = "Benchmark"
    @bs.send external run: t => t = "run"
    @bs.send external runWithOptions: (t, options) => t = "run"
    @bs.send external clone: t => t = "clone"
    @bs.send external cloneWithOptions: (t, options) => t = "clone"
  }

  let make: (~options: options=?, string, testFn) => t = (~options=?, name, fn) =>
    switch options {
    | None => Internal.make(name, fn)
    | Some(opt) => Internal.makeWithOptions(name, fn, opt)
    }

  let run: (~options: options=?, t) => t = (~options=?, benchmark) =>
    switch options {
    | None => Internal.run(benchmark)
    | Some(opt) => Internal.runWithOptions(benchmark, opt)
    }

  let clone: (~options: options=?, t) => t = (~options=?, benchmark) =>
    switch options {
    | None => Internal.clone(benchmark)
    | Some(opt) => Internal.cloneWithOptions(benchmark, opt)
    }

  @bs.get external aborted: t => bool = "aborted"
  @bs.get external compiled: t => testFn = "compiled"
  @bs.get external cycles: t => int = "cycles"
  @bs.get external count: t => int = "count"
  @bs.get external error: t => Js.nullable<Js.Exn.t> = "error"
  @bs.get external fn: t => testFn = "fn"
  @bs.get external hz: t => float = "hz"
  @bs.get external running: t => bool = "running"
  @bs.get external setup: t => setupFn = "setup"
  @bs.get external stats: t => stats = "stats"
  @bs.get external teardown: t => teardownFn = "teardown"
  @bs.get external time: t => times = "time"
  @bs.get external name: t => string = "name"
  @bs.get external options: t => options = "options"
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

module Options = {
  type t = options

  @bs.obj
  external make: (
    ~async: bool=?,
    ~defer: bool=?,
    ~delay: float=?,
    ~id: string=?,
    ~initCount: int=?,
    ~maxTime: float=?,
    ~minSamples: int=?,
    ~minTime: float=?,
    ~name: string=?,
    ~onAbort: eventHandler=?,
    ~onComplete: eventHandler=?,
    ~onCycle: eventHandler=?,
    ~onError: eventHandler=?,
    ~onReset: eventHandler=?,
    ~onStart: eventHandler=?,
    ~fn: testFn=?,
    ~setup: setupFn=?,
    ~teardown: teardownFn=?,
    ~queued: bool=?,
    unit,
  ) => t = ""
}

module Platform = {
  module OS = {
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
