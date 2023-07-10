open Cmdliner

(* Inspired by https://gitlab.ocamlpro.com/louis/opam-custom-install *)

let check_npm_deps_doc = "Check for npm depexts inside the node_modules folder"

let depexts nv opams =
  try
    let opam = OpamPackage.Map.find nv opams in
    List.fold_left
      (fun depexts (names, filter) ->
        let variables = OpamFilter.variables filter in
        let has_npm =
          let module V = OpamVariable in
          List.exists
            (fun full_var ->
              String.equal "npm-version"
                (V.to_string (V.Full.variable full_var)))
            variables
        in
        if has_npm then OpamSysPkg.Set.Op.(names ++ depexts) else depexts)
      OpamSysPkg.Set.empty
      (OpamFile.OPAM.depexts opam)
  with Not_found -> OpamSysPkg.Set.empty

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
  let check_npm_deps global_options build_options () =
    OpamArg.apply_global_options cli global_options;
    OpamArg.apply_build_options cli build_options;
    OpamClientConfig.update ~inplace_build:true ~working_dir:true ();
    OpamGlobalState.with_ `Lock_none @@ fun gt ->
    OpamSwitchState.with_ `Lock_write gt @@ fun st ->
    let npm_depexts =
      List.filter_map
        (fun pkg ->
          let depexts = depexts pkg st.opams in
          match OpamSysPkg.Set.cardinal depexts with
          | 0 -> None
          | _ -> Some (pkg, depexts))
        OpamPackage.Set.(elements @@ st.installed)
    in
    let () =
      match npm_depexts with
      | [] -> ()
      | l ->
          print_endline "Found the following npm dependencies in opam files:";
          print_endline
            (OpamStd.List.concat_map " "
               (fun (pkg, npm_deps) ->
                 Printf.sprintf "pkg: %s, depexts: %s\n"
                   (OpamPackage.to_string pkg)
                   (OpamSysPkg.Set.to_string npm_deps))
               l)
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
  OpamArg.mk_command ~cli OpamArg.cli_original "opam-check-npm-deps" ~doc ~man
    Term.(
      const check_npm_deps $ OpamArg.global_options cli
      $ OpamArg.build_options cli)

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
