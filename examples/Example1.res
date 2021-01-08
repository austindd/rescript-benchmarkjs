open BenchmarkJs

let rec copyList = (~from, acc) =>
  switch from {
  | list{} => acc
  | list{item, ...remaining} => copyList(~from=remaining, list{item, ...acc})
  }

let result = {
  open Benchmark
  let benchmark = make("List Copy", ~config={
    ...defaultConfig,
    onStart: _ => Js.log("-- Running Benchmarks --\r\n"),
    onComplete: _ => Js.log("-- Done --\r\n"),
    onError: evt => evt->Js.log,
  }, (. ()) => {
    let listRef = ref(list{})

    let listRef = listRef
    ()
    let source = {
      let var = ref(list{})
      for i in 1 to 1000 {
        var := list{i, ...var.contents}
      }
      var.contents
    }
    listRef := copyList(~from=source, list{})
  })

  run(benchmark)
}

Js.log2("Times:", result->Benchmark.times)
Js.log2("Stats:", result->Benchmark.stats)

