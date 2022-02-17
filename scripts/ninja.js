#!/usr/bin/env node
//@ts-check

var fs = require("fs");
var path = require("path");
var cp = require("child_process");

var root = process.cwd();
var jscompDir = path.join(__dirname, "..", "jscomp");
var runtimeDir = path.join(jscompDir, "runtime");
var othersDir = path.join(jscompDir, "others");
var testDir = path.join(jscompDir, "test");

var jsDir = path.join(__dirname, "..", "lib", "js");

var runtimeFiles = fs.readdirSync(runtimeDir, "ascii");
var runtimeMlFiles = runtimeFiles.filter(
  (x) => !x.startsWith("bs_stdlib_mini") && x.endsWith(".ml") && x !== "js.ml"
);
var runtimeMliFiles = runtimeFiles.filter(
  (x) => !x.startsWith("bs_stdlib_mini") && x.endsWith(".mli") && x !== "js.mli"
);
var runtimeSourceFiles = runtimeMlFiles.concat(runtimeMliFiles);
var runtimeJsFiles = [...new Set(runtimeSourceFiles.map(baseName))];

var commonBsFlags = `-no-keep-locs -no-alias-deps -bs-no-version-header -bs-no-check-div-by-zero -nostdlib `;
var js_package = pseudoTarget("js_pkg");
var runtimeTarget = pseudoTarget("runtime");
var othersTarget = pseudoTarget("others");
var stdlibTarget = pseudoTarget("stdlib");

var vendorNinjaPath = path.join(__dirname, "..", process.platform, "ninja.exe");

exports.vendorNinjaPath = vendorNinjaPath;
/**
 * By default we use vendored,
 * we produce two ninja files which won't overlap
 * one is build.ninja which use  vendored config
 * the other is env.ninja which use binaries from environment
 *
 * In dev mode, files generated for vendor config
 *
 * build.ninja
 * compiler.ninja
 * snapshot.ninja
 * runtime/build.ninja
 * others/build.ninja
 * $stdlib/build.ninja
 * test/build.ninja
 *
 * files generated for env config
 *
 * env.ninja
 * compilerEnv.ninja (no snapshot since env can not provide snapshot)
 * runtime/env.ninja
 * others/env.ninja
 * $stdlib/env.ninja
 * test/env.ninja
 *
 * In release mode:
 *
 * release.ninja
 * runtime/release.ninja
 * others/release.ninja
 * $stdlib/release.ninja
 *
 * Like that our snapshot is so robust that
 * we don't do snapshot in CI, we don't
 * need do test build in CI either
 *
 */

/**
 * Note this file is not used in ninja file
 * It is used to generate ninja file
 * @returns {string}
 * Note ocamldep.opt has built-in macro handling OCAML_VERSION
 */
var getOcamldepFile = () => {
  return "ocamldep.opt";
};

var getBsc = () => {
  // TODO(anmonteiro): fix for CI
  return "./_build/default/jscomp/main/js_main.exe";
}

/**
 * @type {string}
 */
var versionString = undefined;

var getVersionString = () => {
  if (versionString === undefined) {
    var searcher = "version";
    try {
      var output = cp.execSync(`${getOcamldepFile()} -version`, {
        encoding: "ascii",
      });
      versionString = output
        .substring(output.indexOf(searcher) + searcher.length)
        .trim();
    } catch (err) {
      //
      console.error(`This error  probably came from that you don't have our vendored ocaml installed
      If this is the first time you clone the repo
      try this
      git submodule init && git submodule update
      node ./scripts/buildocaml.js
      `);
      console.error(err.message);
      process.exit(err.status);
    }
  }
  return versionString;
};

function ruleCC(flags, src, target, deps = [], promoteExts) {
  var promoteTarget = promoteExts != null
    ? (target.filter(x => x.endsWith("cmj")).flatMap(x =>
      promoteExts.map(promoteExt => `${path.parse(x).name}${promoteExt}`)
    ))
    : null;
  return `
  (rule
    (targets ${Array.isArray(target) ? target.join(' ') : target} ${promoteTarget != null ? promoteTarget.join(' ') : ""})
    (deps (:inputs ${Array.isArray(src) ? src.join(' ') : src}) ${deps.join(' ')})
${promoteTarget ? `
  (mode
   (promote
    (until-clean)
    (only ${promoteTarget.join(' ')})))
` : ""}
    (action
     (run %{workspace_root}/jscomp/main/js_main.exe -bs-cmi -bs-cmj ${flags} -I . %{inputs})))
`;
}

function ruleCC_cmi(flags, src, target, deps = [], promoteExts) {
  var promoteTarget = promoteExts != null
    ? (target.filter(x => x.endsWith("cmj")).flatMap(x =>
      promoteExts.map(promoteExt => `${path.parse(x).name}${promoteExt}`)
    ))
    : null;
  return `
  (rule
    (targets ${Array.isArray(target) ? target.join(' ') : target} ${promoteTarget ? promoteTarget.join(' ') : ""})
    (deps (:inputs ${Array.isArray(src) ? src.join(' ') : src}) ${deps.join(' ')})
${promoteTarget ? `
  (mode
   (promote
    (until-clean)
    (only ${promoteTarget.join(' ')})))
` : ""}
    (action
     (run %{workspace_root}/jscomp/main/js_main.exe -bs-read-cmi -bs-cmi -bs-cmj ${flags} -I . %{inputs})))
`;
}

/**
 * Fixed since it is already vendored
 */
var cppoMonoFile = `../vendor/cppo/cppo_bin.ml`;
/**
 *
 * @param {string} name
 * @param {string} content
 */
function writeFileAscii(name, content) {
  fs.writeFile(name, content, "ascii", throwIfError);
}

/**
 *
 * @param {string} name
 * @param {string} content
 */
function writeFileSync(name, content) {
  return fs.writeFileSync(name, content, "ascii");
}
/**
 *
 * @param {NodeJS.ErrnoException} err
 */
function throwIfError(err) {
  if (err !== null) {
    throw err;
  }
}
/**
 *
 * @typedef { {kind : "file" , name : string} | {kind : "pseudo" , name : string}} Target
 * @typedef {{key : string, value : string}} Override
 * @typedef { Target[]} Targets
 * @typedef {Map<string,TargetSet>} DepsMap
 */

class TargetSet {
  /**
   *
   * @param {Targets} xs
   */
  constructor(xs = []) {
    this.data = xs;
  }
  /**
   *
   * @param {Target} x
   */
  add(x) {
    var data = this.data;
    var found = false;
    for (var i = 0; i < data.length; ++i) {
      var cur = data[i];
      if (cur.kind === x.kind && cur.name === x.name) {
        found = true;
        break;
      }
    }
    if (!found) {
      this.data.push(x);
    }
    return this;
  }
  /**
   * @returns {Targets} a copy
   *
   */
  toSortedArray() {
    var newData = this.data.concat();
    newData.sort((x, y) => {
      var kindx = x.kind;
      var kindy = y.kind;
      if (kindx > kindy) {
        return 1;
      } else if (kindx < kindy) {
        return -1;
      } else {
        if (x.name > y.name) {
          return 1;
        } else if (x.name < y.name) {
          return -1;
        } else {
          return 0;
        }
      }
    });
    return newData;
  }
  /**
   *
   * @param {(item:Target)=>void} callback
   */
  forEach(callback) {
    this.data.forEach(callback);
  }

  removeByName(x) {
    this.data = this.data.filter(cur => cur.name !== x)

    return this;
  }
}

/**
 *
 * @param {string} target
 * @param {string} dependency
 * @param {DepsMap} depsMap
 */
function updateDepsKVByFile(target, dependency, depsMap) {
  var singleTon = fileTarget(dependency);
  if (depsMap.has(target)) {
    depsMap.get(target).add(singleTon);
  } else {
    depsMap.set(target, new TargetSet([singleTon]));
  }
}

/**
 *
 * @param {string} s
 */
function uncapitalize(s) {
  if (s.length === 0) {
    return s;
  }
  return s[0].toLowerCase() + s.slice(1);
}
/**
 *
 * @param {string} target
 * @param {string[]} dependencies
 * @param {DepsMap} depsMap
 */
function updateDepsKVsByFile(target, dependencies, depsMap) {
  var targets = fileTargets(dependencies);
  if (depsMap.has(target)) {
    var s = depsMap.get(target);
    for (var i = 0; i < targets.length; ++i) {
      s.add(targets[i]);
    }
  } else {
    depsMap.set(target, new TargetSet(targets));
  }
}

/**
 *
 * @param {string} target
 * @param {string[]} modules
 * @param {DepsMap} depsMap
 */
function updateDepsKVsByModule(target, modules, depsMap) {
  if (depsMap.has(target)) {
    let s = depsMap.get(target);
    for (let module of modules) {
      let filename = uncapitalize(module);
      let filenameAsCmi = filename + ".cmi";
      let filenameAsCmj = filename + ".cmj";
      if (target.endsWith(".cmi")) {
        if (depsMap.has(filenameAsCmi) || depsMap.has(filenameAsCmj)) {
          s.add(fileTarget(filenameAsCmi));
        }
      } else if (target.endsWith(".cmj")) {
        if (depsMap.has(filenameAsCmj)) {
          s.add(fileTarget(filenameAsCmj));
        } else if (depsMap.has(filenameAsCmi)) {
          s.add(fileTarget(filenameAsCmi));
        }
      }
    }
  }
}
/**
 *
 * @param {string[]}sources
 * @return {DepsMap}
 */
function createDepsMapWithTargets(sources) {
  /**
   * @type {DepsMap}
   */
  let depsMap = new Map();
  for (let source of sources) {
    let target = sourceToTarget(source);
    depsMap.set(target, new TargetSet([]));
  }
  depsMap.forEach((set, name) => {
    let cmiFile;
    if (
      name.endsWith(".cmj") &&
      depsMap.has((cmiFile = replaceExt(name, ".cmi")))
    ) {
      set.add(fileTarget(cmiFile));
    }
  });
  return depsMap;
}

/**
 *
 * @param {Target} file
 * @param {string} cwd
 */
function targetToString(file, cwd) {
  switch (file.kind) {
    case "file":
      return path.join(cwd, file.name);
    case "pseudo":
      return file.name;
    default:
      throw Error;
  }
}
/**
 *
 * @param {Targets} files
 * @param {string} cwd
 *
 * @returns {string} return a string separated with whitespace
 */
function targetsToString(files, cwd) {
  return files.map((x) => targetToString(x, cwd)).join(" ");
}
/**
 *
 * @param {Targets} outputs
 * @param {Targets} inputs
 * @param {Targets} deps
 * @param {Override[]} overrides
 * @param {string} rule
 * @param {string} cwd
 * @return {string}
 */
function ninjaBuild(outputs, inputs, rule, deps, cwd, overrides) {
  var fileOutputs = targetsToString(outputs, cwd);
  var fileInputs = targetsToString(inputs, cwd);
  var stmt = `o ${fileOutputs} : ${rule} ${fileInputs}`;
  // deps.push(pseudoTarget('../lib/bsc'))
  if (deps.length > 0) {
    var fileDeps = targetsToString(deps, cwd);
    stmt += ` | ${fileDeps}`;
  }
  if (overrides.length > 0) {
    stmt +=
      `\n` +
      overrides
        .map((x) => {
          return `    ${x.key} = ${x.value}`;
        })
        .join("\n");
  }
  return stmt;
}

function dunePhony(outputs, inputs) {
  return `
    (alias
      (name ${outputs.name})
      (deps ${inputs.join(' ')}))
  `
}

/**
 *
 * @param {Target} outputs
 * @param {Targets} inputs
 * @param {string} cwd
 */
function phony(outputs, inputs, cwd) {
  return ninjaBuild([outputs], inputs, "phony", [], cwd, []);
}

/**
 *
 * @param {string | string[]} outputs
 * @param {string | string[]} inputs
 * @param {string | string[]} fileDeps
 * @param {string} rule
 * @param {string} cwd
 * @param {[string,string][]} overrides
 * @param {Target | Targets} extraDeps
 */
function ninjaQuickBuild(
  outputs,
  inputs,
  rule,
  cwd,
  overrides,
  fileDeps,
  extraDeps
) {
  var os = Array.isArray(outputs)
    ? fileTargets(outputs)
    : [fileTarget(outputs)];
  var is = Array.isArray(inputs) ? fileTargets(inputs) : [fileTarget(inputs)];
  var ds = Array.isArray(fileDeps)
    ? fileTargets(fileDeps)
    : [fileTarget(fileDeps)];
  var dds = Array.isArray(extraDeps) ? extraDeps : [extraDeps];

  return ninjaBuild(
    os,
    is,
    rule,
    ds.concat(dds),
    cwd,
    overrides.map((x) => {
      return { key: x[0], value: x[1] };
    })
  );
}

/**
 * @typedef { (string | string []) } Strings
 * @typedef { [string,string]} KV
 * @typedef { [Strings, Strings,  string, string, KV[], Strings, (Target|Targets)] } BuildList
 * @param {BuildList[]} xs
 * @returns {string}
 */
function ninjaQuickBuidList(xs) {
  return xs
    .map((x) => ninjaQuickBuild(x[0], x[1], x[2], x[3], x[4], x[5], x[6]))
    .join("\n");
}

function ccRuleList(xs) {
  return xs
    .map(([rule, flags, src, target, externalDeps]) => rule(flags,src,target, externalDeps))
    .join("\n");
}

/**
 * @typedef { [string,string,string?]} CppoInput
 * @param {CppoInput[]} xs
 * @param {string} cwd
 * @returns {string}
 */
function cppoList(xs) {
  return xs
    .map((x) => {
      /**
       * @type {KV[]}
       */
      var variables;
      if (x[2]) {
        variables = `-D ${x[2]}`;
      } else {
        variables = '';
      }
      let [target, src] = x;
      return cppoRule(src, target, variables)
    })
    .join("");
}
/**
 *
 * @param {string} cwd
 * @param {string[]} xs
 * @returns {string}
 */
function mllList(cwd, xs) {
  return xs
    .map((x) => {
      var output = baseName(x) + ".ml";
      return `
      (ocamllex ${path.join(cwd, x)})
      `
    })
    .join("\n");
}
/**
 *
 * @param {string} name
 * @returns {Target}
 */
function fileTarget(name) {
  return { kind: "file", name };
}

/**
 *
 * @param {string} name
 * @returns {Target}
 */
function pseudoTarget(name) {
  return { kind: "pseudo", name };
}

/**
 *
 * @param {string[]} args
 * @returns {Targets}
 */
function fileTargets(args) {
  return args.map((name) => fileTarget(name));
}

/**
 *
 * @param {string[]} outputs
 * @param {string[]} inputs
 * @param {DepsMap} depsMap
 * @param {Override[]} overrides
 * @param {Targets} extraDeps
 * @param {string} rule
 * @param {string} cwd
 */
function buildStmt(outputs, inputs, rule, depsMap, cwd, overrides, extraDeps) {
  var os = outputs.map(fileTarget);
  var is = inputs.map(fileTarget);
  var deps = new TargetSet();
  for (var i = 0; i < outputs.length; ++i) {
    var curDeps = depsMap.get(outputs[i]);
    if (curDeps !== undefined) {
      curDeps.forEach((x) => deps.add(x));
    }
  }
  extraDeps.forEach((x) => deps.add(x));
  return ninjaBuild(os, is, rule, deps.toSortedArray(), cwd, overrides);
}

function duneBuildStmt(outputs, inputs, rule, depsMap, flags, externalDeps = [], promoteExt) {
  var deps = new TargetSet();
  for (var i = 0; i < outputs.length; ++i) {
    var curDeps = depsMap.get(outputs[i]);
    if (curDeps !== undefined) {
      curDeps.forEach((x) => {
        if (!outputs.includes (x.name)) {
          deps.add(x)
        }
      });
    }
  }
  return rule(flags, inputs, outputs, externalDeps.concat(deps.toSortedArray().map(x => x.name)), promoteExt);
}

/**
 *
 * @param {string} x
 */
function replaceCmj(x) {
  return x.trim().replace("cmx", "cmj");
}

/**
 *
 * @param {string} y
 */
function sourceToTarget(y) {
  if (y.endsWith(".ml") || y.endsWith(".re") || y.endsWith(".res")) {
    return replaceExt(y, ".cmj");
  } else if (y.endsWith(".mli") || y.endsWith(".rei") || y.endsWith(".resi")) {
    return replaceExt(y, ".cmi");
  }
  return y;
}
/**
 *
 * @param {string[]} files
 * @param {string} dir
 * @param {DepsMap} depsMap
 * @return {Promise<void>}
 * Note `bsdep.exe` does not need post processing and -one-line flag
 * By default `ocamldep.opt` only list dependencies in its args
 */
function ocamlDepForBscAsync(files, dir, depsMap) {
  return new Promise((resolve, reject) => {
    cp.exec(
      `${getOcamldepFile()} -allow-approx -one-line -native ${files.join(" ")}`,
      {
        cwd: dir,
        encoding: "ascii",
      },
      function (error, stdout, stderr) {
        if (error !== null) {
          return reject(error);
        } else {
          var pairs = stdout.split("\n").map((x) => x.split(":"));
          pairs.forEach((x) => {
            var deps;
            let source = replaceCmj(x[0]);
            if (x[1] !== undefined && (deps = x[1].trim())) {
              deps = deps.split(" ");
              updateDepsKVsByFile(
                source,
                deps.map((x) => replaceCmj(x)),
                depsMap
              );
            }
          });
          return resolve();
        }
      }
    );
  });
}

/**
 *
 * @param {string[]} files
 * @param {string} dir
 * @param {DepsMap} depsMap
 * @return { Promise<void> []}
 * Note `bsdep.exe` does not need post processing and -one-line flag
 * By default `ocamldep.opt` only list dependencies in its args
 */
function depModulesForBscAsync(files, dir, depsMap) {
  let ocamlFiles = files.filter((x) => x.endsWith(".ml") || x.endsWith(".mli"));
  let reFiles = files.filter((x) => x.endsWith(".re") || x.endsWith(".rei"));
  let resFiles = files.filter((x) => x.endsWith(".res") || x.endsWith(".resi"));
  /**
   *
   * @param {(value:void) =>void} resolve
   * @param {(value:any)=>void} reject
   */
  let cb = (resolve, reject) => {
    /**
     * @param {any} error
     * @param {string} stdout
     * @param {string} stderr
     */
    let fn = function (error, stdout, stderr) {
      if (error !== null) {
        return reject(error);
      } else {
        var pairs = stdout.split("\n").map((x) => x.split(":"));
        pairs.forEach((x) => {
          var modules;
          let source = sourceToTarget(x[0].trim());
          if (x[1] !== undefined && (modules = x[1].trim())) {
            modules = modules.split(" ");
            updateDepsKVsByModule(source, modules, depsMap);
          }
        });
        return resolve();
      }
    };
    return fn;
  };
  let config = {
    cwd: dir,
    encoding: "ascii",
  };
  return [
    new Promise((resolve, reject) => {
      cp.exec(
        `${getOcamldepFile()} -allow-approx -modules -one-line -native ${ocamlFiles.join(
          " "
        )}`,
        config,
        cb(resolve, reject)
      );
    }),

    new Promise((resolve, reject) => {
      cp.exec(
        `${getOcamldepFile()} -pp 'refmt --print=binary' -modules -one-line -native -ml-synonym .re -mli-synonym .rei ${reFiles.join(
          " "
        )}`,
        config,
        cb(resolve, reject)
      );
    }),
    new Promise((resolve, reject) => {
      cp.exec(
        `${path.join(path.relative(dir, root), getBsc())} -modules -bs-syntax-only ${resFiles.join(
          " "
        )}`,
        config,
        cb(resolve, reject)
      );
    }),
  ];
}

/**
 * @typedef {('HAS_ML' | 'HAS_MLI' | 'HAS_BOTH' | 'HAS_RE' | 'HAS_REI' | 'HAS_BOTH_RE')} FileInfo
 * @param {string[]} sourceFiles
 * @returns {Map<string, FileInfo>}
 * We make a set to ensure that `sourceFiles` are not duplicated
 */
function collectTarget(sourceFiles) {
  /**
   * @type {Map<string,FileInfo>}
   */
  var allTargets = new Map();
  sourceFiles.forEach((x) => {
    var { ext, name } = path.parse(x);
    var existExt = allTargets.get(name);
    if (existExt === undefined) {
      if (ext === ".ml") {
        allTargets.set(name, "HAS_ML");
      } else if (ext === ".mli") {
        allTargets.set(name, "HAS_MLI");
      } else if (ext === ".re") {
        allTargets.set(name, "HAS_RE");
      } else if (ext === ".rei") {
        allTargets.set(name, "HAS_REI");
      } else if (ext === ".res") {
        allTargets.set(name, "HAS_RES");
      } else if (ext === ".resi") {
        allTargets.set(name, "HAS_RESI");
      }

    } else {
      switch (existExt) {
        case "HAS_ML":
          if (ext === ".mli") {
            allTargets.set(name, "HAS_BOTH");
          }
          break;
        case "HAS_RE":
          if (ext === ".rei") {
            allTargets.set(name, "HAS_BOTH_RE");
          }
          break;
        case "HAS_RES":
          if (ext === ".resi") {
            allTargets.set(name, "HAS_BOTH_RES");
          }
          break;
        case "HAS_MLI":
          if (ext === ".ml") {
            allTargets.set(name, "HAS_BOTH");
          }
          break;
        case "HAS_REI":
          if (ext === ".re") {
            allTargets.set(name, "HAS_BOTH_RE");
          }
          break;
        case "HAS_RESI":
          if (ext === ".res") {
            allTargets.set(name, "HAS_BOTH_RES");
          }
          break;
        case "HAS_BOTH_RE":
        case "HAS_BOTH":
        case "HAS_BOTH_RES":
          break;
      }
    }
  });
  return allTargets;
}

/**
 *
 * @param {Map<string, FileInfo>} allTargets
 * @param {string[]} collIn
 * @returns {string[]} A new copy which is
 *
 */
function scanFileTargets(allTargets, collIn) {
  var coll = collIn.concat();
  allTargets.forEach((ext, mod) => {
    switch (ext) {
      case "HAS_MLI":
      case "HAS_REI":
      case "HAS_RESI":
        coll.push(`${mod}.cmi`);
        break;
      case "HAS_BOTH_RES":
      case "HAS_BOTH_RE":
      case "HAS_BOTH":
        coll.push(`${mod}.cmi`, `${mod}.cmj`);
        break;
      case "HAS_RE":
      case "HAS_RES":
      case "HAS_ML":
        coll.push(`${mod}.cmi`, `${mod}.cmj`);
        break;
    }
  });
  return coll;
}

function generateDune(depsMap, allTargets, bscFlags, deps = [], promoteExt = null) {
  /**
   * @type {string[]}
   */
  var build_stmts = [];
  allTargets.forEach((x, mod) => {
    let output_cmj = mod + ".cmj";
    let output_cmi = mod + ".cmi";
    let input_ml = mod + ".ml";
    let input_mli = mod + ".mli";
    let input_re = mod + ".re";
    let input_res = mod + ".res";
    let input_rei = mod + ".rei";
    let input_resi = mod + ".resi";

    var flags = (mod.endsWith("Labels")) ? `${bscFlags} -nolabels` : bscFlags;

    /**
     *
     * @param {string[]} outputs
     * @param {string[]} inputs
     *
     */
    let mk = (outputs, inputs, rule = ruleCC) => {
      return build_stmts.push(
        duneBuildStmt(outputs, inputs, rule, depsMap, flags, deps, promoteExt)
      );
    };
    switch (x) {
      case "HAS_BOTH":
        mk([output_cmj], [input_ml], ruleCC_cmi);
        mk([output_cmi], [input_mli]);
        break;
      case "HAS_BOTH_RE":
        mk([output_cmj], [input_re], ruleCC_cmi);
        mk([output_cmi], [input_rei], ruleCC);
        break;
      case "HAS_BOTH_RES":
        mk([output_cmj], [input_res], ruleCC_cmi);
        mk([output_cmi], [input_resi], ruleCC);
        break;
      case "HAS_RE":
        mk([output_cmi, output_cmj], [input_re], ruleCC);
        break;
      case "HAS_RES":
        mk([output_cmi, output_cmj], [input_res], ruleCC);
        break;
      case "HAS_ML":
        mk([output_cmi, output_cmj], [input_ml]);
        break;
      case "HAS_REI":
        mk([output_cmi], [input_rei], ruleCC);
      case "HAS_RESI":
        mk([output_cmi], [input_resi], ruleCC);
        break;
      case "HAS_MLI":
        mk([output_cmi], [input_mli]);
        break;
    }
  });
  return build_stmts;
}

/**
 *
 * @param {DepsMap} depsMap
 * @param {Map<string,string>} allTargets
 * @param {string} cwd
 * @param {Targets} extraDeps
 * @return {string[]}
 */
function generateNinja(depsMap, allTargets, cwd, extraDeps = []) {
  /**
   * @type {string[]}
   */
  var build_stmts = [];
  allTargets.forEach((x, mod) => {
    let output_cmj = mod + ".cmj";
    let output_cmi = mod + ".cmi";
    let input_ml = mod + ".ml";
    let input_mli = mod + ".mli";
    let input_re = mod + ".re";
    let input_rei = mod + ".rei";
    /**
     * @type {Override[]}
     */
    var overrides = [];
    if (mod.endsWith("Labels")) {
      overrides.push({ key: "bsc_flags", value: "$bsc_flags -nolabels" });
    }

    /**
     *
     * @param {string[]} outputs
     * @param {string[]} inputs
     *
     */
    let mk = (outputs, inputs, rule = "cc") => {
      return build_stmts.push(
        buildStmt(outputs, inputs, rule, depsMap, cwd, overrides, extraDeps)
      );
    };
    switch (x) {
      case "HAS_BOTH":
        mk([output_cmj], [input_ml], "cc_cmi");
        mk([output_cmi], [input_mli]);
        break;
      case "HAS_BOTH_RE":
        mk([output_cmj], [input_re], "cc_cmi");
        mk([output_cmi], [input_rei], "cc");
        break;
      case "HAS_RE":
        mk([output_cmi, output_cmj], [input_re], "cc");
        break;
      case "HAS_ML":
        mk([output_cmi, output_cmj], [input_ml]);
        break;
      case "HAS_REI":
        mk([output_cmi], [input_rei], "cc");
      case "HAS_MLI":
        mk([output_cmi], [input_mli]);
        break;
    }
  });
  return build_stmts;
}

async function runtimeNinja() {
  var ninjaCwd = "runtime";
  var ninjaOutput = "dune.gen";
  var bsc_no_open_flags =  `${commonBsFlags} -bs-cross-module-opt -make-runtime -nopervasives -unsafe -w +50 -warn-error A`;
  var bsc_flags = `${bsc_no_open_flags} -open Bs_stdlib_mini`;
  var templateRuntimeRules = `

${ccRuleList([
  [
    ruleCC,
    "-nostdlib -nopervasives",
    "bs_stdlib_mini.mli",
    "bs_stdlib_mini.cmi",
  ],
  [
    ruleCC,
    bsc_no_open_flags,
    "js.ml",
    ["js.cmj", "js.cmi"],
  ],
])}
`;
  /**
   * @type {DepsMap}
   */
  var depsMap = new Map();
  var allTargets = collectTarget([...runtimeMliFiles, ...runtimeMlFiles]);
  var manualDeps = ["bs_stdlib_mini.cmi", "js.cmj", "js.cmi"];
  var allFileTargetsInRuntime = scanFileTargets(allTargets, manualDeps);
  allTargets.forEach((ext, mod) => {
    switch (ext) {
      case "HAS_MLI":
      case "HAS_BOTH":
        updateDepsKVsByFile(mod + ".cmi", manualDeps, depsMap);
        break;
      case "HAS_ML":
        updateDepsKVsByFile(mod + ".cmj", manualDeps, depsMap);
        break;
    }
  });
  // FIXME: in dev mode, it should not rely on reading js file
  // since it may cause a bootstrapping issues
  try {
    await Promise.all([
      runJSCheckAsync(depsMap),
      ocamlDepForBscAsync(runtimeSourceFiles, runtimeDir, depsMap),
    ]);
    var stmts = generateDune(depsMap, allTargets, bsc_flags);
    stmts.push(
      dunePhony(runtimeTarget, allFileTargetsInRuntime)
    );
    writeFileAscii(
      path.join(runtimeDir, ninjaOutput),
      templateRuntimeRules + stmts.join("\n") + "\n"
    );
  } catch (e) {
    console.log(e);
  }
}

var dTypeString = "TYPE_STRING";

var dTypeInt = "TYPE_INT";

var dTypeFunctor = "TYPE_FUNCTOR";

var dTypeLocalIdent = "TYPE_LOCAL_IDENT";

var dTypeIdent = "TYPE_IDENT";

var dTypePoly = "TYPE_POLY";

var cppoRule = (src, target, flags = "") => `
(rule
  (targets ${target})
  (deps ${src})
  (mode
   (promote
    (until-clean)
    (only :standard)))
  (action
   (run cppo ${flags} %{deps} %{env:CPPO_FLAGS=} -o %{targets})))
`;

async function othersNinja() {
  var externalDeps = [runtimeTarget].map(x => `(alias ../runtime/${x.name})`);
  var ninjaOutput = 'dune.gen';
  var ninjaCwd = "others";
  var bsc_flags = `${commonBsFlags} -bs-cross-module-opt -make-runtime   -nopervasives  -unsafe  -w +50 -warn-error A  -open Bs_stdlib_mini -I ../runtime`;

  var belt_extraDeps = {
    belt_HashSet: ['belt_HashSetString', 'belt_HashSetInt'],
    belt_HashSetString: [ 'belt_internalSetBuckets', 'belt_internalBucketsType', 'belt_Array'],
    belt_HashSetInt: [ 'belt_internalSetBuckets', 'belt_internalBucketsType', 'belt_Array'],
    belt_HashMap: ['belt_HashMapString', 'belt_HashMapInt'],
    belt_HashMapString: [ 'belt_internalBuckets', 'belt_internalBucketsType', 'belt_Array'],
    belt_HashMapInt: [ 'belt_internalBuckets', 'belt_internalBucketsType', 'belt_Array'],
    belt_Map: ['belt_MapString', 'belt_MapInt'],
    belt_MapString: [ 'belt_internalAVLtree', 'belt_Array', 'belt_internalMapString' ],
    belt_MapInt: [ 'belt_internalAVLtree', 'belt_Array', 'belt_internalMapInt' ],
    belt_Set: ['belt_SetString', 'belt_SetInt'],
    belt_SetString: [ 'belt_internalAVLset', 'belt_Array', 'belt_internalSetString' ],
    belt_SetInt: [ 'belt_internalAVLset', 'belt_Array', 'belt_internalSetInt' ],
    belt_MutableMap: ['belt_MutableMapString', 'belt_MutableMapInt'],
    belt_MutableMapString: ['belt_internalMapString', 'belt_internalAVLtree', 'belt_Array' ],
    belt_MutableMapInt: ['belt_internalMapInt', 'belt_internalAVLtree', 'belt_Array' ],
    belt_MutableSet: ['belt_MutableSetString', 'belt_MutableSetInt'],
    belt_MutableSetString: [ 'belt_internalSetString', 'belt_SortArrayString', 'belt_internalAVLset', 'belt_Array' ],
    belt_MutableSetInt: [ 'belt_internalSetInt', 'belt_SortArrayInt', 'belt_internalAVLset', 'belt_Array' ],
    belt_SortArray: ['belt_SortArrayString', 'belt_SortArrayInt'],
    belt_SortArrayString: [ 'belt_Array' ],
    belt_SortArrayInt: [ 'belt_Array' ],
    belt_internalMapString: [ 'belt_internalAVLtree', 'belt_Array', 'belt_SortArray' ],
    belt_internalMapInt: [ 'belt_internalAVLtree', 'belt_Array', 'belt_SortArray' ],
    belt_internalSetString: ['belt_internalAVLset', 'belt_Array', 'belt_SortArrayString'],
    belt_internalSetInt: ['belt_internalAVLset', 'belt_Array', 'belt_SortArrayInt'],
    js_typed_array: ['js_typed_array2'],
  }
  var belt_cppo_targets = [
    ["belt_HashSetString.ml", "hashset.cppo.ml", dTypeString],
    ["belt_HashSetString.mli", "hashset.cppo.mli", dTypeString],
    ["belt_HashSetInt.ml", "hashset.cppo.ml", dTypeInt],
    ["belt_HashSetInt.mli", "hashset.cppo.mli", dTypeInt],
    ["belt_HashMapString.ml", "hashmap.cppo.ml", dTypeString],
    ["belt_HashMapString.mli", "hashmap.cppo.mli", dTypeString],
    ["belt_HashMapInt.ml", "hashmap.cppo.ml", dTypeInt],
    ["belt_HashMapInt.mli", "hashmap.cppo.mli", dTypeInt],
    ["belt_MapString.ml", "map.cppo.ml", dTypeString],
    ["belt_MapString.mli", "map.cppo.mli", dTypeString],
    ["belt_MapInt.ml", "map.cppo.ml", dTypeInt],
    ["belt_MapInt.mli", "map.cppo.mli", dTypeInt],
    ["belt_SetString.ml", "belt_Set.cppo.ml", dTypeString],
    ["belt_SetString.mli", "belt_Set.cppo.mli", dTypeString],
    ["belt_SetInt.ml", "belt_Set.cppo.ml", dTypeInt],
    ["belt_SetInt.mli", "belt_Set.cppo.mli", dTypeInt],
    ["belt_MutableMapString.ml", "mapm.cppo.ml", dTypeString],
    ["belt_MutableMapString.mli", "mapm.cppo.mli", dTypeString],
    ["belt_MutableMapInt.ml", "mapm.cppo.ml", dTypeInt],
    ["belt_MutableMapInt.mli", "mapm.cppo.mli", dTypeInt],
    ["belt_MutableSetString.ml", "setm.cppo.ml", dTypeString],
    ["belt_MutableSetString.mli", "setm.cppo.mli", dTypeString],
    ["belt_MutableSetInt.ml", "setm.cppo.ml", dTypeInt],
    ["belt_MutableSetInt.mli", "setm.cppo.mli", dTypeInt],
    ["belt_SortArrayString.ml", "sort.cppo.ml", dTypeString],
    ["belt_SortArrayString.mli", "sort.cppo.mli", dTypeString],
    ["belt_SortArrayInt.ml", "sort.cppo.ml", dTypeInt],
    ["belt_SortArrayInt.mli", "sort.cppo.mli", dTypeInt],
    ["belt_internalMapString.ml", "internal_map.cppo.ml", dTypeString],
    ["belt_internalMapInt.ml", "internal_map.cppo.ml", dTypeInt],
    ["belt_internalSetString.ml", "internal_set.cppo.ml", dTypeString],
    ["belt_internalSetInt.ml", "internal_set.cppo.ml", dTypeInt],
    ["js_typed_array.ml", "js_typed_array.cppo.ml", ""],
    ["js_typed_array2.ml", "js_typed_array2.cppo.ml", ""],
  ];
  var templateOthersRules = `
${
   `
${cppoList(belt_cppo_targets)}
`
}
${ccRuleList([
  [ruleCC, bsc_flags, "belt.ml", ["belt.cmj", "belt.cmi"], externalDeps],
  [ruleCC, bsc_flags, "node.ml", ["node.cmj", "node.cmi"], externalDeps],
])}
`;
  var othersDirFiles = fs.readdirSync(othersDir, "ascii");
  var jsPrefixSourceFiles = othersDirFiles.filter(
    (x) =>
      x.startsWith("js") &&
      (x.endsWith(".ml") || x.endsWith(".mli")) &&
      !x.includes(".cppo") &&
      !x.includes("#")
  );
  var othersFiles = othersDirFiles.filter(
    (x) =>
      !x.startsWith("js") &&
      x !== "belt.ml" &&
      x !== "node.ml" &&
      (x.endsWith(".ml") || x.endsWith(".mli")) &&
      !x.includes("#") &&
      !x.includes(".cppo") // we have node ..
  );
  var jsTargets = collectTarget(jsPrefixSourceFiles.filter(x => !x.startsWith('js_typed_array')));
  var allJsTargets = scanFileTargets(jsTargets, []);
  let jsDepsMap = new Map();
  let depsMap = new Map();
  await Promise.all([
    ocamlDepForBscAsync(jsPrefixSourceFiles, othersDir, jsDepsMap),
    ocamlDepForBscAsync(othersFiles, othersDir, depsMap),
  ]);
  var jsOutput = generateDune(jsDepsMap, jsTargets, bsc_flags, externalDeps);
  jsOutput.push(dunePhony(js_package, allJsTargets));

  // Note compiling belt.ml still try to read
  // belt_xx.cmi we need enforce the order to
  // avoid data race issues
  var beltPackage = fileTarget("belt.cmi");
  var nodePackage = fileTarget("node.cmi");
  var beltTargets = collectTarget(othersFiles.concat(belt_cppo_targets.map(([x]) => x)));
  depsMap.forEach((s, k) => {
    if (k.startsWith("belt")) {
      s.add(beltPackage);
    } else if (k.startsWith("node")) {
      s.add(nodePackage);
    }
  });

  for (entry in belt_extraDeps) {
    const extra_deps = belt_extraDeps[entry]
    var all_deps = extra_deps.map(x => x + '.cmi')
      .concat(extra_deps.map(x => x + '.cmj'))
      .concat(`(alias ${js_package.name})`)
    var self_cmi = belt_cppo_targets.map(([x]) => x).includes(entry + '.mli') ? [ entry + ".cmi" ] : [];
    updateDepsKVsByFile(entry + '.cmi', all_deps, depsMap)
    updateDepsKVsByFile(entry + '.cmj', all_deps.concat(self_cmi), depsMap)
  };

  var allOthersTarget = scanFileTargets(beltTargets, []);
  var beltOutput = generateDune(depsMap, beltTargets, bsc_flags, externalDeps);
  beltOutput.push(dunePhony(othersTarget, allOthersTarget));
  // ninjaBuild([`belt_HashSetString.ml`,])
  writeFileAscii(
    path.join(othersDir, ninjaOutput),
    templateOthersRules +
      jsOutput.join("\n") +
      "\n" +
      beltOutput.join("\n") +
      "\n"
  );
}

async function stdlibNinja() {
  var stdlibVersion = "stdlib-412";
  var stdlibModulesDir = path.join(jscompDir, stdlibVersion, "stdlib_modules");
  var stdlibDir = path.join(jscompDir, stdlibVersion);
  var externalDeps = [othersTarget].map(x => `(alias ../../others/${x.name})`);
  var ninjaOutput = 'dune.gen';
  var warnings = "-w -106 -warn-error A";
  var bsc_flags = `${commonBsFlags} -bs-cross-module-opt -make-runtime ${warnings} -I ../../runtime -I ../../others `
  /**
   * @type [string,string][]
   */
  var bsc_builtin_flags = `${bsc_flags} -nopervasives`;
  // It is interesting `-w -a` would generate not great code sometimes
  // deprecations diabled due to string_of_float
  var templateStdlibRules = `
  ${ccRuleList([[
    ruleCC,
    bsc_builtin_flags,
    "camlinternalFormatBasics.mli",
    "camlinternalFormatBasics.cmi",
    externalDeps,
  ],
  // we make it still depends on external
  // to enjoy free ride on dev config for compiler-deps
  [
    ruleCC_cmi,
    bsc_builtin_flags,
    "camlinternalFormatBasics.ml",
    "camlinternalFormatBasics.cmj",
    externalDeps.concat(["camlinternalFormatBasics.cmi"]),
  ],
  [
    ruleCC,
    bsc_builtin_flags,
    "camlinternalAtomic.mli",
    "camlinternalAtomic.cmi",
    externalDeps,
  ],
  [
    ruleCC_cmi,
    bsc_builtin_flags,
    "camlinternalAtomic.ml",
    "camlinternalAtomic.cmj",
    externalDeps.concat(["camlinternalAtomic.cmi"]),
  ],
  [
    ruleCC,
    bsc_builtin_flags,
    "stdlib__no_aliases.mli",
    "stdlib__no_aliases.cmi",
    externalDeps.concat(["camlinternalFormatBasics.cmi", "camlinternalAtomic.cmi"]),
  ],
  [
    ruleCC_cmi,
    bsc_builtin_flags,
    "stdlib__no_aliases.ml",
    [ "stdlib__no_aliases.cmj" ],
    ["stdlib__no_aliases.cmi"]
  ],
])}
`;
  var stdlibDirFiles = fs.readdirSync(stdlibModulesDir, "ascii");
  var sources = stdlibDirFiles.filter((x) => {
    return (
      !x.startsWith("camlinternalFormatBasics") &&
      !x.startsWith("camlinternalAtomic") &&
      // !x.startsWith("pervasives") &&
      !x.startsWith("stdlib__no_aliases") &&
      (x.endsWith(".ml") || x.endsWith(".mli"))
    );
  });
  let depsMap = new Map();
  await ocamlDepForBscAsync(sources, stdlibModulesDir, depsMap);
  var targets = collectTarget(sources);
  var allTargets = scanFileTargets(targets, [
    "camlinternalFormatBasics.cmi",
    "camlinternalFormatBasics.cmj",
    "stdlib__no_aliases.cmi",
  ]);
  targets.forEach((ext, mod) => {
    switch (mod) {
      /* Some exceptions caused by `-allow-approx`, where ocamldep can't parse
       * files with `#if` conditionals */
      case 'obj':
        var target = mod + ".cmj";
        if (depsMap.has(target)) {
          var tgt = depsMap.get(target);
          tgt.removeByName('ephemeron.cmj');
        }
        break;
      case 'camlinternalFormat':
        var target = mod + ".cmj";
        if (depsMap.has(target)) {
          var tgt = depsMap.get(target);
          tgt.removeByName('format.cmj');
        }
        break;
    };
    switch (ext) {
      case "HAS_MLI":
      case "HAS_BOTH":
        updateDepsKVByFile(mod + ".cmi", "stdlib__no_aliases.cmj", depsMap);
        break;
      case "HAS_ML":
        updateDepsKVByFile(mod + ".cmj", "stdlib__no_aliases.cmj", depsMap);
        break;
    }
  });
  var output = generateDune(depsMap, targets, `${bsc_builtin_flags} -open Stdlib__no_aliases `, externalDeps);
  output.push(dunePhony(stdlibTarget, allTargets));

  writeFileAscii(
    path.join(stdlibModulesDir, ninjaOutput),
    templateStdlibRules + output.join("\n") + "\n"
  );

  var bsc_flags = `${commonBsFlags} -bs-cross-module-opt -make-runtime ${warnings}  -I ../runtime  -I ../others  -I ./stdlib_modules -nopervasives `
  writeFileAscii(
    path.join(stdlibDir, ninjaOutput),
    `
    ${ccRuleList([
      [
        ruleCC,
        bsc_flags,
        "stdlib.mli",
        "stdlib.cmi" ,
        ["(alias ./stdlib_modules/stdlib)"],
      ],
      [
        ruleCC_cmi,
        bsc_flags,
        "stdlib.ml",
        "stdlib.cmj" ,
        ["stdlib.cmi"],
      ]
    ])}
    `
  );
}

/**
 *
 * @param {string} text
 */
function getDeps(text) {
  /**
   * @type {string[]}
   */
  var deps = [];
  text.replace(
    /(\/\*[\w\W]*?\*\/|\/\/[^\n]*|[.$]r)|\brequire\s*\(\s*["']([^"']*)["']\s*\)/g,
    function (_, ignore, id) {
      if (!ignore) deps.push(id);
      return ""; // TODO: examine the regex
    }
  );
  return deps;
}

/**
 *
 * @param {string} x
 * @param {string} newExt
 * @example
 *
 * ```js
 * replaceExt('xx.cmj', '.a') // return 'xx.a'
 * ```
 *
 */
function replaceExt(x, newExt) {
  let index = x.lastIndexOf(".");
  if (index < 0) {
    return x;
  }
  return x.slice(0, index) + newExt;
}
/**
 *
 * @param {string} x
 */
function baseName(x) {
  return x.substr(0, x.indexOf("."));
}

/**
 *
 * @returns {Promise<void>}
 */
async function testNinja() {
  var ninjaOutput = "dune.gen";
  var ninjaCwd = `test`;
  var bsc_flags = `-bs-no-version-header  -bs-cross-module-opt -make-runtime-test -bs-package-output commonjs:jscomp/test  -w -3-6-26-27-29-30-32..40-44-45-52-60-67-68-106+104 -warn-error A  -I ../runtime -I ../stdlib-412/stdlib_modules -I ../stdlib-412 -I ../others`
  var testDirFiles = fs.readdirSync(testDir, "ascii");
  var sources = testDirFiles.filter((x) => {
    return (
      x.endsWith(".res") ||
      x.endsWith(".resi") ||
      x.endsWith(".re") ||
      x.endsWith(".rei") ||
      ((x.endsWith(".ml") || x.endsWith(".mli")) &&
        x !== "es6_import.ml" &&
        x !== "es6_export.ml")
    );
  });

  let depsMap = createDepsMapWithTargets(sources);
  await Promise.all(depModulesForBscAsync(sources, testDir, depsMap));
  var targets = collectTarget(sources);
  var output = generateDune(depsMap, targets, bsc_flags, ['../stdlib-412/stdlib.cmj'], [".js"]);
  depsMap.set('es6_import.cmj', new TargetSet([fileTarget('es6_export.cmj')]))
  var output = output.concat(
    generateDune(
      depsMap,
      collectTarget(['es6_import.ml', 'es6_export.ml']),
      bsc_flags,
      ['../stdlib-412/stdlib.cmj'],
      [ ".js", ".mjs" ]
    )
  );
  writeFileAscii(
    path.join(testDir, ninjaOutput),
    output.join("\n") + "\n"
  );
}

/**
 *
 * @param {DepsMap} depsMap
 */
function runJSCheckAsync(depsMap) {
  return new Promise((resolve) => {
    var count = 0;
    var tasks = runtimeJsFiles.length;
    var updateTick = () => {
      count++;
      if (count === tasks) {
        resolve(count);
      }
    };
    runtimeJsFiles.forEach((name) => {
      var jsFile = path.join(jsDir, name + ".js");
      fs.readFile(jsFile, "utf8", function (err, fileContent) {
        if (err === null) {
          var deps = getDeps(fileContent).map(
            (x) => path.parse(x).name + ".cmj"
          );
          fs.exists(path.join(runtimeDir, name + ".mli"), (exist) => {
            if (exist) {
              deps.push(name + ".cmi");
            }
            updateDepsKVsByFile(`${name}.cmj`, deps, depsMap);
            updateTick();
          });
        } else {
          // file non exist or reading error ignore
          updateTick();
        }
      });
    });
  });
}

function checkEffect() {
  var jsPaths = runtimeJsFiles.map((x) => path.join(jsDir, x + ".js"));
  var effect = jsPaths
    .map((x) => {
      return {
        file: x,
        content: fs.readFileSync(x, "utf8"),
      };
    })
    .map(({ file, content: x }) => {
      if (/No side effect|This output is empty/.test(x)) {
        return {
          file,
          effect: "pure",
        };
      } else if (/Not a pure module/.test(x)) {
        return {
          file,
          effect: "false",
        };
      } else {
        return {
          file,
          effect: "unknown",
        };
      }
    })
    .filter(({ effect }) => effect !== "pure")
    .map(({ file, effect }) => {
      return { file: path.basename(file), effect };
    });

  var black_list = new Set([
    "caml_int32.js",
    "caml_int64.js",
    "caml_lexer.js",
    "caml_parser.js",
  ]);

  var assert = require("assert");
  // @ts-ignore
  assert(
    effect.length === black_list.size &&
      effect.every((x) => black_list.has(x.file))
  );

  console.log(effect);
}

/**
 *
 * @param {string[]} domain
 * @param {Map<string,Set<string>>} dependency_graph
 * @returns {string[]}
 */
function sortFilesByDeps(domain, dependency_graph) {
  /**
   * @type{string[]}
   */
  var result = [];
  var workList = new Set(domain);
  /**
   *
   * @param {Set<string>} visiting
   * @param {string[]} path
   * @param {string} current
   */
  var visit = function (visiting, path, current) {
    if (visiting.has(current)) {
      throw new Error(`cycle: ${path.concat(current).join(" ")}`);
    }
    if (workList.has(current)) {
      visiting.add(current);
      var next = dependency_graph.get(current);
      if (next !== undefined && next.size > 0) {
        next.forEach((x) => {
          visit(visiting, path.concat(current), x);
        });
      }
      visiting.delete(current);
      workList.delete(current);
      result.push(current);
    }
  };
  while (workList.size > 0) {
    visit(new Set(), [], workList.values().next().value);
  }
  return result;
}

function genDuneFiles() {
  runtimeNinja();
  stdlibNinja();
  testNinja();
  othersNinja();
}

/**
 *
 * @param {string} dir
 */
function readdirSync(dir) {
  return fs.readdirSync(dir, "ascii");
}

/**
 *
 * @param {string} dir
 */
function test(dir) {
  return readdirSync(path.join(jscompDir, dir))
    .filter((x) => {
      return (
        (x.endsWith(".ml") || x.endsWith(".mli")) &&
        !(x.endsWith(".cppo.ml") || x.endsWith(".cppo.mli"))
      );
    })
    .map((x) => path.join(dir, x));
}

/**
 *
 * @param {Set<string>} xs
 * @returns {string}
 */
function setSortedToStringAsNativeDeps(xs) {
  var arr = Array.from(xs).sort();
  // it relies on we have -opaque, so that .cmx is dummy file
  return arr.join(" ").replace(/\.cmx/g, ".cmi");
}

/**
 * @returns {string}
 */
function getVendorConfigNinja() {
  var prefix = `../native/${require("./buildocaml.js").getVersionPrefix()}/bin`;
  return `
ocamlopt = ${prefix}/ocamlopt.opt
ocamllex = ${prefix}/ocamllex.opt
ocamlmklib = ${prefix}/ocamlmklib
ocaml = ${prefix}/ocaml
`;
}

function main() {
  var emptyCount = 2;
  var isPlayground = false;
  if (require.main === module) {
    if (process.argv.includes("-check")) {
      checkEffect();
    }
    if (process.argv.includes("-playground")) {
      isPlayground = true;
      emptyCount++;
    }

    var subcommand = process.argv[2];
    switch (subcommand) {
      case "build":
        try {
          cp.execFileSync(vendorNinjaPath, {
            encoding: "utf8",
            cwd: jscompDir,
            stdio: [0, 1, 2],
          });
          if (!isPlayground) {
            cp.execFileSync(
              path.join(__dirname, "..", "jscomp", "bin", "cmij.exe"),
              {
                encoding: "utf8",
                cwd: jscompDir,
                stdio: [0, 1, 2],
              }
            );
          }
          cp.execFileSync(vendorNinjaPath, ["-f", "snapshot.ninja"], {
            encoding: "utf8",
            cwd: jscompDir,
            stdio: [0, 1, 2],
          });
        } catch (e) {
          console.log(e.message);
          console.log(`please run "./scripts/ninja.js config" first`);
          process.exit(2);
        }
        cp.execSync(`node ${__filename} config`, {
          cwd: __dirname,
          stdio: [0, 1, 2],
        });
        break;
      case "clean":
        try {
          cp.execFileSync(vendorNinjaPath, ["-t", "clean"], {
            encoding: "utf8",
            cwd: jscompDir,
            stdio: [0, 1],
          });
        } catch (e) {}
        cp.execSync(
          `git clean -dfx jscomp ${process.platform} lib && rm -rf lib/js/*.js && rm -rf lib/es6/*.js`,
          {
            encoding: "utf8",
            cwd: path.join(__dirname, ".."),
            stdio: [0, 1, 2],
          }
        );
        break;
      case "config":
        console.log(`config for the first time may take a while`);
        genDuneFiles();

        break;
      case "cleanbuild":
        console.log(`run cleaning first`);
        cp.execSync(`node ${__filename} clean`, {
          cwd: __dirname,
          stdio: [0, 1, 2],
        });
        cp.execSync(`node ${__filename} config`, {
          cwd: __dirname,
          stdio: [0, 1, 2],
        });
        cp.execSync(`node ${__filename} build`, {
          cwd: __dirname,
          stdio: [0, 1, 2],
        });
        break;
      case "docs":
        console.log(`building docs`);
        require("./doc_gen").main();
        break;
      case "help":
        console.log(`supported subcommands:
[exe] config
[exe] build
[exe] cleanbuild
[exe] docs
[exe] help
[exe] clean
        `);
        break;
      default:
        if (process.argv.length === emptyCount) {
          genDuneFiles();
        } else {
          var dev = process.argv.includes("-dev");
          var release = process.argv.includes("-release");
          var all = process.argv.includes("-all");
          genDuneFiles();
        }
        break;
    }
  }
}

main();
