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
