# rescript-benchmarkjs
ReScript bindings to [Benchmark.js](https://github.com/bestiejs/benchmark.js/), an excellent performance benchmarking library.

## Installation

Using `npm`:
```shell
npm install --save-dev rescript-benchmarkjs
```

Using `yarn`:
```shell
yarn add --dev rescript-benchmarkjs
```

Don't forget to add the dependency to your `bsconfig.json` file:
```json
{
  "bs-dev-dependencies": [
    "rescript-benchmarkjs"
  ]
}
```

## Usage

```rescript
open BenchmarkJs

let suiteConfig = {
  ...Suite.defaultConfig,
  onStart: _ => Js.log("-- Running Benchmark Suite --\r\n"),
  onComplete: _ => Js.log("-- Benchmark Results --\r\n"),
}

let benchmarkConfig = {
  ...Benchmark.defaultConfig,
  onError: Js.log,
  onStart: event => Js.log("Running: '" ++ Benchmark.name(event.target) ++ "'..."),
  onComplete: _ => Js.log("Done\r\n"),
}

Random.init(486)
let myArray = Belt.Array.makeBy(1000, _ => Random.int(99999))

Suite.make("Array Sort", ~config=suiteConfig)
->Suite.add("Belt.SortArray.stableSortBy", ~config=benchmarkConfig, (. ()) => {
  let result = myArray->Belt.SortArray.stableSortBy(Pervasives.compare)
  ignore(result)
})
->Suite.add("Js.Array2.slice + Js.Array2.sortInPlace", ~config=benchmarkConfig, (. ()) => {
  let result = myArray->Js.Array2.sliceFrom(0)->Js.Array2.sortInPlace
  ignore(result)
})
->Suite.run
->Suite.toArray
->Belt.Array.map(Benchmark.toString)
->Belt.Array.forEach(Js.log)
```

### Important Notes:

1. One obvious difference bewteen the ReScript interface and the original `Benchmark.js` API is that, in ReScript, we cannot define "setup code" in one function, and then expect the values defined there to be available in a separate function defining a "test case". Therefore, any values you expect to be available within both the *setup function* AND a *test case* function must be defined in an outer (usually global) scope. This is done in the example above with the `myArray` value.
2. It's generally a good idea to inspect the generated code for each test case. In some cases, you may find that the compiler has optimized or de-optimized a test case in unexpected ways. The might include code removal, adding/removing wrapper objects, using helper functions for type-safety, etc. In some cases, you might intend to capture this compiler behavior in your tests. In other cases, you may find yourself running tests with false assumptions about the generated JS code. Always check the generated code to be certain.
