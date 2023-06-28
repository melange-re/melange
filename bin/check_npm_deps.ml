open Cmdliner
open OpamPackage.Set.Op

(* Inspired by https://gitlab.ocamlpro.com/louis/opam-custom-install *)

let check_npm_deps_doc = "Check for npm depexts inside the node_modules folder"

let depexts_raw ~env nv opams =
  try
    let opam = OpamPackage.Map.find nv opams in
    print_endline (OpamPackage.name_to_string nv);
    if OpamPackage.name_to_string nv = "reactjs-jsx-ppx" then
      print_endline (OpamFile.OPAM.write_to_string opam);
    List.fold_left
      (fun depexts (names, filter) ->
        print_endline (OpamFilter.to_string filter);
        if OpamFilterVendored.eval_to_bool ~default:false env filter then
          OpamSysPkg.Set.Op.(names ++ depexts)
        else depexts)
      OpamSysPkg.Set.empty
      (OpamFile.OPAM.depexts opam)
  with Not_found -> OpamSysPkg.Set.empty

let depexts package opams =
  let resolve_switch_raw full_var =
    let module V = OpamVariable in
    let var = V.Full.variable full_var in
    print_endline "VAR";
    print_endline (V.to_string var);
    match V.to_string var with
    | "npm" -> 
    Some (OpamVariable.bool true)
    | _ -> None
  in
  let env = resolve_switch_raw in
  depexts_raw ~env package opams

let _variables =
  List.map
    (fun (n, v) ->
      ( OpamVariable.of_string n,
        OpamCompat.Lazy.map (OpamStd.Option.map (fun v -> OpamTypes.S v)) v ))
    [ ("os-family", lazy (Some "npm")) ]

let check_npm_deps cli =
  let doc = check_npm_deps_doc in
  let man =
    [
      `S Manpage.s_description;
      `P
        "This command allows to read the current opam switch to find all \
         dependencies defining a depext belonging to \"npm\" platform and \
         their constraints, and then checks the `node_modules` folder to \
         verify the constraints are satisfied.";
      `P
        "This command only performs read operations, and does not install or \
         modify the opam switch or the `node_modules` folder in any way.";
      `S Manpage.s_arguments;
      `S Manpage.s_options;
    ]
    @ OpamArg.man_build_option_section
  in
  let packages =
    Arg.(
      non_empty
      & pos 0 (list OpamArg.package) []
      & info [] ~docv:"PACKAGE[.VERSION]"
          ~doc:
            "Package which should be registered as installed with the files \
             installed by $(i,COMMAND).")
  in
  let cmd =
    Arg.(
      non_empty & pos_right 0 string []
      & info [] ~docv:"-- COMMAND [ARG]"
          ~doc:
            "Command to run in the current directory that is expected to \
             install the files for $(i,PACKAGE) to the current opam switch \
             prefix. Variable expansions like $(b,%{prefix}%), $(b,%{name}%), \
             $(b,%{version}%) and $(b,%{package}) are expanded as per the \
             $(i,install:) package definition field.")
  in
  let check_npm_deps global_options build_options _packages _cmd () =
    OpamArg.apply_global_options cli global_options;
    OpamArg.apply_build_options cli build_options;
    OpamClientConfig.update ~inplace_build:true ~working_dir:true ();
    OpamGlobalState.with_ `Lock_none @@ fun gt ->
    OpamSwitchState.with_ `Lock_write gt @@ fun st ->
    let t =
      OpamFormula.packages_of_atoms ~disj:true (st.packages ++ st.installed) []
    in
    print_endline "HERE";
    print_endline
      (OpamStd.List.concat_map " "
         (fun pkg ->
           Printf.sprintf "pkg: %s, depexts: %s\n"
             (OpamPackage.to_string pkg)
             (OpamSysPkg.Set.to_string
                (depexts pkg st.opams)))
         OpamPackage.Set.(elements @@ st.installed));
    let () =
      OpamPackage.Set.iter
        (fun pkg -> print_endline (OpamPackage.name_to_string pkg))
        t
    in
    (* let nvs =
         List.fold_left
           (fun acc p -> OpamPackage.Set.add (get_nv p) acc)
           OpamPackage.Set.empty packages
       in
       let build_dir = OpamFilename.cwd () in
       let mk_opam nv =
         OpamFile.OPAM.create nv
         |> OpamFile.OPAM.with_install
              [ (List.map (fun a -> (CString a, None)) cmd, None) ]
         |> OpamFile.OPAM.with_synopsis
              ("Package installed using 'opam custom-install' from "
              ^ OpamFilename.Dir.to_string build_dir)
         |> OpamFile.OPAM.with_url (* needed for inplace_build correct build dir *)
              (OpamFile.URL.create
                 (OpamUrl.parse ~backend:`rsync
                    (OpamFilename.Dir.to_string build_dir)))
       in
       let opams =
         OpamPackage.Set.fold
           (fun nv -> OpamPackage.Map.add nv (mk_opam nv))
           nvs OpamPackage.Map.empty
       in
       let st =
         {
           st with
           opams = OpamPackage.Map.union (fun _ o -> o) st.opams opams;
           packages = OpamPackage.Set.union st.packages nvs;
           available_packages =
             lazy (OpamPackage.Set.union (Lazy.force st.available_packages) nvs);
         }
       in
       let st =
         let atoms = OpamSolution.eq_atoms_of_packages nvs in
         let st, full_orphans, orphan_versions =
           OpamClient.check_conflicts st atoms
         in
         let request = OpamSolver.request ~install:atoms ~criteria:`Fixup () in
         let requested = OpamPackage.names_of_packages nvs in
         let solution =
           OpamSolution.resolve st Reinstall
             ~orphans:(full_orphans ++ orphan_versions)
             ~reinstall:(OpamPackage.packages_of_names st.installed requested)
             ~requested request
         in
         let st, res =
           match solution with
           | Conflicts cs ->
               (* this shouldn't happen, the package requested has no requirements *)
               OpamConsole.error "Package conflict!";
               OpamConsole.errmsg "%s"
                 (OpamCudf.string_of_conflicts st.packages
                    (OpamSwitchState.unavailable_reason st)
                    cs);
               OpamStd.Sys.exit_because `No_solution
           | Success solution ->
               let solution = solution in
               OpamSolution.apply st ~requested ~assume_built:true solution
         in
         OpamSolution.check_solution st (Success res);
         st
       in *)
    OpamSwitchState.drop st
  in
  OpamArg.mk_command ~cli OpamArg.cli_original "check-npm-deps" ~doc ~man
    Term.(
      const check_npm_deps $ OpamArg.global_options cli
      $ OpamArg.build_options cli $ packages $ cmd)

[@@@ocaml.warning "-3"]

let () =
  OpamStd.Option.iter OpamVersion.set_git OpamGitVersion.version;
  OpamSystem.init ();
  (* OpamArg.preinit_opam_envvariables (); *)
  OpamCliMain.main_catch_all @@ fun () ->
  match
    Term.eval ~catch:false (check_npm_deps (OpamCLIVersion.default, `Default))
  with
  | `Error _ -> exit (OpamStd.Sys.get_exit_code `Bad_arguments)
  | _ -> exit (OpamStd.Sys.get_exit_code `Success)

(* -- junkyard, might be useful for scrap code if we want to do the
   recompilations more manually *)

(* let with_recompile_cone st nv f =
 *   let revdeps =
 *     let deps nv =
 *       OpamSwitchState.opam st nv |>
 *       OpamPackageVar.all_depends
 *         ~build:true ~post:false ~test:false ~doc:false
 *         ~dev:(OpamSwitchState.is_dev_package st nv)
 *     in
 *     OpamPackage.Set.filter (fun nv1 -> OpamFormula.verifies (deps nv1) nv)
 *       st.installed_packages
 *   in
 *   if OpamPackage.Set.is_empty revdeps then f () else
 *   let univ =
 *     OpamSwitchState.universe ~reinstall:revdeps ~requested:nv st
 *   in
 * 
 *    * let sol =
 *    *   OpamSolver.resolve universe ~orphans:OpamPackage.Set.empty
 *    *     { criteria=`Fixup;
 *    *       wish_install=[];
 *    *       wish_remove=[];
 *    *       wish_upgrade=[];
 *    *       extra_attributes=[];
 *    *     } *)

(* let recompile_cone =
 *   OpamPackage.Set.of_list @@
 *   OpamSolver.reverse_dependencies
 *     ~depopts:true ~installed:true ~unavailable:true
 *     ~build:true ~post:false
 *     universe (OpamPackage.Set.singleton nv)
 * in
 * 
 * (\* The API exposes no other way to create an empty solution *\)
 * let solution = OpamSolver.solution_of_json `Null in
 * OpamSolver.print_solution
 *   ~messages:(fun _ -> [])
 *   ~append:(fun nv -> if OpamSwitchState.Set.mem nv st.pinned then "*" else "")
 *   ~requested:OpamPackage.Name.Set.empty
 *   ~reinstall:recompile_cone
 *   solution;
 * 
 * let 
 *   OpamSwitchState.universe ~reinstall:(OpamPackage.Set.singleton nv) ~requested:nv st
 * in
 * let sol =
 *   OpamSolver.resolve universe ~orphans:OpamPackage.Set.empty
 *     { criteria=`Fixup;
 *       wish_install=[];
 *       wish_remove=[];
 *       wish_upgrade=[];
 *       extra_attributes=[];
 *     }
 * in *)
