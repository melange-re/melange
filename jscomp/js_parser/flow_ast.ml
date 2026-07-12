module rec
  Syntax:sig
           type ('M, 'internal) t =
             {
             leading: 'M Comment.t list ;
             trailing: 'M Comment.t list ;
             internal: 'internal }[@@deriving show]
         end =
  struct
    type ('M, 'internal) t =
      {
      leading: 'M Comment.t list ;
      trailing: 'M Comment.t list ;
      internal: 'internal }[@@deriving show]
  end
 and
  Identifier:sig
               type ('M, 'T) t = ('T * 'M t')
               and 'M t' =
                 {
                 name: string ;
                 comments: ('M, unit) Syntax.t option }[@@deriving show]
             end =
  struct
    type ('M, 'T) t = ('T * 'M t')
    and 'M t' = {
      name: string ;
      comments: ('M, unit) Syntax.t option }[@@deriving show]
  end and
       PrivateName:sig
                     type 'M t = ('M * 'M t')
                     and 'M t' =
                       {
                       name: string ;
                       comments: ('M, unit) Syntax.t option }[@@deriving
                                                               show]
                   end =
       struct
         type 'M t = ('M * 'M t')
         and 'M t' = {
           name: string ;
           comments: ('M, unit) Syntax.t option }[@@deriving show]
       end and
            StringLiteral:sig
                            type 'M t =
                              {
                              value: string ;
                              raw: string ;
                              comments: ('M, unit) Syntax.t option }[@@deriving
                                                                    show]
                          end =
            struct
              type 'M t =
                {
                value: string ;
                raw: string ;
                comments: ('M, unit) Syntax.t option }[@@deriving show]
            end and
                 NumberLiteral:sig
                                 type 'M t =
                                   {
                                   value: float ;
                                   raw: string ;
                                   comments: ('M, unit) Syntax.t option }
                                 [@@deriving show]
                               end =
                 struct
                   type 'M t =
                     {
                     value: float ;
                     raw: string ;
                     comments: ('M, unit) Syntax.t option }[@@deriving show]
                 end and
                      BigIntLiteral:sig
                                      type 'M t =
                                        {
                                        value: int64 option ;
                                        raw: string ;
                                        comments: ('M, unit) Syntax.t option }
                                      [@@deriving show]
                                    end =
                      struct
                        type 'M t =
                          {
                          value: int64 option ;
                          raw: string ;
                          comments: ('M, unit) Syntax.t option }[@@deriving
                                                                  show]
                      end and
                           BooleanLiteral:sig
                                            type 'M t =
                                              {
                                              value: bool ;
                                              comments:
                                                ('M, unit) Syntax.t option }
                                            [@@deriving show]
                                          end =
                           struct
                             type 'M t =
                               {
                               value: bool ;
                               comments: ('M, unit) Syntax.t option }
                             [@@deriving show]
                           end and
                                RegExpLiteral:sig
                                                type 'M t =
                                                  {
                                                  pattern: string ;
                                                  flags: string ;
                                                  raw: string ;
                                                  comments:
                                                    ('M, unit) Syntax.t
                                                      option
                                                    }[@@deriving show]
                                              end =
                                struct
                                  type 'M t =
                                    {
                                    pattern: string ;
                                    flags: string ;
                                    raw: string ;
                                    comments: ('M, unit) Syntax.t option }
                                  [@@deriving show]
                                end and
                                     ModuleRefLiteral:sig
                                                        type ('M, 'T) t =
                                                          {
                                                          value: string ;
                                                          require_loc: 'M ;
                                                          def_loc_opt:
                                                            'M option ;
                                                          prefix_len: int ;
                                                          raw: string ;
                                                          comments:
                                                            ('M, unit)
                                                              Syntax.t option
                                                            }[@@deriving
                                                               show]
                                                      end =
                                     struct
                                       type ('M, 'T) t =
                                         {
                                         value: string ;
                                         require_loc: 'M ;
                                         def_loc_opt: 'M option ;
                                         prefix_len: int ;
                                         raw: string ;
                                         comments: ('M, unit) Syntax.t option }
                                       [@@deriving show]
                                     end and
                                          Variance:sig
                                                     type 'M t = ('M * 'M t')
                                                     and kind =
                                                       | Plus 
                                                       | Minus 
                                                       | Readonly 
                                                       | Writeonly 
                                                       | In 
                                                       | Out 
                                                       | InOut 
                                                     and 'M t' =
                                                       {
                                                       kind: kind ;
                                                       comments:
                                                         ('M, unit) Syntax.t
                                                           option
                                                         }[@@deriving show]
                                                   end =
                                          struct
                                            type 'M t = ('M * 'M t')
                                            and kind =
                                              | Plus 
                                              | Minus 
                                              | Readonly 
                                              | Writeonly 
                                              | In 
                                              | Out 
                                              | InOut 
                                            and 'M t' =
                                              {
                                              kind: kind ;
                                              comments:
                                                ('M, unit) Syntax.t option }
                                            [@@deriving show]
                                          end and
                                               ComputedKey:sig
                                                             type ('M,
                                                               'T) t =
                                                               ('M * (
                                                                 'M, 
                                                                 'T)
                                                                 ComputedKey.t')
                                                             and ('M,
                                                               'T) t' =
                                                               {
                                                               expression:
                                                                 ('M, 
                                                                   'T)
                                                                   Expression.t
                                                                 ;
                                                               comments:
                                                                 ('M, 
                                                                   unit)
                                                                   Syntax.t
                                                                   option
                                                                 }[@@deriving
                                                                    show]
                                                           end =
                                               struct
                                                 type ('M, 'T) t =
                                                   ('M * ('M, 'T)
                                                     ComputedKey.t')
                                                 and ('M, 'T) t' =
                                                   {
                                                   expression:
                                                     ('M, 'T) Expression.t ;
                                                   comments:
                                                     ('M, unit) Syntax.t
                                                       option
                                                     }[@@deriving show]
                                               end and
                                                    Variable:sig
                                                               type kind =
                                                                 | Var 
                                                                 | Let 
                                                                 | Const 
                                                               [@@deriving
                                                                 show]
                                                             end =
                                                    struct
                                                      type kind =
                                                        | Var 
                                                        | Let 
                                                        | Const [@@deriving
                                                                  show]
                                                    end and
                                                         Type:sig
                                                                module
                                                                Conditional :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    check_type:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    extends_type:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    true_type:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    false_type:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module Infer
                                                                :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    tparam:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.TypeParam.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                Function :
                                                                sig
                                                                  module
                                                                  Param :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    |
                                                                    Anonymous
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Type.t 
                                                                    | Labeled
                                                                    of
                                                                    {
                                                                    name:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    optional:
                                                                    bool } 
                                                                    |
                                                                    Destructuring
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Pattern.t 
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  module
                                                                  RestParam :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Param.t ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  module
                                                                  ThisParam :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.annotation
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  module
                                                                  Params :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    this_:
                                                                    ('M, 
                                                                    'T)
                                                                    ThisParam.t
                                                                    option ;
                                                                    params:
                                                                    ('M, 
                                                                    'T)
                                                                    Param.t
                                                                    list ;
                                                                    rest:
                                                                    ('M, 
                                                                    'T)
                                                                    RestParam.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    'M
                                                                    Comment.t
                                                                    list)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    tparams:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.TypeParams.t
                                                                    option ;
                                                                    params:
                                                                    ('M, 
                                                                    'T)
                                                                    Params.t ;
                                                                    return:
                                                                    ('M, 
                                                                    'T)
                                                                    return_annotation
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option ;
                                                                    effect_:
                                                                    Function.effect_
                                                                    }
                                                                  and (
                                                                    'M,
                                                                    'T) return_annotation =
                                                                    | Missing
                                                                    of 'M 
                                                                    |
                                                                    Available
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Type.t 
                                                                    |
                                                                    TypeGuard
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Type.TypeGuard.t
                                                                    [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                Component :
                                                                sig
                                                                  module
                                                                  Param :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    name:
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.ComponentDeclaration.Param.param_name
                                                                    ;
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.annotation
                                                                    ;
                                                                    optional:
                                                                    bool }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  module
                                                                  RestParam :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    option ;
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    optional:
                                                                    bool ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  module
                                                                  Params :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    params:
                                                                    ('M, 
                                                                    'T)
                                                                    Param.t
                                                                    list ;
                                                                    rest:
                                                                    ('M, 
                                                                    'T)
                                                                    RestParam.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    'M
                                                                    Comment.t
                                                                    list)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    tparams:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.TypeParams.t
                                                                    option ;
                                                                    params:
                                                                    ('M, 
                                                                    'T)
                                                                    Params.t ;
                                                                    renders:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.component_renders_annotation
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                Generic :
                                                                sig
                                                                  module
                                                                  Identifier
                                                                  :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    |
                                                                    Unqualified
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    
                                                                    |
                                                                    Qualified
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    qualified
                                                                    
                                                                    |
                                                                    ImportTypeAnnot
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    import_type
                                                                    
                                                                    and (
                                                                    'M,
                                                                    'T) qualified =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    qualified')
                                                                    and (
                                                                    'M,
                                                                    'T) qualified' =
                                                                    {
                                                                    qualification:
                                                                    ('M, 
                                                                    'T) t ;
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    }
                                                                    and (
                                                                    'M,
                                                                    'T) import_type =
                                                                    ('T * 'M
                                                                    import_type')
                                                                    and 
                                                                    'M import_type' =
                                                                    {
                                                                    argument:
                                                                    ('M * 'M
                                                                    StringLiteral.t)
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    targs:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.TypeArgs.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                IndexedAccess
                                                                :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    _object:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    index:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                OptionalIndexedAccess
                                                                :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    indexed_access:
                                                                    ('M, 
                                                                    'T)
                                                                    IndexedAccess.t
                                                                    ;
                                                                    optional:
                                                                    bool }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module Object
                                                                :
                                                                sig
                                                                  module
                                                                  Property :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    key:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.Object.Property.key
                                                                    ;
                                                                    value:
                                                                    ('M, 
                                                                    'T) value ;
                                                                    optional:
                                                                    bool ;
                                                                    static:
                                                                    bool ;
                                                                    proto:
                                                                    bool ;
                                                                    _method:
                                                                    bool ;
                                                                    abstract:
                                                                    bool ;
                                                                    override:
                                                                    bool ;
                                                                    variance:
                                                                    'M
                                                                    Variance.t
                                                                    option ;
                                                                    ts_accessibility:
                                                                    'M
                                                                    Class.TSAccessibility.t
                                                                    option ;
                                                                    init:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    and (
                                                                    'M,
                                                                    'T) value =
                                                                    | Init of
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t
                                                                    option 
                                                                    | Get of
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Function.t)
                                                                    
                                                                    | Set of
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Function.t)
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  module
                                                                  SpreadProperty
                                                                  :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  module
                                                                  Indexer :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'M)
                                                                    Identifier.t
                                                                    option ;
                                                                    key:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    value:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    static:
                                                                    bool ;
                                                                    variance:
                                                                    'M
                                                                    Variance.t
                                                                    option ;
                                                                    optional:
                                                                    bool ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    and (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  module
                                                                  MappedType
                                                                  :
                                                                  sig
                                                                    type optional_flag =
                                                                    |
                                                                    PlusOptional
                                                                    
                                                                    |
                                                                    MinusOptional
                                                                    
                                                                    |
                                                                    Optional
                                                                    
                                                                    |
                                                                    NoOptionalFlag
                                                                    [@@deriving
                                                                    show]
                                                                    type variance_op =
                                                                    | Add 
                                                                    | Remove 
                                                                    [@@deriving
                                                                    show]
                                                                    type (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    key_tparam:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.TypeParam.t
                                                                    ;
                                                                    prop_type:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    source_type:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    name_type:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t
                                                                    option ;
                                                                    variance:
                                                                    'M
                                                                    Variance.t
                                                                    option ;
                                                                    variance_op:
                                                                    variance_op
                                                                    option ;
                                                                    optional:
                                                                    optional_flag
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    and (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  module
                                                                  CallProperty
                                                                  :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    value:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Function.t)
                                                                    ;
                                                                    static:
                                                                    bool ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  module
                                                                  InternalSlot
                                                                  :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'M)
                                                                    Identifier.t
                                                                    ;
                                                                    value:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    optional:
                                                                    bool ;
                                                                    static:
                                                                    bool ;
                                                                    _method:
                                                                    bool ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  module
                                                                  PrivateField
                                                                  :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    key:
                                                                    'M
                                                                    PrivateName.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    exact:
                                                                    bool ;
                                                                    inexact:
                                                                    bool ;
                                                                    properties:
                                                                    ('M, 
                                                                    'T)
                                                                    property
                                                                    list ;
                                                                    comments:
                                                                    ('M,
                                                                    'M
                                                                    Comment.t
                                                                    list)
                                                                    Syntax.t
                                                                    option }
                                                                  and (
                                                                    'M,
                                                                    'T) property =
                                                                    |
                                                                    Property
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Property.t
                                                                    
                                                                    |
                                                                    SpreadProperty
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    SpreadProperty.t
                                                                    
                                                                    | Indexer
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Indexer.t
                                                                    
                                                                    |
                                                                    CallProperty
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    CallProperty.t
                                                                    
                                                                    |
                                                                    InternalSlot
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    InternalSlot.t
                                                                    
                                                                    |
                                                                    MappedType
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    MappedType.t
                                                                    
                                                                    |
                                                                    PrivateField
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    PrivateField.t
                                                                    [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                Interface :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    body:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Object.t) ;
                                                                    extends:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Generic.t)
                                                                    list ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                Nullable :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module Typeof
                                                                :
                                                                sig
                                                                  module
                                                                  Target :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    |
                                                                    Unqualified
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    
                                                                    |
                                                                    Qualified
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    qualified
                                                                    
                                                                    | Import
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Type.Generic.Identifier.import_type
                                                                    
                                                                    and (
                                                                    'M,
                                                                    'T) qualified' =
                                                                    {
                                                                    qualification:
                                                                    ('M, 
                                                                    'T) t ;
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    }
                                                                    and (
                                                                    'M,
                                                                    'T) qualified =
                                                                    ('T *
                                                                    ('M, 
                                                                    'T)
                                                                    qualified')
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Target.t ;
                                                                    targs:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.TypeArgs.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module Keyof
                                                                :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                Renders :
                                                                sig
                                                                  type variant =
                                                                    | Normal
                                                                    
                                                                    | Maybe 
                                                                    | Star 
                                                                  [@@deriving
                                                                    show]
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    operator_loc:
                                                                    'M ;
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option ;
                                                                    variant:
                                                                    variant }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                ReadOnly :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                ConstructorType
                                                                :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    abstract_:
                                                                    bool ;
                                                                    func:
                                                                    ('M, 
                                                                    'T)
                                                                    Function.t
                                                                    }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module Tuple
                                                                :
                                                                sig
                                                                  module
                                                                  LabeledElement
                                                                  :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    name:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    variance:
                                                                    'M
                                                                    Variance.t
                                                                    option ;
                                                                    optional:
                                                                    bool }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  module
                                                                  UnlabeledElement
                                                                  :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    optional:
                                                                    bool }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  module
                                                                  SpreadElement
                                                                  :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    name:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    option ;
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  type (
                                                                    'M,
                                                                    'T) element =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    element')
                                                                  [@@deriving
                                                                    show]
                                                                  and (
                                                                    'M,
                                                                    'T) element' =
                                                                    |
                                                                    UnlabeledElement
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    UnlabeledElement.t
                                                                    
                                                                    |
                                                                    LabeledElement
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    LabeledElement.t
                                                                    
                                                                    |
                                                                    SpreadElement
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    SpreadElement.t
                                                                    [@@deriving
                                                                    show]
                                                                  and (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    elements:
                                                                    ('M, 
                                                                    'T)
                                                                    element
                                                                    list ;
                                                                    inexact:
                                                                    bool ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module Array
                                                                :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module Union
                                                                :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    types:
                                                                    (('M, 
                                                                    'T)
                                                                    Type.t *
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t *
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t
                                                                    list) ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                Intersection
                                                                :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    types:
                                                                    (('M, 
                                                                    'T)
                                                                    Type.t *
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t *
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t
                                                                    list) ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                TemplateLiteral
                                                                :
                                                                sig
                                                                  module
                                                                  Element :
                                                                  sig
                                                                    type value =
                                                                    {
                                                                    raw:
                                                                    string ;
                                                                    cooked:
                                                                    string }
                                                                    and 
                                                                    'M t =
                                                                    ('M * t')
                                                                    and t' =
                                                                    {
                                                                    value:
                                                                    value ;
                                                                    tail:
                                                                    bool }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    quasis:
                                                                    'M
                                                                    Element.t
                                                                    list ;
                                                                    types:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t
                                                                    list ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                type (
                                                                  'M, 
                                                                  'T) t =
                                                                  ('T * (
                                                                    'M, 
                                                                    'T) t')
                                                                and (
                                                                  'M,
                                                                  'T) t' =
                                                                  | Any of
                                                                  ('M, 
                                                                  unit)
                                                                  Syntax.t
                                                                  option 
                                                                  | Mixed of
                                                                  ('M, 
                                                                  unit)
                                                                  Syntax.t
                                                                  option 
                                                                  | Empty of
                                                                  ('M, 
                                                                  unit)
                                                                  Syntax.t
                                                                  option 
                                                                  | Void of
                                                                  ('M, 
                                                                  unit)
                                                                  Syntax.t
                                                                  option 
                                                                  | Null of
                                                                  ('M, 
                                                                  unit)
                                                                  Syntax.t
                                                                  option 
                                                                  | Number of
                                                                  ('M, 
                                                                  unit)
                                                                  Syntax.t
                                                                  option 
                                                                  | BigInt of
                                                                  ('M, 
                                                                  unit)
                                                                  Syntax.t
                                                                  option 
                                                                  | String of
                                                                  ('M, 
                                                                  unit)
                                                                  Syntax.t
                                                                  option 
                                                                  | Boolean
                                                                  of
                                                                  {
                                                                  raw:
                                                                    [
                                                                    `Boolean 
                                                                    | `Bool ] ;
                                                                  comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  
                                                                  | Symbol of
                                                                  ('M, 
                                                                  unit)
                                                                  Syntax.t
                                                                  option 
                                                                  | Exists of
                                                                  ('M, 
                                                                  unit)
                                                                  Syntax.t
                                                                  option 
                                                                  | Nullable
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  Nullable.t
                                                                  
                                                                  | Function
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  Function.t
                                                                  
                                                                  | Component
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  Component.t
                                                                  
                                                                  | Object of
                                                                  ('M, 
                                                                  'T)
                                                                  Object.t 
                                                                  | Interface
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  Interface.t
                                                                  
                                                                  | Array of
                                                                  ('M, 
                                                                  'T) Array.t
                                                                  
                                                                  |
                                                                  Conditional
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  Conditional.t
                                                                  
                                                                  | Infer of
                                                                  ('M, 
                                                                  'T) Infer.t
                                                                  
                                                                  | Generic
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  Generic.t 
                                                                  |
                                                                  IndexedAccess
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  IndexedAccess.t
                                                                  
                                                                  |
                                                                  OptionalIndexedAccess
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  OptionalIndexedAccess.t
                                                                  
                                                                  | Union of
                                                                  ('M, 
                                                                  'T) Union.t
                                                                  
                                                                  |
                                                                  Intersection
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  Intersection.t
                                                                  
                                                                  | Typeof of
                                                                  ('M, 
                                                                  'T)
                                                                  Typeof.t 
                                                                  | Keyof of
                                                                  ('M, 
                                                                  'T) Keyof.t
                                                                  
                                                                  | Renders
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  Renders.t 
                                                                  | ReadOnly
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  ReadOnly.t
                                                                  
                                                                  | Tuple of
                                                                  ('M, 
                                                                  'T) Tuple.t
                                                                  
                                                                  |
                                                                  StringLiteral
                                                                  of 'M
                                                                  StringLiteral.t
                                                                  
                                                                  |
                                                                  NumberLiteral
                                                                  of 'M
                                                                  NumberLiteral.t
                                                                  
                                                                  |
                                                                  BigIntLiteral
                                                                  of 'M
                                                                  BigIntLiteral.t
                                                                  
                                                                  |
                                                                  BooleanLiteral
                                                                  of 'M
                                                                  BooleanLiteral.t
                                                                  
                                                                  |
                                                                  TemplateLiteral
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  TemplateLiteral.t
                                                                  
                                                                  | Unknown
                                                                  of (
                                                                  'M, 
                                                                  unit)
                                                                  Syntax.t
                                                                  option 
                                                                  | Never of
                                                                  ('M, 
                                                                  unit)
                                                                  Syntax.t
                                                                  option 
                                                                  | Undefined
                                                                  of (
                                                                  'M, 
                                                                  unit)
                                                                  Syntax.t
                                                                  option 
                                                                  |
                                                                  UniqueSymbol
                                                                  of (
                                                                  'M, 
                                                                  unit)
                                                                  Syntax.t
                                                                  option 
                                                                  |
                                                                  ConstructorType
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  ConstructorType.t
                                                                  
                                                                and (
                                                                  'M,
                                                                  'T) annotation =
                                                                  ('M * (
                                                                    'M, 
                                                                    'T) t)
                                                                and (
                                                                  'M,
                                                                  'T) type_guard_annotation =
                                                                  ('M * (
                                                                    'M, 
                                                                    'T)
                                                                    Type.TypeGuard.t)
                                                                and (
                                                                  'M,
                                                                  'T) annotation_or_hint =
                                                                  | Missing
                                                                  of 'T 
                                                                  | Available
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  Type.annotation
                                                                  [@@deriving
                                                                    show]
                                                                and (
                                                                  'M,
                                                                  'T) component_renders_annotation =
                                                                  |
                                                                  MissingRenders
                                                                  of 'T 
                                                                  |
                                                                  AvailableRenders
                                                                  of 'M *
                                                                  ('M, 
                                                                  'T)
                                                                  Type.Renders.t
                                                                  [@@deriving
                                                                    show]
                                                                module
                                                                TypeParam :
                                                                sig
                                                                  type bound_kind =
                                                                    | Colon 
                                                                    | Extends 
                                                                  [@@deriving
                                                                    show]
                                                                  module
                                                                  ConstModifier
                                                                  :
                                                                  sig
                                                                    type 
                                                                    'M t =
                                                                    ('M *
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option)
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                  and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    name:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    bound:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.annotation_or_hint
                                                                    ;
                                                                    bound_kind:
                                                                    bound_kind
                                                                    ;
                                                                    variance:
                                                                    'M
                                                                    Variance.t
                                                                    option ;
                                                                    default:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t
                                                                    option ;
                                                                    const:
                                                                    'M
                                                                    ConstModifier.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                TypeParams :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                  and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    params:
                                                                    ('M, 
                                                                    'T)
                                                                    TypeParam.t
                                                                    list ;
                                                                    comments:
                                                                    ('M,
                                                                    'M
                                                                    Comment.t
                                                                    list)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                TypeArgs :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                  and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    arguments:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t
                                                                    list ;
                                                                    comments:
                                                                    ('M,
                                                                    'M
                                                                    Comment.t
                                                                    list)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                Predicate :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                  and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    kind:
                                                                    ('M, 
                                                                    'T) kind ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  and (
                                                                    'M,
                                                                    'T) kind =
                                                                    |
                                                                    Declared
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Expression.t
                                                                    
                                                                    |
                                                                    Inferred 
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                TypeGuard :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                  and kind =
                                                                    | Default
                                                                    
                                                                    | Asserts
                                                                    
                                                                    | Implies 
                                                                  and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    kind:
                                                                    kind ;
                                                                    guard:
                                                                    (('M, 
                                                                    'M)
                                                                    Identifier.t
                                                                    * (
                                                                    'M, 
                                                                    'T)
                                                                    Type.t
                                                                    option) ;
                                                                    comments:
                                                                    ('M,
                                                                    'M
                                                                    Comment.t
                                                                    list)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                              end =
                                                         struct
                                                           module Conditional =
                                                             struct
                                                               type (
                                                                 'M, 
                                                                 'T) t =
                                                                 {
                                                                 check_type:
                                                                   ('M, 
                                                                    'T)
                                                                    Type.t
                                                                   ;
                                                                 extends_type:
                                                                   ('M, 
                                                                    'T)
                                                                    Type.t
                                                                   ;
                                                                 true_type:
                                                                   ('M, 
                                                                    'T)
                                                                    Type.t
                                                                   ;
                                                                 false_type:
                                                                   ('M, 
                                                                    'T)
                                                                    Type.t
                                                                   ;
                                                                 comments:
                                                                   ('M, 
                                                                    unit)
                                                                    Syntax.t
                                                                    option
                                                                   }[@@deriving
                                                                    show]
                                                             end
                                                           module Infer =
                                                             struct
                                                               type (
                                                                 'M, 
                                                                 'T) t =
                                                                 {
                                                                 tparam:
                                                                   ('M, 
                                                                    'T)
                                                                    Type.TypeParam.t
                                                                   ;
                                                                 comments:
                                                                   ('M, 
                                                                    unit)
                                                                    Syntax.t
                                                                    option
                                                                   }[@@deriving
                                                                    show]
                                                             end
                                                           module Function =
                                                             struct
                                                               module Param =
                                                                 struct
                                                                   type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                   and (
                                                                    'M,
                                                                    'T) t' =
                                                                    |
                                                                    Anonymous
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Type.t 
                                                                    | Labeled
                                                                    of
                                                                    {
                                                                    name:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    optional:
                                                                    bool } 
                                                                    |
                                                                    Destructuring
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Pattern.t 
                                                                   [@@deriving
                                                                    show]
                                                                 end
                                                               module RestParam =
                                                                 struct
                                                                   type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                   and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Param.t ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                   [@@deriving
                                                                    show]
                                                                 end
                                                               module ThisParam =
                                                                 struct
                                                                   type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                   and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.annotation
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                   [@@deriving
                                                                    show]
                                                                 end
                                                               module Params =
                                                                 struct
                                                                   type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                   and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    this_:
                                                                    ('M, 
                                                                    'T)
                                                                    ThisParam.t
                                                                    option ;
                                                                    params:
                                                                    ('M, 
                                                                    'T)
                                                                    Param.t
                                                                    list ;
                                                                    rest:
                                                                    ('M, 
                                                                    'T)
                                                                    RestParam.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    'M
                                                                    Comment.t
                                                                    list)
                                                                    Syntax.t
                                                                    option }
                                                                   [@@deriving
                                                                    show]
                                                                 end
                                                               type (
                                                                 'M, 
                                                                 'T) t =
                                                                 {
                                                                 tparams:
                                                                   ('M, 
                                                                    'T)
                                                                    Type.TypeParams.t
                                                                    option
                                                                   ;
                                                                 params:
                                                                   ('M, 
                                                                    'T)
                                                                    Params.t
                                                                   ;
                                                                 return:
                                                                   ('M, 
                                                                    'T)
                                                                    return_annotation
                                                                   ;
                                                                 comments:
                                                                   ('M, 
                                                                    unit)
                                                                    Syntax.t
                                                                    option
                                                                   ;
                                                                 effect_:
                                                                   Function.effect_
                                                                   }
                                                               and ('M,
                                                                 'T) return_annotation =
                                                                 | Missing of
                                                                 'M 
                                                                 | Available
                                                                 of (
                                                                 'M, 
                                                                 'T) Type.t 
                                                                 | TypeGuard
                                                                 of (
                                                                 'M, 
                                                                 'T)
                                                                 Type.TypeGuard.t
                                                                 [@@deriving
                                                                   show]
                                                             end
                                                           module Component =
                                                             struct
                                                               module Param =
                                                                 struct
                                                                   type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                   and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    name:
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.ComponentDeclaration.Param.param_name
                                                                    ;
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.annotation
                                                                    ;
                                                                    optional:
                                                                    bool }
                                                                   [@@deriving
                                                                    show]
                                                                 end
                                                               module RestParam =
                                                                 struct
                                                                   type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                   and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    option ;
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    optional:
                                                                    bool ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                   [@@deriving
                                                                    show]
                                                                 end
                                                               module Params =
                                                                 struct
                                                                   type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                   and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    params:
                                                                    ('M, 
                                                                    'T)
                                                                    Param.t
                                                                    list ;
                                                                    rest:
                                                                    ('M, 
                                                                    'T)
                                                                    RestParam.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    'M
                                                                    Comment.t
                                                                    list)
                                                                    Syntax.t
                                                                    option }
                                                                   [@@deriving
                                                                    show]
                                                                 end
                                                               type (
                                                                 'M, 
                                                                 'T) t =
                                                                 {
                                                                 tparams:
                                                                   ('M, 
                                                                    'T)
                                                                    Type.TypeParams.t
                                                                    option
                                                                   ;
                                                                 params:
                                                                   ('M, 
                                                                    'T)
                                                                    Params.t
                                                                   ;
                                                                 renders:
                                                                   ('M, 
                                                                    'T)
                                                                    Type.component_renders_annotation
                                                                   ;
                                                                 comments:
                                                                   ('M, 
                                                                    unit)
                                                                    Syntax.t
                                                                    option
                                                                   }[@@deriving
                                                                    show]
                                                             end
                                                           module Generic =
                                                             struct
                                                               module Identifier =
                                                                 struct
                                                                   type (
                                                                    'M,
                                                                    'T) t =
                                                                    |
                                                                    Unqualified
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    
                                                                    |
                                                                    Qualified
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    qualified
                                                                    
                                                                    |
                                                                    ImportTypeAnnot
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    import_type
                                                                    
                                                                   and (
                                                                    'M,
                                                                    'T) qualified =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    qualified')
                                                                   and (
                                                                    'M,
                                                                    'T) qualified' =
                                                                    {
                                                                    qualification:
                                                                    ('M, 
                                                                    'T) t ;
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    }
                                                                   and (
                                                                    'M,
                                                                    'T) import_type =
                                                                    ('T * 'M
                                                                    import_type')
                                                                   and 
                                                                    'M import_type' =
                                                                    {
                                                                    argument:
                                                                    ('M * 'M
                                                                    StringLiteral.t)
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                   [@@deriving
                                                                    show]
                                                                 end
                                                               type (
                                                                 'M, 
                                                                 'T) t =
                                                                 {
                                                                 id:
                                                                   ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                   ;
                                                                 targs:
                                                                   ('M, 
                                                                    'T)
                                                                    Type.TypeArgs.t
                                                                    option
                                                                   ;
                                                                 comments:
                                                                   ('M, 
                                                                    unit)
                                                                    Syntax.t
                                                                    option
                                                                   }[@@deriving
                                                                    show]
                                                             end
                                                           module IndexedAccess =
                                                             struct
                                                               type (
                                                                 'M, 
                                                                 'T) t =
                                                                 {
                                                                 _object:
                                                                   ('M, 
                                                                    'T)
                                                                    Type.t
                                                                   ;
                                                                 index:
                                                                   ('M, 
                                                                    'T)
                                                                    Type.t
                                                                   ;
                                                                 comments:
                                                                   ('M, 
                                                                    unit)
                                                                    Syntax.t
                                                                    option
                                                                   }[@@deriving
                                                                    show]
                                                             end
                                                           module OptionalIndexedAccess =
                                                             struct
                                                               type (
                                                                 'M, 
                                                                 'T) t =
                                                                 {
                                                                 indexed_access:
                                                                   ('M, 
                                                                    'T)
                                                                    IndexedAccess.t
                                                                   ;
                                                                 optional:
                                                                   bool }
                                                               [@@deriving
                                                                 show]
                                                             end
                                                           module Object =
                                                             struct
                                                               module Property =
                                                                 struct
                                                                   type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                   and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    key:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.Object.Property.key
                                                                    ;
                                                                    value:
                                                                    ('M, 
                                                                    'T) value ;
                                                                    optional:
                                                                    bool ;
                                                                    static:
                                                                    bool ;
                                                                    proto:
                                                                    bool ;
                                                                    _method:
                                                                    bool ;
                                                                    abstract:
                                                                    bool ;
                                                                    override:
                                                                    bool ;
                                                                    variance:
                                                                    'M
                                                                    Variance.t
                                                                    option ;
                                                                    ts_accessibility:
                                                                    'M
                                                                    Class.TSAccessibility.t
                                                                    option ;
                                                                    init:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                   and (
                                                                    'M,
                                                                    'T) value =
                                                                    | Init of
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t
                                                                    option 
                                                                    | Get of
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Function.t)
                                                                    
                                                                    | Set of
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Function.t)
                                                                    [@@deriving
                                                                    show]
                                                                 end
                                                               module SpreadProperty =
                                                                 struct
                                                                   type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                   and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                   [@@deriving
                                                                    show]
                                                                 end
                                                               module Indexer =
                                                                 struct
                                                                   type (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'M)
                                                                    Identifier.t
                                                                    option ;
                                                                    key:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    value:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    static:
                                                                    bool ;
                                                                    variance:
                                                                    'M
                                                                    Variance.t
                                                                    option ;
                                                                    optional:
                                                                    bool ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                   and (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                   [@@deriving
                                                                    show]
                                                                 end
                                                               module MappedType =
                                                                 struct
                                                                   type optional_flag =
                                                                    |
                                                                    PlusOptional
                                                                    
                                                                    |
                                                                    MinusOptional
                                                                    
                                                                    |
                                                                    Optional
                                                                    
                                                                    |
                                                                    NoOptionalFlag
                                                                    [@@deriving
                                                                    show]
                                                                   type variance_op =
                                                                    | Add 
                                                                    | Remove 
                                                                   [@@deriving
                                                                    show]
                                                                   type (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    key_tparam:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.TypeParam.t
                                                                    ;
                                                                    prop_type:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    source_type:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    name_type:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t
                                                                    option ;
                                                                    variance:
                                                                    'M
                                                                    Variance.t
                                                                    option ;
                                                                    variance_op:
                                                                    variance_op
                                                                    option ;
                                                                    optional:
                                                                    optional_flag
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                   and (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                   [@@deriving
                                                                    show]
                                                                 end
                                                               module CallProperty =
                                                                 struct
                                                                   type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                   and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    value:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Function.t)
                                                                    ;
                                                                    static:
                                                                    bool ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                   [@@deriving
                                                                    show]
                                                                 end
                                                               module InternalSlot =
                                                                 struct
                                                                   type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                   and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'M)
                                                                    Identifier.t
                                                                    ;
                                                                    value:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    optional:
                                                                    bool ;
                                                                    static:
                                                                    bool ;
                                                                    _method:
                                                                    bool ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                   [@@deriving
                                                                    show]
                                                                 end
                                                               module PrivateField =
                                                                 struct
                                                                   type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                   and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    key:
                                                                    'M
                                                                    PrivateName.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                   [@@deriving
                                                                    show]
                                                                 end
                                                               type (
                                                                 'M, 
                                                                 'T) t =
                                                                 {
                                                                 exact: bool ;
                                                                 inexact:
                                                                   bool ;
                                                                 properties:
                                                                   ('M, 
                                                                    'T)
                                                                    property
                                                                    list
                                                                   ;
                                                                 comments:
                                                                   ('M,
                                                                    'M
                                                                    Comment.t
                                                                    list)
                                                                    Syntax.t
                                                                    option
                                                                   }
                                                               and ('M,
                                                                 'T) property =
                                                                 | Property
                                                                 of (
                                                                 'M, 
                                                                 'T)
                                                                 Property.t 
                                                                 |
                                                                 SpreadProperty
                                                                 of (
                                                                 'M, 
                                                                 'T)
                                                                 SpreadProperty.t
                                                                 
                                                                 | Indexer of
                                                                 ('M, 
                                                                 'T)
                                                                 Indexer.t 
                                                                 |
                                                                 CallProperty
                                                                 of (
                                                                 'M, 
                                                                 'T)
                                                                 CallProperty.t
                                                                 
                                                                 |
                                                                 InternalSlot
                                                                 of (
                                                                 'M, 
                                                                 'T)
                                                                 InternalSlot.t
                                                                 
                                                                 | MappedType
                                                                 of (
                                                                 'M, 
                                                                 'T)
                                                                 MappedType.t
                                                                 
                                                                 |
                                                                 PrivateField
                                                                 of (
                                                                 'M, 
                                                                 'T)
                                                                 PrivateField.t
                                                                 [@@deriving
                                                                   show]
                                                             end
                                                           module Interface =
                                                             struct
                                                               type (
                                                                 'M, 
                                                                 'T) t =
                                                                 {
                                                                 body:
                                                                   ('M * (
                                                                    'M, 
                                                                    'T)
                                                                    Object.t)
                                                                   ;
                                                                 extends:
                                                                   ('M * (
                                                                    'M, 
                                                                    'T)
                                                                    Generic.t)
                                                                    list
                                                                   ;
                                                                 comments:
                                                                   ('M, 
                                                                    unit)
                                                                    Syntax.t
                                                                    option
                                                                   }[@@deriving
                                                                    show]
                                                             end
                                                           module Nullable =
                                                             struct
                                                               type (
                                                                 'M, 
                                                                 'T) t =
                                                                 {
                                                                 argument:
                                                                   ('M, 
                                                                    'T)
                                                                    Type.t
                                                                   ;
                                                                 comments:
                                                                   ('M, 
                                                                    unit)
                                                                    Syntax.t
                                                                    option
                                                                   }[@@deriving
                                                                    show]
                                                             end
                                                           module Typeof =
                                                             struct
                                                               module Target =
                                                                 struct
                                                                   type (
                                                                    'M,
                                                                    'T) t =
                                                                    |
                                                                    Unqualified
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    
                                                                    |
                                                                    Qualified
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    qualified
                                                                    
                                                                    | Import
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Type.Generic.Identifier.import_type
                                                                    
                                                                   and (
                                                                    'M,
                                                                    'T) qualified' =
                                                                    {
                                                                    qualification:
                                                                    ('M, 
                                                                    'T) t ;
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    }
                                                                   and (
                                                                    'M,
                                                                    'T) qualified =
                                                                    ('T *
                                                                    ('M, 
                                                                    'T)
                                                                    qualified')
                                                                   [@@deriving
                                                                    show]
                                                                 end
                                                               type (
                                                                 'M, 
                                                                 'T) t =
                                                                 {
                                                                 argument:
                                                                   ('M, 
                                                                    'T)
                                                                    Target.t
                                                                   ;
                                                                 targs:
                                                                   ('M, 
                                                                    'T)
                                                                    Type.TypeArgs.t
                                                                    option
                                                                   ;
                                                                 comments:
                                                                   ('M, 
                                                                    unit)
                                                                    Syntax.t
                                                                    option
                                                                   }[@@deriving
                                                                    show]
                                                             end
                                                           module Keyof =
                                                             struct
                                                               type (
                                                                 'M, 
                                                                 'T) t =
                                                                 {
                                                                 argument:
                                                                   ('M, 
                                                                    'T)
                                                                    Type.t
                                                                   ;
                                                                 comments:
                                                                   ('M, 
                                                                    unit)
                                                                    Syntax.t
                                                                    option
                                                                   }[@@deriving
                                                                    show]
                                                             end
                                                           module Renders =
                                                             struct
                                                               type variant =
                                                                 | Normal 
                                                                 | Maybe 
                                                                 | Star 
                                                               [@@deriving
                                                                 show]
                                                               type (
                                                                 'M, 
                                                                 'T) t =
                                                                 {
                                                                 operator_loc:
                                                                   'M ;
                                                                 argument:
                                                                   ('M, 
                                                                    'T)
                                                                    Type.t
                                                                   ;
                                                                 comments:
                                                                   ('M, 
                                                                    unit)
                                                                    Syntax.t
                                                                    option
                                                                   ;
                                                                 variant:
                                                                   variant }
                                                               [@@deriving
                                                                 show]
                                                             end
                                                           module ReadOnly =
                                                             struct
                                                               type (
                                                                 'M, 
                                                                 'T) t =
                                                                 {
                                                                 argument:
                                                                   ('M, 
                                                                    'T)
                                                                    Type.t
                                                                   ;
                                                                 comments:
                                                                   ('M, 
                                                                    unit)
                                                                    Syntax.t
                                                                    option
                                                                   }[@@deriving
                                                                    show]
                                                             end
                                                           module ConstructorType =
                                                             struct
                                                               type (
                                                                 'M, 
                                                                 'T) t =
                                                                 {
                                                                 abstract_:
                                                                   bool ;
                                                                 func:
                                                                   ('M, 
                                                                    'T)
                                                                    Function.t
                                                                   }[@@deriving
                                                                    show]
                                                             end
                                                           module Tuple =
                                                             struct
                                                               module LabeledElement =
                                                                 struct
                                                                   type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    name:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    variance:
                                                                    'M
                                                                    Variance.t
                                                                    option ;
                                                                    optional:
                                                                    bool }
                                                                   [@@deriving
                                                                    show]
                                                                 end
                                                               module UnlabeledElement =
                                                                 struct
                                                                   type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    optional:
                                                                    bool }
                                                                   [@@deriving
                                                                    show]
                                                                 end
                                                               module SpreadElement =
                                                                 struct
                                                                   type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    name:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    option ;
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t }
                                                                   [@@deriving
                                                                    show]
                                                                 end
                                                               type (
                                                                 'M,
                                                                 'T) element =
                                                                 ('M * (
                                                                   'M, 
                                                                   'T)
                                                                   element')
                                                               [@@deriving
                                                                 show]
                                                               and ('M,
                                                                 'T) element' =
                                                                 |
                                                                 UnlabeledElement
                                                                 of (
                                                                 'M, 
                                                                 'T)
                                                                 UnlabeledElement.t
                                                                 
                                                                 |
                                                                 LabeledElement
                                                                 of (
                                                                 'M, 
                                                                 'T)
                                                                 LabeledElement.t
                                                                 
                                                                 |
                                                                 SpreadElement
                                                                 of (
                                                                 'M, 
                                                                 'T)
                                                                 SpreadElement.t
                                                                 [@@deriving
                                                                   show]
                                                               and ('M,
                                                                 'T) t =
                                                                 {
                                                                 elements:
                                                                   ('M, 
                                                                    'T)
                                                                    element
                                                                    list
                                                                   ;
                                                                 inexact:
                                                                   bool ;
                                                                 comments:
                                                                   ('M, 
                                                                    unit)
                                                                    Syntax.t
                                                                    option
                                                                   }[@@deriving
                                                                    show]
                                                             end
                                                           module Array =
                                                             struct
                                                               type (
                                                                 'M, 
                                                                 'T) t =
                                                                 {
                                                                 argument:
                                                                   ('M, 
                                                                    'T)
                                                                    Type.t
                                                                   ;
                                                                 comments:
                                                                   ('M, 
                                                                    unit)
                                                                    Syntax.t
                                                                    option
                                                                   }[@@deriving
                                                                    show]
                                                             end
                                                           module Union =
                                                             struct
                                                               type (
                                                                 'M, 
                                                                 'T) t =
                                                                 {
                                                                 types:
                                                                   (('M, 
                                                                    'T)
                                                                    Type.t *
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t *
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t
                                                                    list)
                                                                   ;
                                                                 comments:
                                                                   ('M, 
                                                                    unit)
                                                                    Syntax.t
                                                                    option
                                                                   }[@@deriving
                                                                    show]
                                                             end
                                                           module Intersection =
                                                             struct
                                                               type (
                                                                 'M, 
                                                                 'T) t =
                                                                 {
                                                                 types:
                                                                   (('M, 
                                                                    'T)
                                                                    Type.t *
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t *
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t
                                                                    list)
                                                                   ;
                                                                 comments:
                                                                   ('M, 
                                                                    unit)
                                                                    Syntax.t
                                                                    option
                                                                   }[@@deriving
                                                                    show]
                                                             end
                                                           module TemplateLiteral =
                                                             struct
                                                               module Element =
                                                                 struct
                                                                   type value =
                                                                    {
                                                                    raw:
                                                                    string ;
                                                                    cooked:
                                                                    string }
                                                                   and 
                                                                    'M t =
                                                                    ('M * t')
                                                                   and t' =
                                                                    {
                                                                    value:
                                                                    value ;
                                                                    tail:
                                                                    bool }
                                                                   [@@deriving
                                                                    show]
                                                                 end
                                                               type (
                                                                 'M, 
                                                                 'T) t =
                                                                 {
                                                                 quasis:
                                                                   'M
                                                                    Element.t
                                                                    list
                                                                   ;
                                                                 types:
                                                                   ('M, 
                                                                    'T)
                                                                    Type.t
                                                                    list
                                                                   ;
                                                                 comments:
                                                                   ('M, 
                                                                    unit)
                                                                    Syntax.t
                                                                    option
                                                                   }[@@deriving
                                                                    show]
                                                             end
                                                           type ('M, 
                                                             'T) t =
                                                             ('T * ('M, 
                                                               'T) t')
                                                           and ('M, 'T) t' =
                                                             | Any of (
                                                             'M, unit)
                                                             Syntax.t option
                                                             
                                                             | Mixed of (
                                                             'M, unit)
                                                             Syntax.t option
                                                             
                                                             | Empty of (
                                                             'M, unit)
                                                             Syntax.t option
                                                             
                                                             | Void of (
                                                             'M, unit)
                                                             Syntax.t option
                                                             
                                                             | Null of (
                                                             'M, unit)
                                                             Syntax.t option
                                                             
                                                             | Number of (
                                                             'M, unit)
                                                             Syntax.t option
                                                             
                                                             | BigInt of (
                                                             'M, unit)
                                                             Syntax.t option
                                                             
                                                             | String of (
                                                             'M, unit)
                                                             Syntax.t option
                                                             
                                                             | Boolean of
                                                             {
                                                             raw:
                                                               [ `Boolean 
                                                               | `Bool ] ;
                                                             comments:
                                                               ('M, unit)
                                                                 Syntax.t
                                                                 option
                                                               }
                                                             
                                                             | Symbol of (
                                                             'M, unit)
                                                             Syntax.t option
                                                             
                                                             | Exists of (
                                                             'M, unit)
                                                             Syntax.t option
                                                             
                                                             | Nullable of
                                                             ('M, 'T)
                                                             Nullable.t 
                                                             | Function of
                                                             ('M, 'T)
                                                             Function.t 
                                                             | Component of
                                                             ('M, 'T)
                                                             Component.t 
                                                             | Object of (
                                                             'M, 'T) Object.t
                                                             
                                                             | Interface of
                                                             ('M, 'T)
                                                             Interface.t 
                                                             | Array of (
                                                             'M, 'T) Array.t
                                                             
                                                             | Conditional of
                                                             ('M, 'T)
                                                             Conditional.t 
                                                             | Infer of (
                                                             'M, 'T) Infer.t
                                                             
                                                             | Generic of
                                                             ('M, 'T)
                                                             Generic.t 
                                                             | IndexedAccess
                                                             of ('M, 
                                                             'T)
                                                             IndexedAccess.t
                                                             
                                                             |
                                                             OptionalIndexedAccess
                                                             of ('M, 
                                                             'T)
                                                             OptionalIndexedAccess.t
                                                             
                                                             | Union of (
                                                             'M, 'T) Union.t
                                                             
                                                             | Intersection
                                                             of ('M, 
                                                             'T)
                                                             Intersection.t 
                                                             | Typeof of (
                                                             'M, 'T) Typeof.t
                                                             
                                                             | Keyof of (
                                                             'M, 'T) Keyof.t
                                                             
                                                             | Renders of
                                                             ('M, 'T)
                                                             Renders.t 
                                                             | ReadOnly of
                                                             ('M, 'T)
                                                             ReadOnly.t 
                                                             | Tuple of (
                                                             'M, 'T) Tuple.t
                                                             
                                                             | StringLiteral
                                                             of 'M
                                                             StringLiteral.t
                                                             
                                                             | NumberLiteral
                                                             of 'M
                                                             NumberLiteral.t
                                                             
                                                             | BigIntLiteral
                                                             of 'M
                                                             BigIntLiteral.t
                                                             
                                                             | BooleanLiteral
                                                             of 'M
                                                             BooleanLiteral.t
                                                             
                                                             |
                                                             TemplateLiteral
                                                             of ('M, 
                                                             'T)
                                                             TemplateLiteral.t
                                                             
                                                             | Unknown of
                                                             ('M, unit)
                                                             Syntax.t option
                                                             
                                                             | Never of (
                                                             'M, unit)
                                                             Syntax.t option
                                                             
                                                             | Undefined of
                                                             ('M, unit)
                                                             Syntax.t option
                                                             
                                                             | UniqueSymbol
                                                             of ('M, 
                                                             unit) Syntax.t
                                                             option 
                                                             |
                                                             ConstructorType
                                                             of ('M, 
                                                             'T)
                                                             ConstructorType.t
                                                             
                                                           and ('M,
                                                             'T) annotation =
                                                             ('M * ('M, 
                                                               'T) t)
                                                           and ('M,
                                                             'T) type_guard_annotation =
                                                             ('M * ('M, 
                                                               'T)
                                                               Type.TypeGuard.t)
                                                           and ('M,
                                                             'T) annotation_or_hint =
                                                             | Missing of 'T
                                                             
                                                             | Available of
                                                             ('M, 'T)
                                                             Type.annotation 
                                                           [@@deriving 
                                                             show]
                                                           and ('M,
                                                             'T) component_renders_annotation =
                                                             | MissingRenders
                                                             of 'T 
                                                             |
                                                             AvailableRenders
                                                             of 'M * (
                                                             'M, 'T)
                                                             Type.Renders.t 
                                                           [@@deriving 
                                                             show]
                                                           module TypeParam =
                                                             struct
                                                               type bound_kind =
                                                                 | Colon 
                                                                 | Extends 
                                                               [@@deriving
                                                                 show]
                                                               module ConstModifier =
                                                                 struct
                                                                   type 
                                                                    'M t =
                                                                    ('M *
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option)
                                                                   [@@deriving
                                                                    show]
                                                                 end
                                                               type (
                                                                 'M, 
                                                                 'T) t =
                                                                 ('M * (
                                                                   'M, 
                                                                   'T) t')
                                                               and ('M,
                                                                 'T) t' =
                                                                 {
                                                                 name:
                                                                   ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                   ;
                                                                 bound:
                                                                   ('M, 
                                                                    'T)
                                                                    Type.annotation_or_hint
                                                                   ;
                                                                 bound_kind:
                                                                   bound_kind ;
                                                                 variance:
                                                                   'M
                                                                    Variance.t
                                                                    option
                                                                   ;
                                                                 default:
                                                                   ('M, 
                                                                    'T)
                                                                    Type.t
                                                                    option
                                                                   ;
                                                                 const:
                                                                   'M
                                                                    ConstModifier.t
                                                                    option
                                                                   }[@@deriving
                                                                    show]
                                                             end
                                                           module TypeParams =
                                                             struct
                                                               type (
                                                                 'M, 
                                                                 'T) t =
                                                                 ('M * (
                                                                   'M, 
                                                                   'T) t')
                                                               and ('M,
                                                                 'T) t' =
                                                                 {
                                                                 params:
                                                                   ('M, 
                                                                    'T)
                                                                    TypeParam.t
                                                                    list
                                                                   ;
                                                                 comments:
                                                                   ('M,
                                                                    'M
                                                                    Comment.t
                                                                    list)
                                                                    Syntax.t
                                                                    option
                                                                   }[@@deriving
                                                                    show]
                                                             end
                                                           module TypeArgs =
                                                             struct
                                                               type (
                                                                 'M, 
                                                                 'T) t =
                                                                 ('M * (
                                                                   'M, 
                                                                   'T) t')
                                                               and ('M,
                                                                 'T) t' =
                                                                 {
                                                                 arguments:
                                                                   ('M, 
                                                                    'T)
                                                                    Type.t
                                                                    list
                                                                   ;
                                                                 comments:
                                                                   ('M,
                                                                    'M
                                                                    Comment.t
                                                                    list)
                                                                    Syntax.t
                                                                    option
                                                                   }[@@deriving
                                                                    show]
                                                             end
                                                           module Predicate =
                                                             struct
                                                               type (
                                                                 'M, 
                                                                 'T) t =
                                                                 ('M * (
                                                                   'M, 
                                                                   'T) t')
                                                               and ('M,
                                                                 'T) t' =
                                                                 {
                                                                 kind:
                                                                   ('M, 
                                                                    'T) kind
                                                                   ;
                                                                 comments:
                                                                   ('M, 
                                                                    unit)
                                                                    Syntax.t
                                                                    option
                                                                   }
                                                               and ('M,
                                                                 'T) kind =
                                                                 | Declared
                                                                 of (
                                                                 'M, 
                                                                 'T)
                                                                 Expression.t
                                                                 
                                                                 | Inferred 
                                                               [@@deriving
                                                                 show]
                                                             end
                                                           module TypeGuard =
                                                             struct
                                                               type (
                                                                 'M, 
                                                                 'T) t =
                                                                 ('M * (
                                                                   'M, 
                                                                   'T) t')
                                                               and kind =
                                                                 | Default 
                                                                 | Asserts 
                                                                 | Implies 
                                                               and ('M,
                                                                 'T) t' =
                                                                 {
                                                                 kind: kind ;
                                                                 guard:
                                                                   (('M, 
                                                                    'M)
                                                                    Identifier.t
                                                                    * (
                                                                    'M, 
                                                                    'T)
                                                                    Type.t
                                                                    option)
                                                                   ;
                                                                 comments:
                                                                   ('M,
                                                                    'M
                                                                    Comment.t
                                                                    list)
                                                                    Syntax.t
                                                                    option
                                                                   }[@@deriving
                                                                    show]
                                                             end
                                                         end and
                                                              Statement:
                                                              sig
                                                                module Block
                                                                :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    body:
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.t
                                                                    list ;
                                                                    comments:
                                                                    ('M,
                                                                    'M
                                                                    Comment.t
                                                                    list)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module If :
                                                                sig
                                                                  module
                                                                  Alternate :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    body:
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    test:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    consequent:
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.t
                                                                    ;
                                                                    alternate:
                                                                    ('M, 
                                                                    'T)
                                                                    Alternate.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                Labeled :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    label:
                                                                    ('M, 
                                                                    'M)
                                                                    Identifier.t
                                                                    ;
                                                                    body:
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module Break
                                                                :
                                                                sig
                                                                  type 
                                                                    'M t =
                                                                    {
                                                                    label:
                                                                    ('M, 
                                                                    'M)
                                                                    Identifier.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                Continue :
                                                                sig
                                                                  type 
                                                                    'M t =
                                                                    {
                                                                    label:
                                                                    ('M, 
                                                                    'M)
                                                                    Identifier.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                Debugger :
                                                                sig
                                                                  type 
                                                                    'M t =
                                                                    {
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module With :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    _object:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    body:
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                TypeAlias :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    tparams:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.TypeParams.t
                                                                    option ;
                                                                    right:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                OpaqueType :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    tparams:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.TypeParams.t
                                                                    option ;
                                                                    impl_type:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t
                                                                    option ;
                                                                    lower_bound:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t
                                                                    option ;
                                                                    upper_bound:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t
                                                                    option ;
                                                                    legacy_upper_bound:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t
                                                                    option
                                                                    [@ocaml.doc
                                                                    " Invariant: only one of legacy_upper_bound and upper_bound can exist. "];
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                type (
                                                                  'M,
                                                                  'T) match_statement =
                                                                  ('M, 
                                                                    'T,
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.t)
                                                                    Match.t
                                                                [@@deriving
                                                                  show]
                                                                module Switch
                                                                :
                                                                sig
                                                                  module Case
                                                                  :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    test:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    option ;
                                                                    case_test_loc:
                                                                    'M option ;
                                                                    consequent:
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.t
                                                                    list ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    discriminant:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    cases:
                                                                    ('M, 
                                                                    'T)
                                                                    Case.t
                                                                    list ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option ;
                                                                    exhaustive_out:
                                                                    'T }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module Return
                                                                :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option ;
                                                                    return_out:
                                                                    'T }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module Throw
                                                                :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module Try :
                                                                sig
                                                                  module
                                                                  CatchClause
                                                                  :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    param:
                                                                    ('M, 
                                                                    'T)
                                                                    Pattern.t
                                                                    option ;
                                                                    body:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Block.t) ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    block:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Block.t) ;
                                                                    handler:
                                                                    ('M, 
                                                                    'T)
                                                                    CatchClause.t
                                                                    option ;
                                                                    finalizer:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Block.t)
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                VariableDeclaration
                                                                :
                                                                sig
                                                                  module
                                                                  Declarator
                                                                  :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Pattern.t ;
                                                                    init:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    declarations:
                                                                    ('M, 
                                                                    'T)
                                                                    Declarator.t
                                                                    list ;
                                                                    kind:
                                                                    Variable.kind
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module While
                                                                :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    test:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    body:
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                DoWhile :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    body:
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.t
                                                                    ;
                                                                    test:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module For :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    init:
                                                                    ('M, 
                                                                    'T) init
                                                                    option ;
                                                                    test:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    option ;
                                                                    update:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    option ;
                                                                    body:
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  and (
                                                                    'M,
                                                                    'T) init =
                                                                    |
                                                                    InitDeclaration
                                                                    of ('M *
                                                                    (
                                                                    'M, 
                                                                    'T)
                                                                    VariableDeclaration.t)
                                                                    
                                                                    |
                                                                    InitExpression
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Expression.t
                                                                    [@@deriving
                                                                    show]
                                                                end
                                                                module ForIn
                                                                :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    left:
                                                                    ('M, 
                                                                    'T) left ;
                                                                    right:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    body:
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.t
                                                                    ;
                                                                    each:
                                                                    bool ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  and (
                                                                    'M,
                                                                    'T) left =
                                                                    |
                                                                    LeftDeclaration
                                                                    of ('M *
                                                                    (
                                                                    'M, 
                                                                    'T)
                                                                    VariableDeclaration.t)
                                                                    
                                                                    |
                                                                    LeftPattern
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Pattern.t 
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module ForOf
                                                                :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    left:
                                                                    ('M, 
                                                                    'T) left ;
                                                                    right:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    body:
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.t
                                                                    ;
                                                                    await:
                                                                    bool ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  and (
                                                                    'M,
                                                                    'T) left =
                                                                    |
                                                                    LeftDeclaration
                                                                    of ('M *
                                                                    (
                                                                    'M, 
                                                                    'T)
                                                                    VariableDeclaration.t)
                                                                    
                                                                    |
                                                                    LeftPattern
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Pattern.t 
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                EnumDeclaration
                                                                :
                                                                sig
                                                                  type 
                                                                    'M member_name =
                                                                    |
                                                                    Identifier
                                                                    of (
                                                                    'M, 
                                                                    'M)
                                                                    Identifier.t
                                                                    
                                                                    |
                                                                    StringLiteral
                                                                    of ('M *
                                                                    'M
                                                                    StringLiteral.t)
                                                                    [@@deriving
                                                                    show]
                                                                  module
                                                                  DefaultedMember
                                                                  :
                                                                  sig
                                                                    type 
                                                                    'M t =
                                                                    ('M * 'M
                                                                    t')
                                                                    and 
                                                                    'M t' =
                                                                    {
                                                                    id:
                                                                    'M
                                                                    member_name
                                                                    }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  module
                                                                  InitializedMember
                                                                  :
                                                                  sig
                                                                    type (
                                                                    'I,
                                                                    'M) t =
                                                                    ('M *
                                                                    ('I, 
                                                                    'M) t')
                                                                    and (
                                                                    'I,
                                                                    'M) t' =
                                                                    {
                                                                    id:
                                                                    'M
                                                                    member_name
                                                                    ;
                                                                    init:
                                                                    ('M * 'I) }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  type explicit_type =
                                                                    | Boolean
                                                                    
                                                                    | Number
                                                                    
                                                                    | String
                                                                    
                                                                    | Symbol
                                                                    
                                                                    | BigInt 
                                                                  [@@deriving
                                                                    (ord,
                                                                    show)]
                                                                  val compare_explicit_type :
                                                                    explicit_type -> explicit_type -> int
                                                                  type 
                                                                    'M member =
                                                                    |
                                                                    BooleanMember
                                                                    of
                                                                    (
                                                                    'M
                                                                    BooleanLiteral.t,
                                                                    'M)
                                                                    InitializedMember.t
                                                                    
                                                                    |
                                                                    NumberMember
                                                                    of
                                                                    (
                                                                    'M
                                                                    NumberLiteral.t,
                                                                    'M)
                                                                    InitializedMember.t
                                                                    
                                                                    |
                                                                    StringMember
                                                                    of
                                                                    (
                                                                    'M
                                                                    StringLiteral.t,
                                                                    'M)
                                                                    InitializedMember.t
                                                                    
                                                                    |
                                                                    BigIntMember
                                                                    of
                                                                    (
                                                                    'M
                                                                    BigIntLiteral.t,
                                                                    'M)
                                                                    InitializedMember.t
                                                                    
                                                                    |
                                                                    DefaultedMember
                                                                    of 'M
                                                                    DefaultedMember.t
                                                                    [@@deriving
                                                                    show]
                                                                  module Body
                                                                  :
                                                                  sig
                                                                    type 
                                                                    'M t =
                                                                    {
                                                                    members:
                                                                    'M member
                                                                    list ;
                                                                    explicit_type:
                                                                    ('M *
                                                                    explicit_type)
                                                                    option ;
                                                                    has_unknown_members:
                                                                    'M option ;
                                                                    comments:
                                                                    ('M,
                                                                    'M
                                                                    Comment.t
                                                                    list)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    body:
                                                                    'M body ;
                                                                    const_:
                                                                    bool ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  and 
                                                                    'M body =
                                                                    ('M * 'M
                                                                    Body.t)
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                ComponentDeclaration
                                                                :
                                                                sig
                                                                  module
                                                                  RestParam :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Pattern.t ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  module
                                                                  Param :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    name:
                                                                    ('M, 
                                                                    'T)
                                                                    param_name
                                                                    ;
                                                                    local:
                                                                    ('M, 
                                                                    'T)
                                                                    Pattern.t ;
                                                                    default:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    option ;
                                                                    shorthand:
                                                                    bool }
                                                                    and (
                                                                    'M,
                                                                    'T) param_name =
                                                                    |
                                                                    Identifier
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    
                                                                    |
                                                                    StringLiteral
                                                                    of ('M *
                                                                    'M
                                                                    StringLiteral.t)
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  module
                                                                  Params :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    params:
                                                                    ('M, 
                                                                    'T)
                                                                    Param.t
                                                                    list ;
                                                                    rest:
                                                                    ('M, 
                                                                    'T)
                                                                    RestParam.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    'M
                                                                    Comment.t
                                                                    list)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    tparams:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.TypeParams.t
                                                                    option ;
                                                                    params:
                                                                    ('M, 
                                                                    'T)
                                                                    Params.t ;
                                                                    renders:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.component_renders_annotation
                                                                    ;
                                                                    body:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.Block.t)
                                                                    option ;
                                                                    async:
                                                                    bool ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option ;
                                                                    sig_loc:
                                                                    'M }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                Interface :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    tparams:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.TypeParams.t
                                                                    option ;
                                                                    extends:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Type.Generic.t)
                                                                    list ;
                                                                    body:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Type.Object.t)
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                RecordDeclaration
                                                                :
                                                                sig
                                                                  module
                                                                  InvalidPropertySyntax
                                                                  :
                                                                  sig
                                                                    type 
                                                                    'M t =
                                                                    {
                                                                    invalid_variance:
                                                                    'M
                                                                    Variance.t
                                                                    option ;
                                                                    invalid_optional:
                                                                    'M option ;
                                                                    invalid_suffix_semicolon:
                                                                    'M option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  module
                                                                  Property :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('T *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    key:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.Object.Property.key
                                                                    ;
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.annotation
                                                                    ;
                                                                    default_value:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option ;
                                                                    invalid_syntax:
                                                                    'M
                                                                    InvalidPropertySyntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  module
                                                                  StaticProperty
                                                                  :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('T *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    key:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.Object.Property.key
                                                                    ;
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.annotation
                                                                    ;
                                                                    value:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option ;
                                                                    invalid_syntax:
                                                                    'M
                                                                    InvalidPropertySyntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  module Body
                                                                  :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    body:
                                                                    ('M, 
                                                                    'T)
                                                                    element
                                                                    list ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    and (
                                                                    'M,
                                                                    'T) element =
                                                                    | Method
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Class.Method.t
                                                                    
                                                                    |
                                                                    Property
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Property.t
                                                                    
                                                                    |
                                                                    StaticProperty
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    StaticProperty.t
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  module
                                                                  InvalidSyntax
                                                                  :
                                                                  sig
                                                                    type 
                                                                    'M t =
                                                                    {
                                                                    invalid_infix_equals:
                                                                    'M option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    tparams:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.TypeParams.t
                                                                    option ;
                                                                    implements:
                                                                    ('M, 
                                                                    'T)
                                                                    Class.Implements.t
                                                                    option ;
                                                                    body:
                                                                    ('M, 
                                                                    'T)
                                                                    Body.t ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option ;
                                                                    invalid_syntax:
                                                                    'M
                                                                    InvalidSyntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                DeclareClass
                                                                :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) extends =
                                                                    |
                                                                    ExtendsIdent
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Type.Generic.t
                                                                    
                                                                    |
                                                                    ExtendsCall
                                                                    of
                                                                    {
                                                                    callee:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Type.Generic.t)
                                                                    ;
                                                                    arg:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    extends) }
                                                                    [@@deriving
                                                                    show]
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    tparams:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.TypeParams.t
                                                                    option ;
                                                                    body:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Type.Object.t)
                                                                    ;
                                                                    extends:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    extends)
                                                                    option ;
                                                                    mixins:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Type.Generic.t)
                                                                    list ;
                                                                    implements:
                                                                    ('M, 
                                                                    'T)
                                                                    Class.Implements.t
                                                                    option ;
                                                                    abstract:
                                                                    bool ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                DeclareComponent
                                                                :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    tparams:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.TypeParams.t
                                                                    option ;
                                                                    params:
                                                                    ('M, 
                                                                    'T)
                                                                    ComponentDeclaration.Params.t
                                                                    ;
                                                                    renders:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.component_renders_annotation
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                DeclareVariable
                                                                :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    declarations:
                                                                    ('M, 
                                                                    'T)
                                                                    VariableDeclaration.Declarator.t
                                                                    list ;
                                                                    kind:
                                                                    Variable.kind
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                DeclareFunction
                                                                :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    option ;
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.annotation
                                                                    ;
                                                                    predicate:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.Predicate.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option ;
                                                                    implicit_declare:
                                                                    bool }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                DeclareModule
                                                                :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) id =
                                                                    |
                                                                    Identifier
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    
                                                                    | Literal
                                                                    of ('T *
                                                                    'M
                                                                    StringLiteral.t)
                                                                    
                                                                  and (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T) id ;
                                                                    body:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Block.t) ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                DeclareModuleExports
                                                                :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.annotation
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                DeclareNamespace
                                                                :
                                                                sig
                                                                  type keyword =
                                                                    |
                                                                    Namespace
                                                                    
                                                                    | Module 
                                                                  [@@deriving
                                                                    show]
                                                                  type (
                                                                    'M,
                                                                    'T) id =
                                                                    | Global
                                                                    of (
                                                                    'M, 
                                                                    'M)
                                                                    Identifier.t
                                                                    
                                                                    | Local
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    [@@deriving
                                                                    show]
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T) id ;
                                                                    body:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Block.t) ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option ;
                                                                    implicit_declare:
                                                                    bool ;
                                                                    keyword:
                                                                    keyword }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                ExportAssignment
                                                                :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) rhs =
                                                                    |
                                                                    Expression
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Expression.t
                                                                    
                                                                    |
                                                                    DeclareFunction
                                                                    of ('M *
                                                                    (
                                                                    'M, 
                                                                    'T)
                                                                    DeclareFunction.t)
                                                                    [@@deriving
                                                                    show]
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    rhs:
                                                                    ('M, 
                                                                    'T) rhs ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                NamespaceExportDeclaration
                                                                :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                ExportNamedDeclaration
                                                                :
                                                                sig
                                                                  module
                                                                  ExportSpecifier
                                                                  :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    local:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    exported:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    option ;
                                                                    export_kind:
                                                                    Statement.export_kind
                                                                    ;
                                                                    from_remote:
                                                                    bool ;
                                                                    imported_name_def_loc:
                                                                    'M option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  module
                                                                  ExportBatchSpecifier
                                                                  :
                                                                  sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    option)
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    declaration:
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.t
                                                                    option ;
                                                                    specifiers:
                                                                    ('M, 
                                                                    'T)
                                                                    specifier
                                                                    option ;
                                                                    source:
                                                                    ('T * 'M
                                                                    StringLiteral.t)
                                                                    option ;
                                                                    export_kind:
                                                                    Statement.export_kind
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  and (
                                                                    'M,
                                                                    'T) specifier =
                                                                    |
                                                                    ExportSpecifiers
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    ExportSpecifier.t
                                                                    list 
                                                                    |
                                                                    ExportBatchSpecifier
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    ExportBatchSpecifier.t
                                                                    [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                ExportDefaultDeclaration
                                                                :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    default:
                                                                    'T ;
                                                                    declaration:
                                                                    ('M, 
                                                                    'T)
                                                                    declaration
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  and (
                                                                    'M,
                                                                    'T) declaration =
                                                                    |
                                                                    Declaration
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Statement.t
                                                                    
                                                                    |
                                                                    Expression
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Expression.t
                                                                    [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                DeclareExportDeclaration
                                                                :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) declaration =
                                                                    |
                                                                    Variable
                                                                    of ('M *
                                                                    (
                                                                    'M, 
                                                                    'T)
                                                                    DeclareVariable.t)
                                                                    
                                                                    |
                                                                    Function
                                                                    of ('M *
                                                                    (
                                                                    'M, 
                                                                    'T)
                                                                    DeclareFunction.t)
                                                                    
                                                                    | Class
                                                                    of ('M *
                                                                    (
                                                                    'M, 
                                                                    'T)
                                                                    DeclareClass.t)
                                                                    
                                                                    |
                                                                    Component
                                                                    of ('M *
                                                                    (
                                                                    'M, 
                                                                    'T)
                                                                    DeclareComponent.t)
                                                                    
                                                                    |
                                                                    DefaultType
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Type.t 
                                                                    |
                                                                    NamedType
                                                                    of ('M *
                                                                    (
                                                                    'M, 
                                                                    'T)
                                                                    TypeAlias.t)
                                                                    
                                                                    |
                                                                    NamedOpaqueType
                                                                    of ('M *
                                                                    (
                                                                    'M, 
                                                                    'T)
                                                                    OpaqueType.t)
                                                                    
                                                                    |
                                                                    Interface
                                                                    of ('M *
                                                                    (
                                                                    'M, 
                                                                    'T)
                                                                    Interface.t)
                                                                    
                                                                    | Enum of
                                                                    ('M *
                                                                    (
                                                                    'M, 
                                                                    'T)
                                                                    EnumDeclaration.t)
                                                                    
                                                                    |
                                                                    Namespace
                                                                    of ('M *
                                                                    (
                                                                    'M, 
                                                                    'T)
                                                                    DeclareNamespace.t)
                                                                    
                                                                  and (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    default:
                                                                    'M option ;
                                                                    declaration:
                                                                    ('M, 
                                                                    'T)
                                                                    declaration
                                                                    option ;
                                                                    specifiers:
                                                                    ('M, 
                                                                    'T)
                                                                    ExportNamedDeclaration.specifier
                                                                    option ;
                                                                    source:
                                                                    ('T * 'M
                                                                    StringLiteral.t)
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                ImportDeclaration
                                                                :
                                                                sig
                                                                  type import_kind =
                                                                    |
                                                                    ImportType
                                                                    
                                                                    |
                                                                    ImportTypeof
                                                                    
                                                                    |
                                                                    ImportValue
                                                                    
                                                                  and (
                                                                    'M,
                                                                    'T) specifier =
                                                                    |
                                                                    ImportNamedSpecifiers
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    named_specifier
                                                                    list 
                                                                    |
                                                                    ImportNamespaceSpecifier
                                                                    of ('M *
                                                                    (
                                                                    'M, 
                                                                    'T)
                                                                    Identifier.t)
                                                                    
                                                                  and (
                                                                    'M,
                                                                    'T) named_specifier =
                                                                    {
                                                                    kind:
                                                                    import_kind
                                                                    option ;
                                                                    kind_loc:
                                                                    'M option ;
                                                                    local:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    option ;
                                                                    remote:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    remote_name_def_loc:
                                                                    'M option }
                                                                  and (
                                                                    'M,
                                                                    'T) default_identifier =
                                                                    {
                                                                    identifier:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    remote_default_name_def_loc:
                                                                    'M option }
                                                                  and (
                                                                    'M,
                                                                    'T) import_attribute =
                                                                    {
                                                                    loc: 'M ;
                                                                    key:
                                                                    ('M, 
                                                                    'T)
                                                                    import_attribute_key
                                                                    ;
                                                                    value:
                                                                    ('T * 'M
                                                                    StringLiteral.t)
                                                                    }
                                                                  and (
                                                                    'M,
                                                                    'T) import_attribute_key =
                                                                    |
                                                                    Identifier
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    
                                                                    |
                                                                    StringLiteral
                                                                    of 'M *
                                                                    'M
                                                                    StringLiteral.t
                                                                    
                                                                  and (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    import_kind:
                                                                    import_kind
                                                                    ;
                                                                    source:
                                                                    ('T * 'M
                                                                    StringLiteral.t)
                                                                    ;
                                                                    default:
                                                                    ('M, 
                                                                    'T)
                                                                    default_identifier
                                                                    option ;
                                                                    specifiers:
                                                                    ('M, 
                                                                    'T)
                                                                    specifier
                                                                    option ;
                                                                    attributes:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    import_attribute
                                                                    list)
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                ImportEqualsDeclaration
                                                                :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) module_reference =
                                                                    |
                                                                    ExternalModuleReference
                                                                    of ('T *
                                                                    'M
                                                                    StringLiteral.t)
                                                                    
                                                                    |
                                                                    Identifier
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Type.Generic.Identifier.t
                                                                    
                                                                  and (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    module_reference:
                                                                    ('M, 
                                                                    'T)
                                                                    module_reference
                                                                    ;
                                                                    import_kind:
                                                                    ImportDeclaration.import_kind
                                                                    ;
                                                                    is_export:
                                                                    bool ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module
                                                                Expression :
                                                                sig
                                                                  type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    expression:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    directive:
                                                                    string
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                module Empty
                                                                :
                                                                sig
                                                                  type 
                                                                    'M t =
                                                                    {
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                  [@@deriving
                                                                    show]
                                                                end
                                                                type export_kind =
                                                                  |
                                                                  ExportType
                                                                  
                                                                  |
                                                                  ExportValue 
                                                                and (
                                                                  'M, 
                                                                  'T) t =
                                                                  ('M * (
                                                                    'M, 
                                                                    'T) t')
                                                                and (
                                                                  'M,
                                                                  'T) t' =
                                                                  | Block of
                                                                  ('M, 
                                                                  'T) Block.t
                                                                  
                                                                  | Break of
                                                                  'M Break.t
                                                                  
                                                                  |
                                                                  ClassDeclaration
                                                                  of (
                                                                  'M, 
                                                                  'T) Class.t
                                                                  
                                                                  |
                                                                  ComponentDeclaration
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  ComponentDeclaration.t
                                                                  
                                                                  | Continue
                                                                  of 'M
                                                                  Continue.t
                                                                  
                                                                  | Debugger
                                                                  of 'M
                                                                  Debugger.t
                                                                  
                                                                  |
                                                                  DeclareClass
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  DeclareClass.t
                                                                  
                                                                  |
                                                                  DeclareComponent
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  DeclareComponent.t
                                                                  
                                                                  |
                                                                  DeclareEnum
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  EnumDeclaration.t
                                                                  
                                                                  |
                                                                  DeclareExportDeclaration
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  DeclareExportDeclaration.t
                                                                  
                                                                  |
                                                                  DeclareFunction
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  DeclareFunction.t
                                                                  
                                                                  |
                                                                  DeclareInterface
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  Interface.t
                                                                  
                                                                  |
                                                                  DeclareModule
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  DeclareModule.t
                                                                  
                                                                  |
                                                                  DeclareModuleExports
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  DeclareModuleExports.t
                                                                  
                                                                  |
                                                                  DeclareNamespace
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  DeclareNamespace.t
                                                                  
                                                                  |
                                                                  DeclareTypeAlias
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  TypeAlias.t
                                                                  
                                                                  |
                                                                  DeclareOpaqueType
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  OpaqueType.t
                                                                  
                                                                  |
                                                                  DeclareVariable
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  DeclareVariable.t
                                                                  
                                                                  | DoWhile
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  DoWhile.t 
                                                                  | Empty of
                                                                  'M Empty.t
                                                                  
                                                                  |
                                                                  EnumDeclaration
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  EnumDeclaration.t
                                                                  
                                                                  |
                                                                  ExportDefaultDeclaration
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  ExportDefaultDeclaration.t
                                                                  
                                                                  |
                                                                  ExportNamedDeclaration
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  ExportNamedDeclaration.t
                                                                  
                                                                  |
                                                                  ExportAssignment
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  ExportAssignment.t
                                                                  
                                                                  |
                                                                  NamespaceExportDeclaration
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  NamespaceExportDeclaration.t
                                                                  
                                                                  |
                                                                  Expression
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  Expression.t
                                                                  
                                                                  | For of
                                                                  ('M, 
                                                                  'T) For.t 
                                                                  | ForIn of
                                                                  ('M, 
                                                                  'T) ForIn.t
                                                                  
                                                                  | ForOf of
                                                                  ('M, 
                                                                  'T) ForOf.t
                                                                  
                                                                  |
                                                                  FunctionDeclaration
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  Function.t
                                                                  
                                                                  | If of
                                                                  ('M, 
                                                                  'T) If.t 
                                                                  |
                                                                  ImportDeclaration
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  ImportDeclaration.t
                                                                  
                                                                  |
                                                                  ImportEqualsDeclaration
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  ImportEqualsDeclaration.t
                                                                  
                                                                  |
                                                                  InterfaceDeclaration
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  Interface.t
                                                                  
                                                                  | Labeled
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  Labeled.t 
                                                                  | Match of
                                                                  ('M, 
                                                                  'T)
                                                                  match_statement
                                                                  
                                                                  |
                                                                  RecordDeclaration
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  RecordDeclaration.t
                                                                  
                                                                  | Return of
                                                                  ('M, 
                                                                  'T)
                                                                  Return.t 
                                                                  | Switch of
                                                                  ('M, 
                                                                  'T)
                                                                  Switch.t 
                                                                  | Throw of
                                                                  ('M, 
                                                                  'T) Throw.t
                                                                  
                                                                  | Try of
                                                                  ('M, 
                                                                  'T) Try.t 
                                                                  | TypeAlias
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  TypeAlias.t
                                                                  
                                                                  |
                                                                  OpaqueType
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  OpaqueType.t
                                                                  
                                                                  |
                                                                  VariableDeclaration
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  VariableDeclaration.t
                                                                  
                                                                  | While of
                                                                  ('M, 
                                                                  'T) While.t
                                                                  
                                                                  | With of
                                                                  ('M, 
                                                                  'T) With.t 
                                                                [@@deriving
                                                                  show]
                                                              end =
                                                              struct
                                                                module Block =
                                                                  struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    body:
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.t
                                                                    list ;
                                                                    comments:
                                                                    ('M,
                                                                    'M
                                                                    Comment.t
                                                                    list)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module If =
                                                                  struct
                                                                    module Alternate =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    body:
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    test:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    consequent:
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.t
                                                                    ;
                                                                    alternate:
                                                                    ('M, 
                                                                    'T)
                                                                    Alternate.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module Labeled =
                                                                  struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    label:
                                                                    ('M, 
                                                                    'M)
                                                                    Identifier.t
                                                                    ;
                                                                    body:
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module Break =
                                                                  struct
                                                                    type 
                                                                    'M t =
                                                                    {
                                                                    label:
                                                                    ('M, 
                                                                    'M)
                                                                    Identifier.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module Continue =
                                                                  struct
                                                                    type 
                                                                    'M t =
                                                                    {
                                                                    label:
                                                                    ('M, 
                                                                    'M)
                                                                    Identifier.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module Debugger =
                                                                  struct
                                                                    type 
                                                                    'M t =
                                                                    {
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module With =
                                                                  struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    _object:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    body:
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module TypeAlias =
                                                                  struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    tparams:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.TypeParams.t
                                                                    option ;
                                                                    right:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module OpaqueType =
                                                                  struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    tparams:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.TypeParams.t
                                                                    option ;
                                                                    impl_type:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t
                                                                    option ;
                                                                    lower_bound:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t
                                                                    option ;
                                                                    upper_bound:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t
                                                                    option ;
                                                                    legacy_upper_bound:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.t
                                                                    option
                                                                    [@ocaml.doc
                                                                    " Invariant: only one of legacy_upper_bound and upper_bound can exist. "];
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                type (
                                                                  'M,
                                                                  'T) match_statement =
                                                                  ('M, 
                                                                    'T,
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.t)
                                                                    Match.t
                                                                [@@deriving
                                                                  show]
                                                                module Switch =
                                                                  struct
                                                                    module Case =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    test:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    option ;
                                                                    case_test_loc:
                                                                    'M option ;
                                                                    consequent:
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.t
                                                                    list ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    discriminant:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    cases:
                                                                    ('M, 
                                                                    'T)
                                                                    Case.t
                                                                    list ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option ;
                                                                    exhaustive_out:
                                                                    'T }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module Return =
                                                                  struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option ;
                                                                    return_out:
                                                                    'T }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module Throw =
                                                                  struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module Try =
                                                                  struct
                                                                    module CatchClause =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    param:
                                                                    ('M, 
                                                                    'T)
                                                                    Pattern.t
                                                                    option ;
                                                                    body:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Block.t) ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    block:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Block.t) ;
                                                                    handler:
                                                                    ('M, 
                                                                    'T)
                                                                    CatchClause.t
                                                                    option ;
                                                                    finalizer:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Block.t)
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module VariableDeclaration =
                                                                  struct
                                                                    module Declarator =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Pattern.t ;
                                                                    init:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    declarations:
                                                                    ('M, 
                                                                    'T)
                                                                    Declarator.t
                                                                    list ;
                                                                    kind:
                                                                    Variable.kind
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module While =
                                                                  struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    test:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    body:
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module DoWhile =
                                                                  struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    body:
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.t
                                                                    ;
                                                                    test:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module For =
                                                                  struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    init:
                                                                    ('M, 
                                                                    'T) init
                                                                    option ;
                                                                    test:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    option ;
                                                                    update:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    option ;
                                                                    body:
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    and (
                                                                    'M,
                                                                    'T) init =
                                                                    |
                                                                    InitDeclaration
                                                                    of ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    VariableDeclaration.t)
                                                                    
                                                                    |
                                                                    InitExpression
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Expression.t
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module ForIn =
                                                                  struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    left:
                                                                    ('M, 
                                                                    'T) left ;
                                                                    right:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    body:
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.t
                                                                    ;
                                                                    each:
                                                                    bool ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    and (
                                                                    'M,
                                                                    'T) left =
                                                                    |
                                                                    LeftDeclaration
                                                                    of ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    VariableDeclaration.t)
                                                                    
                                                                    |
                                                                    LeftPattern
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Pattern.t 
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module ForOf =
                                                                  struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    left:
                                                                    ('M, 
                                                                    'T) left ;
                                                                    right:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    body:
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.t
                                                                    ;
                                                                    await:
                                                                    bool ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    and (
                                                                    'M,
                                                                    'T) left =
                                                                    |
                                                                    LeftDeclaration
                                                                    of ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    VariableDeclaration.t)
                                                                    
                                                                    |
                                                                    LeftPattern
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Pattern.t 
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module EnumDeclaration =
                                                                  struct
                                                                    type 
                                                                    'M member_name =
                                                                    |
                                                                    Identifier
                                                                    of (
                                                                    'M, 
                                                                    'M)
                                                                    Identifier.t
                                                                    
                                                                    |
                                                                    StringLiteral
                                                                    of ('M *
                                                                    'M
                                                                    StringLiteral.t)
                                                                    [@@deriving
                                                                    show]
                                                                    module DefaultedMember =
                                                                    struct
                                                                    type 
                                                                    'M t =
                                                                    ('M * 'M
                                                                    t')
                                                                    and 
                                                                    'M t' =
                                                                    {
                                                                    id:
                                                                    'M
                                                                    member_name
                                                                    }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module InitializedMember =
                                                                    struct
                                                                    type (
                                                                    'I,
                                                                    'M) t =
                                                                    ('M *
                                                                    ('I, 
                                                                    'M) t')
                                                                    and (
                                                                    'I,
                                                                    'M) t' =
                                                                    {
                                                                    id:
                                                                    'M
                                                                    member_name
                                                                    ;
                                                                    init:
                                                                    ('M * 'I) }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    type explicit_type =
                                                                    | Boolean
                                                                    
                                                                    | Number
                                                                    
                                                                    | String
                                                                    
                                                                    | Symbol
                                                                    
                                                                    | BigInt 
                                                                    [@@deriving
                                                                    (ord,
                                                                    show)]
                                                                    let compare_explicit_type a b =
                                                                    Stdlib.compare a b
                                                                    type 
                                                                    'M member =
                                                                    |
                                                                    BooleanMember
                                                                    of
                                                                    ('M
                                                                    BooleanLiteral.t,
                                                                    'M)
                                                                    InitializedMember.t
                                                                    
                                                                    |
                                                                    NumberMember
                                                                    of
                                                                    ('M
                                                                    NumberLiteral.t,
                                                                    'M)
                                                                    InitializedMember.t
                                                                    
                                                                    |
                                                                    StringMember
                                                                    of
                                                                    ('M
                                                                    StringLiteral.t,
                                                                    'M)
                                                                    InitializedMember.t
                                                                    
                                                                    |
                                                                    BigIntMember
                                                                    of
                                                                    ('M
                                                                    BigIntLiteral.t,
                                                                    'M)
                                                                    InitializedMember.t
                                                                    
                                                                    |
                                                                    DefaultedMember
                                                                    of 'M
                                                                    DefaultedMember.t
                                                                    [@@deriving
                                                                    show]
                                                                    module Body =
                                                                    struct
                                                                    type 
                                                                    'M t =
                                                                    {
                                                                    members:
                                                                    'M member
                                                                    list ;
                                                                    explicit_type:
                                                                    ('M *
                                                                    explicit_type)
                                                                    option ;
                                                                    has_unknown_members:
                                                                    'M option ;
                                                                    comments:
                                                                    ('M,
                                                                    'M
                                                                    Comment.t
                                                                    list)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    body:
                                                                    'M body ;
                                                                    const_:
                                                                    bool ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    and 
                                                                    'M body =
                                                                    ('M * 'M
                                                                    Body.t)
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module ComponentDeclaration =
                                                                  struct
                                                                    module RestParam =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Pattern.t ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module Param =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    name:
                                                                    ('M, 
                                                                    'T)
                                                                    param_name
                                                                    ;
                                                                    local:
                                                                    ('M, 
                                                                    'T)
                                                                    Pattern.t ;
                                                                    default:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    option ;
                                                                    shorthand:
                                                                    bool }
                                                                    and (
                                                                    'M,
                                                                    'T) param_name =
                                                                    |
                                                                    Identifier
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    
                                                                    |
                                                                    StringLiteral
                                                                    of ('M *
                                                                    'M
                                                                    StringLiteral.t)
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module Params =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    params:
                                                                    ('M, 
                                                                    'T)
                                                                    Param.t
                                                                    list ;
                                                                    rest:
                                                                    ('M, 
                                                                    'T)
                                                                    RestParam.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    'M
                                                                    Comment.t
                                                                    list)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    tparams:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.TypeParams.t
                                                                    option ;
                                                                    params:
                                                                    ('M, 
                                                                    'T)
                                                                    Params.t ;
                                                                    renders:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.component_renders_annotation
                                                                    ;
                                                                    body:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.Block.t)
                                                                    option ;
                                                                    async:
                                                                    bool ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option ;
                                                                    sig_loc:
                                                                    'M }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module Interface =
                                                                  struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    tparams:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.TypeParams.t
                                                                    option ;
                                                                    extends:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Type.Generic.t)
                                                                    list ;
                                                                    body:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Type.Object.t)
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module RecordDeclaration =
                                                                  struct
                                                                    module InvalidPropertySyntax =
                                                                    struct
                                                                    type 
                                                                    'M t =
                                                                    {
                                                                    invalid_variance:
                                                                    'M
                                                                    Variance.t
                                                                    option ;
                                                                    invalid_optional:
                                                                    'M option ;
                                                                    invalid_suffix_semicolon:
                                                                    'M option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module Property =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('T *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    key:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.Object.Property.key
                                                                    ;
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.annotation
                                                                    ;
                                                                    default_value:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option ;
                                                                    invalid_syntax:
                                                                    'M
                                                                    InvalidPropertySyntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module StaticProperty =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('T *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    key:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.Object.Property.key
                                                                    ;
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.annotation
                                                                    ;
                                                                    value:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option ;
                                                                    invalid_syntax:
                                                                    'M
                                                                    InvalidPropertySyntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module Body =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    body:
                                                                    ('M, 
                                                                    'T)
                                                                    element
                                                                    list ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    and (
                                                                    'M,
                                                                    'T) element =
                                                                    | Method
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Class.Method.t
                                                                    
                                                                    |
                                                                    Property
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Property.t
                                                                    
                                                                    |
                                                                    StaticProperty
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    StaticProperty.t
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module InvalidSyntax =
                                                                    struct
                                                                    type 
                                                                    'M t =
                                                                    {
                                                                    invalid_infix_equals:
                                                                    'M option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    tparams:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.TypeParams.t
                                                                    option ;
                                                                    implements:
                                                                    ('M, 
                                                                    'T)
                                                                    Class.Implements.t
                                                                    option ;
                                                                    body:
                                                                    ('M, 
                                                                    'T)
                                                                    Body.t ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option ;
                                                                    invalid_syntax:
                                                                    'M
                                                                    InvalidSyntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module DeclareClass =
                                                                  struct
                                                                    type (
                                                                    'M,
                                                                    'T) extends =
                                                                    |
                                                                    ExtendsIdent
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Type.Generic.t
                                                                    
                                                                    |
                                                                    ExtendsCall
                                                                    of
                                                                    {
                                                                    callee:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Type.Generic.t)
                                                                    ;
                                                                    arg:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    extends) }
                                                                    [@@deriving
                                                                    show]
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    tparams:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.TypeParams.t
                                                                    option ;
                                                                    body:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Type.Object.t)
                                                                    ;
                                                                    extends:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    extends)
                                                                    option ;
                                                                    mixins:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Type.Generic.t)
                                                                    list ;
                                                                    implements:
                                                                    ('M, 
                                                                    'T)
                                                                    Class.Implements.t
                                                                    option ;
                                                                    abstract:
                                                                    bool ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module DeclareComponent =
                                                                  struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    tparams:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.TypeParams.t
                                                                    option ;
                                                                    params:
                                                                    ('M, 
                                                                    'T)
                                                                    ComponentDeclaration.Params.t
                                                                    ;
                                                                    renders:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.component_renders_annotation
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module DeclareVariable =
                                                                  struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    declarations:
                                                                    ('M, 
                                                                    'T)
                                                                    VariableDeclaration.Declarator.t
                                                                    list ;
                                                                    kind:
                                                                    Variable.kind
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module DeclareFunction =
                                                                  struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    option ;
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.annotation
                                                                    ;
                                                                    predicate:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.Predicate.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option ;
                                                                    implicit_declare:
                                                                    bool }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module DeclareModule =
                                                                  struct
                                                                    type (
                                                                    'M,
                                                                    'T) id =
                                                                    |
                                                                    Identifier
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    
                                                                    | Literal
                                                                    of ('T *
                                                                    'M
                                                                    StringLiteral.t)
                                                                    
                                                                    and (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T) id ;
                                                                    body:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Block.t) ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module DeclareModuleExports =
                                                                  struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.annotation
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module DeclareNamespace =
                                                                  struct
                                                                    type keyword =
                                                                    |
                                                                    Namespace
                                                                    
                                                                    | Module 
                                                                    [@@deriving
                                                                    show]
                                                                    type (
                                                                    'M,
                                                                    'T) id =
                                                                    | Global
                                                                    of (
                                                                    'M, 
                                                                    'M)
                                                                    Identifier.t
                                                                    
                                                                    | Local
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    [@@deriving
                                                                    show]
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T) id ;
                                                                    body:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Block.t) ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option ;
                                                                    implicit_declare:
                                                                    bool ;
                                                                    keyword:
                                                                    keyword }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module ExportAssignment =
                                                                  struct
                                                                    type (
                                                                    'M,
                                                                    'T) rhs =
                                                                    |
                                                                    Expression
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Expression.t
                                                                    
                                                                    |
                                                                    DeclareFunction
                                                                    of ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    DeclareFunction.t)
                                                                    [@@deriving
                                                                    show]
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    rhs:
                                                                    ('M, 
                                                                    'T) rhs ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module NamespaceExportDeclaration =
                                                                  struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module ExportNamedDeclaration =
                                                                  struct
                                                                    module ExportSpecifier =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    local:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    exported:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    option ;
                                                                    export_kind:
                                                                    Statement.export_kind
                                                                    ;
                                                                    from_remote:
                                                                    bool ;
                                                                    imported_name_def_loc:
                                                                    'M option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module ExportBatchSpecifier =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    option)
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    declaration:
                                                                    ('M, 
                                                                    'T)
                                                                    Statement.t
                                                                    option ;
                                                                    specifiers:
                                                                    ('M, 
                                                                    'T)
                                                                    specifier
                                                                    option ;
                                                                    source:
                                                                    ('T * 'M
                                                                    StringLiteral.t)
                                                                    option ;
                                                                    export_kind:
                                                                    Statement.export_kind
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    and (
                                                                    'M,
                                                                    'T) specifier =
                                                                    |
                                                                    ExportSpecifiers
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    ExportSpecifier.t
                                                                    list 
                                                                    |
                                                                    ExportBatchSpecifier
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    ExportBatchSpecifier.t
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module ExportDefaultDeclaration =
                                                                  struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    default:
                                                                    'T ;
                                                                    declaration:
                                                                    ('M, 
                                                                    'T)
                                                                    declaration
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    and (
                                                                    'M,
                                                                    'T) declaration =
                                                                    |
                                                                    Declaration
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Statement.t
                                                                    
                                                                    |
                                                                    Expression
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Expression.t
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module DeclareExportDeclaration =
                                                                  struct
                                                                    type (
                                                                    'M,
                                                                    'T) declaration =
                                                                    |
                                                                    Variable
                                                                    of ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    DeclareVariable.t)
                                                                    
                                                                    |
                                                                    Function
                                                                    of ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    DeclareFunction.t)
                                                                    
                                                                    | Class
                                                                    of ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    DeclareClass.t)
                                                                    
                                                                    |
                                                                    Component
                                                                    of ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    DeclareComponent.t)
                                                                    
                                                                    |
                                                                    DefaultType
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Type.t 
                                                                    |
                                                                    NamedType
                                                                    of ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    TypeAlias.t)
                                                                    
                                                                    |
                                                                    NamedOpaqueType
                                                                    of ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    OpaqueType.t)
                                                                    
                                                                    |
                                                                    Interface
                                                                    of ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Interface.t)
                                                                    
                                                                    | Enum of
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    EnumDeclaration.t)
                                                                    
                                                                    |
                                                                    Namespace
                                                                    of ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    DeclareNamespace.t)
                                                                    
                                                                    and (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    default:
                                                                    'M option ;
                                                                    declaration:
                                                                    ('M, 
                                                                    'T)
                                                                    declaration
                                                                    option ;
                                                                    specifiers:
                                                                    ('M, 
                                                                    'T)
                                                                    ExportNamedDeclaration.specifier
                                                                    option ;
                                                                    source:
                                                                    ('T * 'M
                                                                    StringLiteral.t)
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module ImportDeclaration =
                                                                  struct
                                                                    type import_kind =
                                                                    |
                                                                    ImportType
                                                                    
                                                                    |
                                                                    ImportTypeof
                                                                    
                                                                    |
                                                                    ImportValue
                                                                    
                                                                    and (
                                                                    'M,
                                                                    'T) specifier =
                                                                    |
                                                                    ImportNamedSpecifiers
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    named_specifier
                                                                    list 
                                                                    |
                                                                    ImportNamespaceSpecifier
                                                                    of ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t)
                                                                    
                                                                    and (
                                                                    'M,
                                                                    'T) named_specifier =
                                                                    {
                                                                    kind:
                                                                    import_kind
                                                                    option ;
                                                                    kind_loc:
                                                                    'M option ;
                                                                    local:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    option ;
                                                                    remote:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    remote_name_def_loc:
                                                                    'M option }
                                                                    and (
                                                                    'M,
                                                                    'T) default_identifier =
                                                                    {
                                                                    identifier:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    remote_default_name_def_loc:
                                                                    'M option }
                                                                    and (
                                                                    'M,
                                                                    'T) import_attribute =
                                                                    {
                                                                    loc: 'M ;
                                                                    key:
                                                                    ('M, 
                                                                    'T)
                                                                    import_attribute_key
                                                                    ;
                                                                    value:
                                                                    ('T * 'M
                                                                    StringLiteral.t)
                                                                    }
                                                                    and (
                                                                    'M,
                                                                    'T) import_attribute_key =
                                                                    |
                                                                    Identifier
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    
                                                                    |
                                                                    StringLiteral
                                                                    of 'M *
                                                                    'M
                                                                    StringLiteral.t
                                                                    
                                                                    and (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    import_kind:
                                                                    import_kind
                                                                    ;
                                                                    source:
                                                                    ('T * 'M
                                                                    StringLiteral.t)
                                                                    ;
                                                                    default:
                                                                    ('M, 
                                                                    'T)
                                                                    default_identifier
                                                                    option ;
                                                                    specifiers:
                                                                    ('M, 
                                                                    'T)
                                                                    specifier
                                                                    option ;
                                                                    attributes:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    import_attribute
                                                                    list)
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module ImportEqualsDeclaration =
                                                                  struct
                                                                    type (
                                                                    'M,
                                                                    'T) module_reference =
                                                                    |
                                                                    ExternalModuleReference
                                                                    of ('T *
                                                                    'M
                                                                    StringLiteral.t)
                                                                    
                                                                    |
                                                                    Identifier
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Type.Generic.Identifier.t
                                                                    
                                                                    and (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    id:
                                                                    ('M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    ;
                                                                    module_reference:
                                                                    ('M, 
                                                                    'T)
                                                                    module_reference
                                                                    ;
                                                                    import_kind:
                                                                    ImportDeclaration.import_kind
                                                                    ;
                                                                    is_export:
                                                                    bool ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module Expression =
                                                                  struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    expression:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    directive:
                                                                    string
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                module Empty =
                                                                  struct
                                                                    type 
                                                                    'M t =
                                                                    {
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                  end
                                                                type export_kind =
                                                                  |
                                                                  ExportType
                                                                  
                                                                  |
                                                                  ExportValue 
                                                                and (
                                                                  'M, 
                                                                  'T) t =
                                                                  ('M * (
                                                                    'M, 
                                                                    'T) t')
                                                                and (
                                                                  'M,
                                                                  'T) t' =
                                                                  | Block of
                                                                  ('M, 
                                                                  'T) Block.t
                                                                  
                                                                  | Break of
                                                                  'M Break.t
                                                                  
                                                                  |
                                                                  ClassDeclaration
                                                                  of (
                                                                  'M, 
                                                                  'T) Class.t
                                                                  
                                                                  |
                                                                  ComponentDeclaration
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  ComponentDeclaration.t
                                                                  
                                                                  | Continue
                                                                  of 'M
                                                                  Continue.t
                                                                  
                                                                  | Debugger
                                                                  of 'M
                                                                  Debugger.t
                                                                  
                                                                  |
                                                                  DeclareClass
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  DeclareClass.t
                                                                  
                                                                  |
                                                                  DeclareComponent
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  DeclareComponent.t
                                                                  
                                                                  |
                                                                  DeclareEnum
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  EnumDeclaration.t
                                                                  
                                                                  |
                                                                  DeclareExportDeclaration
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  DeclareExportDeclaration.t
                                                                  
                                                                  |
                                                                  DeclareFunction
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  DeclareFunction.t
                                                                  
                                                                  |
                                                                  DeclareInterface
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  Interface.t
                                                                  
                                                                  |
                                                                  DeclareModule
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  DeclareModule.t
                                                                  
                                                                  |
                                                                  DeclareModuleExports
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  DeclareModuleExports.t
                                                                  
                                                                  |
                                                                  DeclareNamespace
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  DeclareNamespace.t
                                                                  
                                                                  |
                                                                  DeclareTypeAlias
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  TypeAlias.t
                                                                  
                                                                  |
                                                                  DeclareOpaqueType
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  OpaqueType.t
                                                                  
                                                                  |
                                                                  DeclareVariable
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  DeclareVariable.t
                                                                  
                                                                  | DoWhile
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  DoWhile.t 
                                                                  | Empty of
                                                                  'M Empty.t
                                                                  
                                                                  |
                                                                  EnumDeclaration
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  EnumDeclaration.t
                                                                  
                                                                  |
                                                                  ExportDefaultDeclaration
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  ExportDefaultDeclaration.t
                                                                  
                                                                  |
                                                                  ExportNamedDeclaration
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  ExportNamedDeclaration.t
                                                                  
                                                                  |
                                                                  ExportAssignment
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  ExportAssignment.t
                                                                  
                                                                  |
                                                                  NamespaceExportDeclaration
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  NamespaceExportDeclaration.t
                                                                  
                                                                  |
                                                                  Expression
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  Expression.t
                                                                  
                                                                  | For of
                                                                  ('M, 
                                                                  'T) For.t 
                                                                  | ForIn of
                                                                  ('M, 
                                                                  'T) ForIn.t
                                                                  
                                                                  | ForOf of
                                                                  ('M, 
                                                                  'T) ForOf.t
                                                                  
                                                                  |
                                                                  FunctionDeclaration
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  Function.t
                                                                  
                                                                  | If of
                                                                  ('M, 
                                                                  'T) If.t 
                                                                  |
                                                                  ImportDeclaration
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  ImportDeclaration.t
                                                                  
                                                                  |
                                                                  ImportEqualsDeclaration
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  ImportEqualsDeclaration.t
                                                                  
                                                                  |
                                                                  InterfaceDeclaration
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  Interface.t
                                                                  
                                                                  | Labeled
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  Labeled.t 
                                                                  | Match of
                                                                  ('M, 
                                                                  'T)
                                                                  match_statement
                                                                  
                                                                  |
                                                                  RecordDeclaration
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  RecordDeclaration.t
                                                                  
                                                                  | Return of
                                                                  ('M, 
                                                                  'T)
                                                                  Return.t 
                                                                  | Switch of
                                                                  ('M, 
                                                                  'T)
                                                                  Switch.t 
                                                                  | Throw of
                                                                  ('M, 
                                                                  'T) Throw.t
                                                                  
                                                                  | Try of
                                                                  ('M, 
                                                                  'T) Try.t 
                                                                  | TypeAlias
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  TypeAlias.t
                                                                  
                                                                  |
                                                                  OpaqueType
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  OpaqueType.t
                                                                  
                                                                  |
                                                                  VariableDeclaration
                                                                  of (
                                                                  'M, 
                                                                  'T)
                                                                  VariableDeclaration.t
                                                                  
                                                                  | While of
                                                                  ('M, 
                                                                  'T) While.t
                                                                  
                                                                  | With of
                                                                  ('M, 
                                                                  'T) With.t 
                                                                [@@deriving
                                                                  show]
                                                              end and
                                                                   Expression:
                                                                   sig
                                                                    module
                                                                    CallTypeArg
                                                                    :
                                                                    sig
                                                                    module
                                                                    Implicit
                                                                    :
                                                                    sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('T * 'M
                                                                    t')
                                                                    and 
                                                                    'M t' =
                                                                    {
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    |
                                                                    Explicit
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Type.t 
                                                                    |
                                                                    Implicit
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Implicit.t
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    CallTypeArgs
                                                                    :
                                                                    sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    arguments:
                                                                    ('M, 
                                                                    'T)
                                                                    CallTypeArg.t
                                                                    list ;
                                                                    comments:
                                                                    ('M,
                                                                    'M
                                                                    Comment.t
                                                                    list)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    SpreadElement
                                                                    :
                                                                    sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    Array :
                                                                    sig
                                                                    type (
                                                                    'M,
                                                                    'T) element =
                                                                    |
                                                                    Expression
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Expression.t
                                                                    
                                                                    | Spread
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    SpreadElement.t
                                                                    
                                                                    | Hole of
                                                                    'M 
                                                                    [@@deriving
                                                                    show]
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    elements:
                                                                    ('M, 
                                                                    'T)
                                                                    element
                                                                    list ;
                                                                    trailing_comma:
                                                                    bool ;
                                                                    comments:
                                                                    ('M,
                                                                    'M
                                                                    Comment.t
                                                                    list)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    TemplateLiteral
                                                                    :
                                                                    sig
                                                                    module
                                                                    Element :
                                                                    sig
                                                                    type value =
                                                                    {
                                                                    raw:
                                                                    string ;
                                                                    cooked:
                                                                    string }
                                                                    and 
                                                                    'M t =
                                                                    ('M * t')
                                                                    and t' =
                                                                    {
                                                                    value:
                                                                    value ;
                                                                    tail:
                                                                    bool }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    quasis:
                                                                    'M
                                                                    Element.t
                                                                    list ;
                                                                    expressions:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    list ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    TaggedTemplate
                                                                    :
                                                                    sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    tag:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    targs:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.CallTypeArgs.t
                                                                    option ;
                                                                    quasi:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    TemplateLiteral.t)
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    Object :
                                                                    sig
                                                                    module
                                                                    Property
                                                                    :
                                                                    sig
                                                                    type (
                                                                    'M,
                                                                    'T) key =
                                                                    |
                                                                    StringLiteral
                                                                    of ('T *
                                                                    'M
                                                                    StringLiteral.t)
                                                                    
                                                                    |
                                                                    NumberLiteral
                                                                    of ('T *
                                                                    'M
                                                                    NumberLiteral.t)
                                                                    
                                                                    |
                                                                    BigIntLiteral
                                                                    of ('T *
                                                                    'M
                                                                    BigIntLiteral.t)
                                                                    
                                                                    |
                                                                    Identifier
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    
                                                                    |
                                                                    PrivateName
                                                                    of 'M
                                                                    PrivateName.t
                                                                    
                                                                    |
                                                                    Computed
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    ComputedKey.t
                                                                    
                                                                    and (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    | Init of
                                                                    {
                                                                    key:
                                                                    ('M, 
                                                                    'T) key ;
                                                                    value:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    shorthand:
                                                                    bool } 
                                                                    | Method
                                                                    of
                                                                    {
                                                                    key:
                                                                    ('M, 
                                                                    'T) key ;
                                                                    value:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Function.t)
                                                                    } 
                                                                    | Get of
                                                                    {
                                                                    key:
                                                                    ('M, 
                                                                    'T) key ;
                                                                    value:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Function.t)
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    
                                                                    | Set of
                                                                    {
                                                                    key:
                                                                    ('M, 
                                                                    'T) key ;
                                                                    value:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Function.t)
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option } 
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    SpreadProperty
                                                                    :
                                                                    sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    type (
                                                                    'M,
                                                                    'T) property =
                                                                    |
                                                                    Property
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Property.t
                                                                    
                                                                    |
                                                                    SpreadProperty
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    SpreadProperty.t
                                                                    
                                                                    and (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    properties:
                                                                    ('M, 
                                                                    'T)
                                                                    property
                                                                    list ;
                                                                    comments:
                                                                    ('M,
                                                                    'M
                                                                    Comment.t
                                                                    list)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    Record :
                                                                    sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    constructor:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    targs:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.CallTypeArgs.t
                                                                    option ;
                                                                    properties:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Object.t) ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    Sequence
                                                                    :
                                                                    sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    expressions:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    list ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    Unary :
                                                                    sig
                                                                    type operator =
                                                                    | Minus 
                                                                    | Plus 
                                                                    | Not 
                                                                    | BitNot
                                                                    
                                                                    | Typeof
                                                                    
                                                                    | Void 
                                                                    | Delete
                                                                    
                                                                    | Await 
                                                                    | Nonnull 
                                                                    and (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    operator:
                                                                    operator ;
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    Binary :
                                                                    sig
                                                                    type operator =
                                                                    | Equal 
                                                                    |
                                                                    NotEqual
                                                                    
                                                                    |
                                                                    StrictEqual
                                                                    
                                                                    |
                                                                    StrictNotEqual
                                                                    
                                                                    |
                                                                    LessThan
                                                                    
                                                                    |
                                                                    LessThanEqual
                                                                    
                                                                    |
                                                                    GreaterThan
                                                                    
                                                                    |
                                                                    GreaterThanEqual
                                                                    
                                                                    | LShift
                                                                    
                                                                    | RShift
                                                                    
                                                                    | RShift3
                                                                    
                                                                    | Plus 
                                                                    | Minus 
                                                                    | Mult 
                                                                    | Exp 
                                                                    | Div 
                                                                    | Mod 
                                                                    | BitOr 
                                                                    | Xor 
                                                                    | BitAnd
                                                                    
                                                                    | In 
                                                                    |
                                                                    Instanceof
                                                                    
                                                                    and (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    operator:
                                                                    operator ;
                                                                    left:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    right:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    Assignment
                                                                    :
                                                                    sig
                                                                    type operator =
                                                                    |
                                                                    PlusAssign
                                                                    
                                                                    |
                                                                    MinusAssign
                                                                    
                                                                    |
                                                                    MultAssign
                                                                    
                                                                    |
                                                                    ExpAssign
                                                                    
                                                                    |
                                                                    DivAssign
                                                                    
                                                                    |
                                                                    ModAssign
                                                                    
                                                                    |
                                                                    LShiftAssign
                                                                    
                                                                    |
                                                                    RShiftAssign
                                                                    
                                                                    |
                                                                    RShift3Assign
                                                                    
                                                                    |
                                                                    BitOrAssign
                                                                    
                                                                    |
                                                                    BitXorAssign
                                                                    
                                                                    |
                                                                    BitAndAssign
                                                                    
                                                                    |
                                                                    NullishAssign
                                                                    
                                                                    |
                                                                    AndAssign
                                                                    
                                                                    |
                                                                    OrAssign 
                                                                    and (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    operator:
                                                                    operator
                                                                    option ;
                                                                    left:
                                                                    ('M, 
                                                                    'T)
                                                                    Pattern.t ;
                                                                    right:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    Update :
                                                                    sig
                                                                    type operator =
                                                                    |
                                                                    Increment
                                                                    
                                                                    |
                                                                    Decrement 
                                                                    and (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    operator:
                                                                    operator ;
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    prefix:
                                                                    bool ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    Logical :
                                                                    sig
                                                                    type operator =
                                                                    | Or 
                                                                    | And 
                                                                    |
                                                                    NullishCoalesce
                                                                    
                                                                    and (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    operator:
                                                                    operator ;
                                                                    left:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    right:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    Conditional
                                                                    :
                                                                    sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    test:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    consequent:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    alternate:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    type (
                                                                    'M,
                                                                    'T) expression_or_spread =
                                                                    |
                                                                    Expression
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Expression.t
                                                                    
                                                                    | Spread
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    SpreadElement.t
                                                                    [@@deriving
                                                                    show]
                                                                    module
                                                                    ArgList :
                                                                    sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    arguments:
                                                                    ('M, 
                                                                    'T)
                                                                    expression_or_spread
                                                                    list ;
                                                                    comments:
                                                                    ('M,
                                                                    'M
                                                                    Comment.t
                                                                    list)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    New :
                                                                    sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    callee:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    targs:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.CallTypeArgs.t
                                                                    option ;
                                                                    arguments:
                                                                    ('M, 
                                                                    'T)
                                                                    ArgList.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    Call :
                                                                    sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    callee:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    targs:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.CallTypeArgs.t
                                                                    option ;
                                                                    arguments:
                                                                    ('M, 
                                                                    'T)
                                                                    ArgList.t ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    OptionalCall
                                                                    :
                                                                    sig
                                                                    type kind =
                                                                    |
                                                                    Optional
                                                                    
                                                                    |
                                                                    NonOptional
                                                                    
                                                                    |
                                                                    AssertNonnull
                                                                    [@@deriving
                                                                    show]
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    call:
                                                                    ('M, 
                                                                    'T)
                                                                    Call.t ;
                                                                    filtered_out:
                                                                    'T ;
                                                                    optional:
                                                                    kind }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    Member :
                                                                    sig
                                                                    type (
                                                                    'M,
                                                                    'T) property =
                                                                    |
                                                                    PropertyIdentifier
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    
                                                                    |
                                                                    PropertyPrivateName
                                                                    of 'M
                                                                    PrivateName.t
                                                                    
                                                                    |
                                                                    PropertyExpression
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Expression.t
                                                                    
                                                                    and (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    _object:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    property:
                                                                    ('M, 
                                                                    'T)
                                                                    property ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    OptionalMember
                                                                    :
                                                                    sig
                                                                    type kind =
                                                                    |
                                                                    Optional
                                                                    
                                                                    |
                                                                    NonOptional
                                                                    
                                                                    |
                                                                    AssertNonnull
                                                                    [@@deriving
                                                                    show]
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    member:
                                                                    ('M, 
                                                                    'T)
                                                                    Member.t ;
                                                                    filtered_out:
                                                                    'T ;
                                                                    optional:
                                                                    kind }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    Yield :
                                                                    sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option ;
                                                                    delegate:
                                                                    bool ;
                                                                    result_out:
                                                                    'T }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    TypeCast
                                                                    :
                                                                    sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    expression:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.annotation
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    AsExpression
                                                                    :
                                                                    sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    expression:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.annotation
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    AsConstExpression
                                                                    :
                                                                    sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    expression:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    TSSatisfies
                                                                    :
                                                                    sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    expression:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.annotation
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    MetaProperty
                                                                    :
                                                                    sig
                                                                    type 
                                                                    'M t =
                                                                    {
                                                                    meta:
                                                                    ('M, 
                                                                    'M)
                                                                    Identifier.t
                                                                    ;
                                                                    property:
                                                                    ('M, 
                                                                    'M)
                                                                    Identifier.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    This :
                                                                    sig
                                                                    type 
                                                                    'M t =
                                                                    {
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    Super :
                                                                    sig
                                                                    type 
                                                                    'M t =
                                                                    {
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module
                                                                    Import :
                                                                    sig
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    options:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    type (
                                                                    'M,
                                                                    'T) match_expression =
                                                                    ('M, 
                                                                    'T,
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t)
                                                                    Match.t
                                                                    [@@deriving
                                                                    show]
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('T *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    | Array
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Array.t 
                                                                    |
                                                                    ArrowFunction
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Function.t
                                                                    
                                                                    |
                                                                    AsConstExpression
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    AsConstExpression.t
                                                                    
                                                                    |
                                                                    AsExpression
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    AsExpression.t
                                                                    
                                                                    |
                                                                    Assignment
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Assignment.t
                                                                    
                                                                    | Binary
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Binary.t
                                                                    
                                                                    | Call of
                                                                    ('M, 
                                                                    'T)
                                                                    Call.t 
                                                                    | Class
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Class.t 
                                                                    |
                                                                    Conditional
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Conditional.t
                                                                    
                                                                    |
                                                                    Function
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Function.t
                                                                    
                                                                    |
                                                                    Identifier
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    
                                                                    | Import
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Import.t
                                                                    
                                                                    |
                                                                    JSXElement
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    JSX.element
                                                                    
                                                                    |
                                                                    JSXFragment
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    JSX.fragment
                                                                    
                                                                    |
                                                                    StringLiteral
                                                                    of 'M
                                                                    StringLiteral.t
                                                                    
                                                                    |
                                                                    BooleanLiteral
                                                                    of 'M
                                                                    BooleanLiteral.t
                                                                    
                                                                    |
                                                                    NullLiteral
                                                                    of (
                                                                    'M, 
                                                                    unit)
                                                                    Syntax.t
                                                                    option 
                                                                    |
                                                                    NumberLiteral
                                                                    of 'M
                                                                    NumberLiteral.t
                                                                    
                                                                    |
                                                                    BigIntLiteral
                                                                    of 'M
                                                                    BigIntLiteral.t
                                                                    
                                                                    |
                                                                    RegExpLiteral
                                                                    of 'M
                                                                    RegExpLiteral.t
                                                                    
                                                                    |
                                                                    ModuleRefLiteral
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    ModuleRefLiteral.t
                                                                    
                                                                    | Logical
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Logical.t
                                                                    
                                                                    | Match
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    match_expression
                                                                    
                                                                    | Member
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Member.t
                                                                    
                                                                    |
                                                                    MetaProperty
                                                                    of 'M
                                                                    MetaProperty.t
                                                                    
                                                                    | New of
                                                                    ('M, 
                                                                    'T) New.t
                                                                    
                                                                    | Object
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Object.t
                                                                    
                                                                    |
                                                                    OptionalCall
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    OptionalCall.t
                                                                    
                                                                    |
                                                                    OptionalMember
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    OptionalMember.t
                                                                    
                                                                    | Record
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Record.t
                                                                    
                                                                    |
                                                                    Sequence
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Sequence.t
                                                                    
                                                                    | Super
                                                                    of 'M
                                                                    Super.t 
                                                                    |
                                                                    TaggedTemplate
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    TaggedTemplate.t
                                                                    
                                                                    |
                                                                    TemplateLiteral
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    TemplateLiteral.t
                                                                    
                                                                    | This of
                                                                    'M This.t
                                                                    
                                                                    |
                                                                    TypeCast
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    TypeCast.t
                                                                    
                                                                    |
                                                                    TSSatisfies
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    TSSatisfies.t
                                                                    
                                                                    | Unary
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Unary.t 
                                                                    | Update
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Update.t
                                                                    
                                                                    | Yield
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Yield.t 
                                                                    [@@deriving
                                                                    show]
                                                                   end =
                                                                   struct
                                                                    module CallTypeArg =
                                                                    struct
                                                                    module Implicit =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('T * 'M
                                                                    t')
                                                                    and 
                                                                    'M t' =
                                                                    {
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    |
                                                                    Explicit
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Type.t 
                                                                    |
                                                                    Implicit
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Implicit.t
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module CallTypeArgs =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    arguments:
                                                                    ('M, 
                                                                    'T)
                                                                    CallTypeArg.t
                                                                    list ;
                                                                    comments:
                                                                    ('M,
                                                                    'M
                                                                    Comment.t
                                                                    list)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module SpreadElement =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module Array =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) element =
                                                                    |
                                                                    Expression
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Expression.t
                                                                    
                                                                    | Spread
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    SpreadElement.t
                                                                    
                                                                    | Hole of
                                                                    'M 
                                                                    [@@deriving
                                                                    show]
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    elements:
                                                                    ('M, 
                                                                    'T)
                                                                    element
                                                                    list ;
                                                                    trailing_comma:
                                                                    bool ;
                                                                    comments:
                                                                    ('M,
                                                                    'M
                                                                    Comment.t
                                                                    list)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module TemplateLiteral =
                                                                    struct
                                                                    module Element =
                                                                    struct
                                                                    type value =
                                                                    {
                                                                    raw:
                                                                    string ;
                                                                    cooked:
                                                                    string }
                                                                    and 
                                                                    'M t =
                                                                    ('M * t')
                                                                    and t' =
                                                                    {
                                                                    value:
                                                                    value ;
                                                                    tail:
                                                                    bool }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    quasis:
                                                                    'M
                                                                    Element.t
                                                                    list ;
                                                                    expressions:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    list ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module TaggedTemplate =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    tag:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    targs:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.CallTypeArgs.t
                                                                    option ;
                                                                    quasi:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    TemplateLiteral.t)
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module Object =
                                                                    struct
                                                                    module Property =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) key =
                                                                    |
                                                                    StringLiteral
                                                                    of ('T *
                                                                    'M
                                                                    StringLiteral.t)
                                                                    
                                                                    |
                                                                    NumberLiteral
                                                                    of ('T *
                                                                    'M
                                                                    NumberLiteral.t)
                                                                    
                                                                    |
                                                                    BigIntLiteral
                                                                    of ('T *
                                                                    'M
                                                                    BigIntLiteral.t)
                                                                    
                                                                    |
                                                                    Identifier
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    
                                                                    |
                                                                    PrivateName
                                                                    of 'M
                                                                    PrivateName.t
                                                                    
                                                                    |
                                                                    Computed
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    ComputedKey.t
                                                                    
                                                                    and (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    | Init of
                                                                    {
                                                                    key:
                                                                    ('M, 
                                                                    'T) key ;
                                                                    value:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    shorthand:
                                                                    bool } 
                                                                    | Method
                                                                    of
                                                                    {
                                                                    key:
                                                                    ('M, 
                                                                    'T) key ;
                                                                    value:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Function.t)
                                                                    } 
                                                                    | Get of
                                                                    {
                                                                    key:
                                                                    ('M, 
                                                                    'T) key ;
                                                                    value:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Function.t)
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    
                                                                    | Set of
                                                                    {
                                                                    key:
                                                                    ('M, 
                                                                    'T) key ;
                                                                    value:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Function.t)
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option } 
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module SpreadProperty =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    type (
                                                                    'M,
                                                                    'T) property =
                                                                    |
                                                                    Property
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Property.t
                                                                    
                                                                    |
                                                                    SpreadProperty
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    SpreadProperty.t
                                                                    
                                                                    and (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    properties:
                                                                    ('M, 
                                                                    'T)
                                                                    property
                                                                    list ;
                                                                    comments:
                                                                    ('M,
                                                                    'M
                                                                    Comment.t
                                                                    list)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module Record =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    constructor:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    targs:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.CallTypeArgs.t
                                                                    option ;
                                                                    properties:
                                                                    ('M *
                                                                    ('M, 
                                                                    'T)
                                                                    Object.t) ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module Sequence =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    expressions:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    list ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module Unary =
                                                                    struct
                                                                    type operator =
                                                                    | Minus 
                                                                    | Plus 
                                                                    | Not 
                                                                    | BitNot
                                                                    
                                                                    | Typeof
                                                                    
                                                                    | Void 
                                                                    | Delete
                                                                    
                                                                    | Await 
                                                                    | Nonnull 
                                                                    and (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    operator:
                                                                    operator ;
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module Binary =
                                                                    struct
                                                                    type operator =
                                                                    | Equal 
                                                                    |
                                                                    NotEqual
                                                                    
                                                                    |
                                                                    StrictEqual
                                                                    
                                                                    |
                                                                    StrictNotEqual
                                                                    
                                                                    |
                                                                    LessThan
                                                                    
                                                                    |
                                                                    LessThanEqual
                                                                    
                                                                    |
                                                                    GreaterThan
                                                                    
                                                                    |
                                                                    GreaterThanEqual
                                                                    
                                                                    | LShift
                                                                    
                                                                    | RShift
                                                                    
                                                                    | RShift3
                                                                    
                                                                    | Plus 
                                                                    | Minus 
                                                                    | Mult 
                                                                    | Exp 
                                                                    | Div 
                                                                    | Mod 
                                                                    | BitOr 
                                                                    | Xor 
                                                                    | BitAnd
                                                                    
                                                                    | In 
                                                                    |
                                                                    Instanceof
                                                                    
                                                                    and (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    operator:
                                                                    operator ;
                                                                    left:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    right:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module Assignment =
                                                                    struct
                                                                    type operator =
                                                                    |
                                                                    PlusAssign
                                                                    
                                                                    |
                                                                    MinusAssign
                                                                    
                                                                    |
                                                                    MultAssign
                                                                    
                                                                    |
                                                                    ExpAssign
                                                                    
                                                                    |
                                                                    DivAssign
                                                                    
                                                                    |
                                                                    ModAssign
                                                                    
                                                                    |
                                                                    LShiftAssign
                                                                    
                                                                    |
                                                                    RShiftAssign
                                                                    
                                                                    |
                                                                    RShift3Assign
                                                                    
                                                                    |
                                                                    BitOrAssign
                                                                    
                                                                    |
                                                                    BitXorAssign
                                                                    
                                                                    |
                                                                    BitAndAssign
                                                                    
                                                                    |
                                                                    NullishAssign
                                                                    
                                                                    |
                                                                    AndAssign
                                                                    
                                                                    |
                                                                    OrAssign 
                                                                    and (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    operator:
                                                                    operator
                                                                    option ;
                                                                    left:
                                                                    ('M, 
                                                                    'T)
                                                                    Pattern.t ;
                                                                    right:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module Update =
                                                                    struct
                                                                    type operator =
                                                                    |
                                                                    Increment
                                                                    
                                                                    |
                                                                    Decrement 
                                                                    and (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    operator:
                                                                    operator ;
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    prefix:
                                                                    bool ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module Logical =
                                                                    struct
                                                                    type operator =
                                                                    | Or 
                                                                    | And 
                                                                    |
                                                                    NullishCoalesce
                                                                    
                                                                    and (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    operator:
                                                                    operator ;
                                                                    left:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    right:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module Conditional =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    test:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    consequent:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    alternate:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    type (
                                                                    'M,
                                                                    'T) expression_or_spread =
                                                                    |
                                                                    Expression
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Expression.t
                                                                    
                                                                    | Spread
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    SpreadElement.t
                                                                    [@@deriving
                                                                    show]
                                                                    module ArgList =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('M *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    {
                                                                    arguments:
                                                                    ('M, 
                                                                    'T)
                                                                    expression_or_spread
                                                                    list ;
                                                                    comments:
                                                                    ('M,
                                                                    'M
                                                                    Comment.t
                                                                    list)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module New =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    callee:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    targs:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.CallTypeArgs.t
                                                                    option ;
                                                                    arguments:
                                                                    ('M, 
                                                                    'T)
                                                                    ArgList.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module Call =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    callee:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    targs:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.CallTypeArgs.t
                                                                    option ;
                                                                    arguments:
                                                                    ('M, 
                                                                    'T)
                                                                    ArgList.t ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module OptionalCall =
                                                                    struct
                                                                    type kind =
                                                                    |
                                                                    Optional
                                                                    
                                                                    |
                                                                    NonOptional
                                                                    
                                                                    |
                                                                    AssertNonnull
                                                                    [@@deriving
                                                                    show]
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    call:
                                                                    ('M, 
                                                                    'T)
                                                                    Call.t ;
                                                                    filtered_out:
                                                                    'T ;
                                                                    optional:
                                                                    kind }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module Member =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) property =
                                                                    |
                                                                    PropertyIdentifier
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    
                                                                    |
                                                                    PropertyPrivateName
                                                                    of 'M
                                                                    PrivateName.t
                                                                    
                                                                    |
                                                                    PropertyExpression
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Expression.t
                                                                    
                                                                    and (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    _object:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    property:
                                                                    ('M, 
                                                                    'T)
                                                                    property ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module OptionalMember =
                                                                    struct
                                                                    type kind =
                                                                    |
                                                                    Optional
                                                                    
                                                                    |
                                                                    NonOptional
                                                                    
                                                                    |
                                                                    AssertNonnull
                                                                    [@@deriving
                                                                    show]
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    member:
                                                                    ('M, 
                                                                    'T)
                                                                    Member.t ;
                                                                    filtered_out:
                                                                    'T ;
                                                                    optional:
                                                                    kind }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module Yield =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option ;
                                                                    delegate:
                                                                    bool ;
                                                                    result_out:
                                                                    'T }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module TypeCast =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    expression:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.annotation
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module AsExpression =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    expression:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.annotation
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module AsConstExpression =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    expression:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module TSSatisfies =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    expression:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    annot:
                                                                    ('M, 
                                                                    'T)
                                                                    Type.annotation
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module MetaProperty =
                                                                    struct
                                                                    type 
                                                                    'M t =
                                                                    {
                                                                    meta:
                                                                    ('M, 
                                                                    'M)
                                                                    Identifier.t
                                                                    ;
                                                                    property:
                                                                    ('M, 
                                                                    'M)
                                                                    Identifier.t
                                                                    ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module This =
                                                                    struct
                                                                    type 
                                                                    'M t =
                                                                    {
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module Super =
                                                                    struct
                                                                    type 
                                                                    'M t =
                                                                    {
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    module Import =
                                                                    struct
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    {
                                                                    argument:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    ;
                                                                    options:
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t
                                                                    option ;
                                                                    comments:
                                                                    ('M,
                                                                    unit)
                                                                    Syntax.t
                                                                    option }
                                                                    [@@deriving
                                                                    show]
                                                                    end
                                                                    type (
                                                                    'M,
                                                                    'T) match_expression =
                                                                    ('M, 
                                                                    'T,
                                                                    ('M, 
                                                                    'T)
                                                                    Expression.t)
                                                                    Match.t
                                                                    [@@deriving
                                                                    show]
                                                                    type (
                                                                    'M,
                                                                    'T) t =
                                                                    ('T *
                                                                    ('M, 
                                                                    'T) t')
                                                                    and (
                                                                    'M,
                                                                    'T) t' =
                                                                    | Array
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Array.t 
                                                                    |
                                                                    ArrowFunction
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Function.t
                                                                    
                                                                    |
                                                                    AsConstExpression
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    AsConstExpression.t
                                                                    
                                                                    |
                                                                    AsExpression
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    AsExpression.t
                                                                    
                                                                    |
                                                                    Assignment
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Assignment.t
                                                                    
                                                                    | Binary
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Binary.t
                                                                    
                                                                    | Call of
                                                                    ('M, 
                                                                    'T)
                                                                    Call.t 
                                                                    | Class
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Class.t 
                                                                    |
                                                                    Conditional
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Conditional.t
                                                                    
                                                                    |
                                                                    Function
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Function.t
                                                                    
                                                                    |
                                                                    Identifier
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Identifier.t
                                                                    
                                                                    | Import
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Import.t
                                                                    
                                                                    |
                                                                    JSXElement
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    JSX.element
                                                                    
                                                                    |
                                                                    JSXFragment
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    JSX.fragment
                                                                    
                                                                    |
                                                                    StringLiteral
                                                                    of 'M
                                                                    StringLiteral.t
                                                                    
                                                                    |
                                                                    BooleanLiteral
                                                                    of 'M
                                                                    BooleanLiteral.t
                                                                    
                                                                    |
                                                                    NullLiteral
                                                                    of (
                                                                    'M, 
                                                                    unit)
                                                                    Syntax.t
                                                                    option 
                                                                    |
                                                                    NumberLiteral
                                                                    of 'M
                                                                    NumberLiteral.t
                                                                    
                                                                    |
                                                                    BigIntLiteral
                                                                    of 'M
                                                                    BigIntLiteral.t
                                                                    
                                                                    |
                                                                    RegExpLiteral
                                                                    of 'M
                                                                    RegExpLiteral.t
                                                                    
                                                                    |
                                                                    ModuleRefLiteral
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    ModuleRefLiteral.t
                                                                    
                                                                    | Logical
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Logical.t
                                                                    
                                                                    | Match
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    match_expression
                                                                    
                                                                    | Member
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Member.t
                                                                    
                                                                    |
                                                                    MetaProperty
                                                                    of 'M
                                                                    MetaProperty.t
                                                                    
                                                                    | New of
                                                                    ('M, 
                                                                    'T) New.t
                                                                    
                                                                    | Object
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Object.t
                                                                    
                                                                    |
                                                                    OptionalCall
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    OptionalCall.t
                                                                    
                                                                    |
                                                                    OptionalMember
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    OptionalMember.t
                                                                    
                                                                    | Record
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Record.t
                                                                    
                                                                    |
                                                                    Sequence
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Sequence.t
                                                                    
                                                                    | Super
                                                                    of 'M
                                                                    Super.t 
                                                                    |
                                                                    TaggedTemplate
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    TaggedTemplate.t
                                                                    
                                                                    |
                                                                    TemplateLiteral
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    TemplateLiteral.t
                                                                    
                                                                    | This of
                                                                    'M This.t
                                                                    
                                                                    |
                                                                    TypeCast
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    TypeCast.t
                                                                    
                                                                    |
                                                                    TSSatisfies
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    TSSatisfies.t
                                                                    
                                                                    | Unary
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Unary.t 
                                                                    | Update
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Update.t
                                                                    
                                                                    | Yield
                                                                    of (
                                                                    'M, 
                                                                    'T)
                                                                    Yield.t 
                                                                    [@@deriving
                                                                    show]
                                                                   end
 and
  JSX:sig
        module Identifier :
        sig
          type ('M, 'T) t = ('T * 'M t')
          and 'M t' = {
            name: string ;
            comments: ('M, unit) Syntax.t option }[@@deriving show]
        end
        module NamespacedName :
        sig
          type ('M, 'T) t = ('M * ('M, 'T) t')
          and ('M, 'T) t' =
            {
            namespace: ('M, 'T) Identifier.t ;
            name: ('M, 'T) Identifier.t }[@@deriving show]
        end
        module ExpressionContainer :
        sig
          type ('M, 'T) t =
            {
            expression: ('M, 'T) expression ;
            comments: ('M, 'M Comment.t list) Syntax.t option }
          and ('M, 'T) expression =
            | Expression of ('M, 'T) Expression.t 
            | EmptyExpression [@@deriving show]
        end
        module Text :
        sig type t = {
              value: string ;
              raw: string }[@@deriving show] end
        module Attribute :
        sig
          type ('M, 'T) t = ('M * ('M, 'T) t')
          and ('M, 'T) name =
            | Identifier of ('M, 'T) Identifier.t 
            | NamespacedName of ('M, 'T) NamespacedName.t 
          and ('M, 'T) value =
            | StringLiteral of ('T * 'M StringLiteral.t) 
            | ExpressionContainer of ('T * ('M, 'T) ExpressionContainer.t) 
          and ('M, 'T) t' =
            {
            name: ('M, 'T) name ;
            value: ('M, 'T) value option }[@@deriving show]
        end
        module SpreadAttribute :
        sig
          type ('M, 'T) t = ('M * ('M, 'T) t')
          and ('M, 'T) t' =
            {
            argument: ('M, 'T) Expression.t ;
            comments: ('M, unit) Syntax.t option }[@@deriving show]
        end
        module MemberExpression :
        sig
          type ('M, 'T) t = ('M * ('M, 'T) t')
          and ('M, 'T) _object =
            | Identifier of ('M, 'T) Identifier.t 
            | MemberExpression of ('M, 'T) t 
          and ('M, 'T) t' =
            {
            _object: ('M, 'T) _object ;
            property: ('M, 'T) Identifier.t }[@@deriving show]
        end
        type ('M, 'T) name =
          | Identifier of ('M, 'T) Identifier.t 
          | NamespacedName of ('M, 'T) NamespacedName.t 
          | MemberExpression of ('M, 'T) MemberExpression.t [@@deriving show]
        module Opening :
        sig
          type ('M, 'T) t = ('M * ('M, 'T) t')
          and ('M, 'T) attribute =
            | Attribute of ('M, 'T) Attribute.t 
            | SpreadAttribute of ('M, 'T) SpreadAttribute.t 
          and ('M, 'T) t' =
            {
            name: ('M, 'T) name ;
            targs: ('M, 'T) Expression.CallTypeArgs.t option ;
            self_closing: bool ;
            attributes: ('M, 'T) attribute list }[@@deriving show]
        end
        module Closing :
        sig
          type ('M, 'T) t = ('M * ('M, 'T) t')
          and ('M, 'T) t' = {
            name: ('M, 'T) name }[@@deriving show]
        end
        module SpreadChild :
        sig
          type ('M, 'T) t =
            {
            expression: ('M, 'T) Expression.t ;
            comments: ('M, unit) Syntax.t option }[@@deriving show]
        end
        type ('M, 'T) child = ('T * ('M, 'T) child')
        and ('M, 'T) child' =
          | Element of ('M, 'T) element 
          | Fragment of ('M, 'T) fragment 
          | ExpressionContainer of ('M, 'T) ExpressionContainer.t 
          | SpreadChild of ('M, 'T) SpreadChild.t 
          | Text of Text.t 
        and ('M, 'T) element =
          {
          opening_element: ('M, 'T) Opening.t ;
          closing_element: ('M, 'T) Closing.t option ;
          children: ('M * ('M, 'T) child list) ;
          comments: ('M, unit) Syntax.t option }
        and ('M, 'T) fragment =
          {
          frag_opening_element: 'M ;
          frag_closing_element: 'M ;
          frag_children: ('M * ('M, 'T) child list) ;
          frag_comments: ('M, unit) Syntax.t option }[@@deriving show]
      end =
  struct
    module Identifier =
      struct
        type ('M, 'T) t = ('T * 'M t')
        and 'M t' = {
          name: string ;
          comments: ('M, unit) Syntax.t option }[@@deriving show]
      end
    module NamespacedName =
      struct
        type ('M, 'T) t = ('M * ('M, 'T) t')
        and ('M, 'T) t' =
          {
          namespace: ('M, 'T) Identifier.t ;
          name: ('M, 'T) Identifier.t }[@@deriving show]
      end
    module ExpressionContainer =
      struct
        type ('M, 'T) t =
          {
          expression: ('M, 'T) expression ;
          comments: ('M, 'M Comment.t list) Syntax.t option }
        and ('M, 'T) expression =
          | Expression of ('M, 'T) Expression.t 
          | EmptyExpression [@@deriving show]
      end
    module Text =
      struct type t = {
               value: string ;
               raw: string }[@@deriving show] end
    module Attribute =
      struct
        type ('M, 'T) t = ('M * ('M, 'T) t')
        and ('M, 'T) name =
          | Identifier of ('M, 'T) Identifier.t 
          | NamespacedName of ('M, 'T) NamespacedName.t 
        and ('M, 'T) value =
          | StringLiteral of ('T * 'M StringLiteral.t) 
          | ExpressionContainer of ('T * ('M, 'T) ExpressionContainer.t) 
        and ('M, 'T) t' =
          {
          name: ('M, 'T) name ;
          value: ('M, 'T) value option }[@@deriving show]
      end
    module SpreadAttribute =
      struct
        type ('M, 'T) t = ('M * ('M, 'T) t')
        and ('M, 'T) t' =
          {
          argument: ('M, 'T) Expression.t ;
          comments: ('M, unit) Syntax.t option }[@@deriving show]
      end
    module MemberExpression =
      struct
        type ('M, 'T) t = ('M * ('M, 'T) t')
        and ('M, 'T) _object =
          | Identifier of ('M, 'T) Identifier.t 
          | MemberExpression of ('M, 'T) t 
        and ('M, 'T) t' =
          {
          _object: ('M, 'T) _object ;
          property: ('M, 'T) Identifier.t }[@@deriving show]
      end
    type ('M, 'T) name =
      | Identifier of ('M, 'T) Identifier.t 
      | NamespacedName of ('M, 'T) NamespacedName.t 
      | MemberExpression of ('M, 'T) MemberExpression.t [@@deriving show]
    module Opening =
      struct
        type ('M, 'T) t = ('M * ('M, 'T) t')
        and ('M, 'T) attribute =
          | Attribute of ('M, 'T) Attribute.t 
          | SpreadAttribute of ('M, 'T) SpreadAttribute.t 
        and ('M, 'T) t' =
          {
          name: ('M, 'T) name ;
          targs: ('M, 'T) Expression.CallTypeArgs.t option ;
          self_closing: bool ;
          attributes: ('M, 'T) attribute list }[@@deriving show]
      end
    module Closing =
      struct
        type ('M, 'T) t = ('M * ('M, 'T) t')
        and ('M, 'T) t' = {
          name: ('M, 'T) name }[@@deriving show]
      end
    module SpreadChild =
      struct
        type ('M, 'T) t =
          {
          expression: ('M, 'T) Expression.t ;
          comments: ('M, unit) Syntax.t option }[@@deriving show]
      end
    type ('M, 'T) child = ('T * ('M, 'T) child')
    and ('M, 'T) child' =
      | Element of ('M, 'T) element 
      | Fragment of ('M, 'T) fragment 
      | ExpressionContainer of ('M, 'T) ExpressionContainer.t 
      | SpreadChild of ('M, 'T) SpreadChild.t 
      | Text of Text.t 
    and ('M, 'T) element =
      {
      opening_element: ('M, 'T) Opening.t ;
      closing_element: ('M, 'T) Closing.t option ;
      children: ('M * ('M, 'T) child list) ;
      comments: ('M, unit) Syntax.t option }
    and ('M, 'T) fragment =
      {
      frag_opening_element: 'M ;
      frag_closing_element: 'M ;
      frag_children: ('M * ('M, 'T) child list) ;
      frag_comments: ('M, unit) Syntax.t option }[@@deriving show]
  end and
       Match:sig
               module Case :
               sig
                 module InvalidSyntax :
                 sig
                   type 'M t =
                     {
                     invalid_prefix_case: 'M option ;
                     invalid_infix_colon: 'M option ;
                     invalid_suffix_semicolon: 'M option }[@@deriving show]
                 end
                 type ('M, 'T, 'B) t = ('M * ('M, 'T, 'B) t')
                 and ('M, 'T, 'B) t' =
                   {
                   pattern: ('M, 'T) MatchPattern.t ;
                   body: 'B ;
                   guard: ('M, 'T) Expression.t option ;
                   comments: ('M, unit) Syntax.t option ;
                   invalid_syntax: 'M InvalidSyntax.t ;
                   case_match_root_loc: 'M }[@@deriving show]
               end
               type ('M, 'T, 'B) t =
                 {
                 arg: ('M, 'T) Expression.t ;
                 cases: ('M, 'T, 'B) Case.t list ;
                 match_keyword_loc: 'M ;
                 comments: ('M, unit) Syntax.t option }[@@deriving show]
             end =
       struct
         module Case =
           struct
             module InvalidSyntax =
               struct
                 type 'M t =
                   {
                   invalid_prefix_case: 'M option ;
                   invalid_infix_colon: 'M option ;
                   invalid_suffix_semicolon: 'M option }[@@deriving show]
               end
             type ('M, 'T, 'B) t = ('M * ('M, 'T, 'B) t')
             and ('M, 'T, 'B) t' =
               {
               pattern: ('M, 'T) MatchPattern.t ;
               body: 'B ;
               guard: ('M, 'T) Expression.t option ;
               comments: ('M, unit) Syntax.t option ;
               invalid_syntax: 'M InvalidSyntax.t ;
               case_match_root_loc: 'M }[@@deriving show]
           end
         type ('M, 'T, 'B) t =
           {
           arg: ('M, 'T) Expression.t ;
           cases: ('M, 'T, 'B) Case.t list ;
           match_keyword_loc: 'M ;
           comments: ('M, unit) Syntax.t option }[@@deriving show]
       end and
            MatchPattern:sig
                           module UnaryPattern :
                           sig
                             type operator =
                               | Plus 
                               | Minus 
                             and 'M argument =
                               | NumberLiteral of 'M NumberLiteral.t 
                               | BigIntLiteral of 'M BigIntLiteral.t 
                             and 'M t =
                               {
                               operator: operator ;
                               argument: ('M * 'M argument) ;
                               comments: ('M, unit) Syntax.t option }
                             [@@deriving show]
                           end
                           module MemberPattern :
                           sig
                             type ('M, 'T) base =
                               | BaseIdentifier of ('M, 'T) Identifier.t 
                               | BaseMember of ('M, 'T) t 
                             and ('M, 'T) property =
                               | PropertyString of ('M * 'M StringLiteral.t)
                               
                               | PropertyNumber of ('M * 'M NumberLiteral.t)
                               
                               | PropertyBigInt of ('M * 'M BigIntLiteral.t)
                               
                               | PropertyIdentifier of ('M, 'T) Identifier.t 
                             and ('M, 'T) t = ('T * ('M, 'T) t')
                             and ('M, 'T) t' =
                               {
                               base: ('M, 'T) base ;
                               property: ('M, 'T) property ;
                               comments: ('M, unit) Syntax.t option }
                             [@@deriving show]
                           end
                           module BindingPattern :
                           sig
                             type ('M, 'T) t =
                               {
                               kind: Variable.kind ;
                               id: ('M, 'T) Identifier.t ;
                               comments: ('M, unit) Syntax.t option }
                             [@@deriving show]
                           end
                           module RestPattern :
                           sig
                             type ('M, 'T) t = ('M * ('M, 'T) t')
                             and ('M, 'T) t' =
                               {
                               argument:
                                 ('M * ('M, 'T) BindingPattern.t) option ;
                               comments: ('M, unit) Syntax.t option }
                             [@@deriving show]
                           end
                           module ObjectPattern :
                           sig
                             module Property :
                             sig
                               type ('M, 'T) key =
                                 | StringLiteral of ('M * 'M StringLiteral.t)
                                 
                                 | NumberLiteral of ('M * 'M NumberLiteral.t)
                                 
                                 | BigIntLiteral of ('M * 'M BigIntLiteral.t)
                                 
                                 | Identifier of ('M, 'T) Identifier.t 
                               and ('M, 'T) property =
                                 {
                                 key: ('M, 'T) key ;
                                 pattern: ('M, 'T) MatchPattern.t ;
                                 shorthand: bool ;
                                 comments: ('M, unit) Syntax.t option }
                               and ('M, 'T) t = ('M * ('M, 'T) t')
                               and ('M, 'T) t' =
                                 | Valid of ('M, 'T) property 
                                 | InvalidShorthand of ('M, 'M) Identifier.t 
                               [@@deriving show]
                             end
                             type ('M, 'T) t =
                               {
                               properties: ('M, 'T) Property.t list ;
                               rest: ('M, 'T) RestPattern.t option ;
                               comments:
                                 ('M, 'M Comment.t list) Syntax.t option }
                             [@@deriving show]
                           end
                           module ArrayPattern :
                           sig
                             module Element :
                             sig
                               type ('M, 'T) t =
                                 {
                                 index: 'M ;
                                 pattern: ('M, 'T) MatchPattern.t }[@@deriving
                                                                    show]
                             end
                             type ('M, 'T) t =
                               {
                               elements: ('M, 'T) Element.t list ;
                               rest: ('M, 'T) RestPattern.t option ;
                               comments:
                                 ('M, 'M Comment.t list) Syntax.t option }
                             [@@deriving show]
                           end
                           module InstancePattern :
                           sig
                             type ('M, 'T) constructor =
                               | IdentifierConstructor of ('M, 'T)
                               Identifier.t 
                               | MemberConstructor of ('M, 'T)
                               MemberPattern.t 
                             and ('M, 'T) t =
                               {
                               constructor: ('M, 'T) constructor ;
                               properties: ('M * ('M, 'T) ObjectPattern.t) ;
                               comments: ('M, unit) Syntax.t option }
                             [@@deriving show]
                           end
                           module OrPattern :
                           sig
                             type ('M, 'T) t =
                               {
                               patterns: ('M, 'T) MatchPattern.t list ;
                               comments: ('M, unit) Syntax.t option }
                             [@@deriving show]
                           end
                           module AsPattern :
                           sig
                             type ('M, 'T) target =
                               | Identifier of ('M, 'T) Identifier.t 
                               | Binding of 'M * ('M, 'T) BindingPattern.t 
                             and ('M, 'T) t =
                               {
                               pattern: ('M, 'T) MatchPattern.t ;
                               target: ('M, 'T) target ;
                               comments: ('M, unit) Syntax.t option }
                             [@@deriving show]
                           end
                           module WildcardPattern :
                           sig
                             type 'M t =
                               {
                               comments: ('M, unit) Syntax.t option ;
                               invalid_syntax_default_keyword: bool }
                             [@@deriving show]
                           end
                           type ('M, 'T) t = ('M * ('M, 'T) t')
                           and ('M, 'T) t' =
                             | WildcardPattern of 'M WildcardPattern.t 
                             | NumberPattern of 'M NumberLiteral.t 
                             | BigIntPattern of 'M BigIntLiteral.t 
                             | StringPattern of 'M StringLiteral.t 
                             | BooleanPattern of 'M BooleanLiteral.t 
                             | NullPattern of ('M, unit) Syntax.t option 
                             | UnaryPattern of 'M UnaryPattern.t 
                             | BindingPattern of ('M, 'T) BindingPattern.t 
                             | IdentifierPattern of ('M, 'T) Identifier.t 
                             | MemberPattern of ('M, 'T) MemberPattern.t 
                             | ObjectPattern of ('M, 'T) ObjectPattern.t 
                             | ArrayPattern of ('M, 'T) ArrayPattern.t 
                             | InstancePattern of ('M, 'T) InstancePattern.t
                             
                             | OrPattern of ('M, 'T) OrPattern.t 
                             | AsPattern of ('M, 'T) AsPattern.t [@@deriving
                                                                   show]
                         end =
            struct
              module UnaryPattern =
                struct
                  type operator =
                    | Plus 
                    | Minus 
                  and 'M argument =
                    | NumberLiteral of 'M NumberLiteral.t 
                    | BigIntLiteral of 'M BigIntLiteral.t 
                  and 'M t =
                    {
                    operator: operator ;
                    argument: ('M * 'M argument) ;
                    comments: ('M, unit) Syntax.t option }[@@deriving show]
                end
              module MemberPattern =
                struct
                  type ('M, 'T) base =
                    | BaseIdentifier of ('M, 'T) Identifier.t 
                    | BaseMember of ('M, 'T) t 
                  and ('M, 'T) property =
                    | PropertyString of ('M * 'M StringLiteral.t) 
                    | PropertyNumber of ('M * 'M NumberLiteral.t) 
                    | PropertyBigInt of ('M * 'M BigIntLiteral.t) 
                    | PropertyIdentifier of ('M, 'T) Identifier.t 
                  and ('M, 'T) t = ('T * ('M, 'T) t')
                  and ('M, 'T) t' =
                    {
                    base: ('M, 'T) base ;
                    property: ('M, 'T) property ;
                    comments: ('M, unit) Syntax.t option }[@@deriving show]
                end
              module BindingPattern =
                struct
                  type ('M, 'T) t =
                    {
                    kind: Variable.kind ;
                    id: ('M, 'T) Identifier.t ;
                    comments: ('M, unit) Syntax.t option }[@@deriving show]
                end
              module RestPattern =
                struct
                  type ('M, 'T) t = ('M * ('M, 'T) t')
                  and ('M, 'T) t' =
                    {
                    argument: ('M * ('M, 'T) BindingPattern.t) option ;
                    comments: ('M, unit) Syntax.t option }[@@deriving show]
                end
              module ObjectPattern =
                struct
                  module Property =
                    struct
                      type ('M, 'T) key =
                        | StringLiteral of ('M * 'M StringLiteral.t) 
                        | NumberLiteral of ('M * 'M NumberLiteral.t) 
                        | BigIntLiteral of ('M * 'M BigIntLiteral.t) 
                        | Identifier of ('M, 'T) Identifier.t 
                      and ('M, 'T) property =
                        {
                        key: ('M, 'T) key ;
                        pattern: ('M, 'T) MatchPattern.t ;
                        shorthand: bool ;
                        comments: ('M, unit) Syntax.t option }
                      and ('M, 'T) t = ('M * ('M, 'T) t')
                      and ('M, 'T) t' =
                        | Valid of ('M, 'T) property 
                        | InvalidShorthand of ('M, 'M) Identifier.t [@@deriving
                                                                    show]
                    end
                  type ('M, 'T) t =
                    {
                    properties: ('M, 'T) Property.t list ;
                    rest: ('M, 'T) RestPattern.t option ;
                    comments: ('M, 'M Comment.t list) Syntax.t option }
                  [@@deriving show]
                end
              module ArrayPattern =
                struct
                  module Element =
                    struct
                      type ('M, 'T) t =
                        {
                        index: 'M ;
                        pattern: ('M, 'T) MatchPattern.t }[@@deriving show]
                    end
                  type ('M, 'T) t =
                    {
                    elements: ('M, 'T) Element.t list ;
                    rest: ('M, 'T) RestPattern.t option ;
                    comments: ('M, 'M Comment.t list) Syntax.t option }
                  [@@deriving show]
                end
              module InstancePattern =
                struct
                  type ('M, 'T) constructor =
                    | IdentifierConstructor of ('M, 'T) Identifier.t 
                    | MemberConstructor of ('M, 'T) MemberPattern.t 
                  and ('M, 'T) t =
                    {
                    constructor: ('M, 'T) constructor ;
                    properties: ('M * ('M, 'T) ObjectPattern.t) ;
                    comments: ('M, unit) Syntax.t option }[@@deriving show]
                end
              module OrPattern =
                struct
                  type ('M, 'T) t =
                    {
                    patterns: ('M, 'T) MatchPattern.t list ;
                    comments: ('M, unit) Syntax.t option }[@@deriving show]
                end
              module AsPattern =
                struct
                  type ('M, 'T) target =
                    | Identifier of ('M, 'T) Identifier.t 
                    | Binding of 'M * ('M, 'T) BindingPattern.t 
                  and ('M, 'T) t =
                    {
                    pattern: ('M, 'T) MatchPattern.t ;
                    target: ('M, 'T) target ;
                    comments: ('M, unit) Syntax.t option }[@@deriving show]
                end
              module WildcardPattern =
                struct
                  type 'M t =
                    {
                    comments: ('M, unit) Syntax.t option ;
                    invalid_syntax_default_keyword: bool }[@@deriving show]
                end
              type ('M, 'T) t = ('M * ('M, 'T) t')
              and ('M, 'T) t' =
                | WildcardPattern of 'M WildcardPattern.t 
                | NumberPattern of 'M NumberLiteral.t 
                | BigIntPattern of 'M BigIntLiteral.t 
                | StringPattern of 'M StringLiteral.t 
                | BooleanPattern of 'M BooleanLiteral.t 
                | NullPattern of ('M, unit) Syntax.t option 
                | UnaryPattern of 'M UnaryPattern.t 
                | BindingPattern of ('M, 'T) BindingPattern.t 
                | IdentifierPattern of ('M, 'T) Identifier.t 
                | MemberPattern of ('M, 'T) MemberPattern.t 
                | ObjectPattern of ('M, 'T) ObjectPattern.t 
                | ArrayPattern of ('M, 'T) ArrayPattern.t 
                | InstancePattern of ('M, 'T) InstancePattern.t 
                | OrPattern of ('M, 'T) OrPattern.t 
                | AsPattern of ('M, 'T) AsPattern.t [@@deriving show]
            end and
                 Pattern:sig
                           module RestElement :
                           sig
                             type ('M, 'T) t = ('M * ('M, 'T) t')
                             and ('M, 'T) t' =
                               {
                               argument: ('M, 'T) Pattern.t ;
                               comments: ('M, unit) Syntax.t option }
                             [@@deriving show]
                           end
                           module Object :
                           sig
                             module Property :
                             sig
                               type ('M, 'T) key =
                                 | StringLiteral of ('M * 'M StringLiteral.t)
                                 
                                 | NumberLiteral of ('M * 'M NumberLiteral.t)
                                 
                                 | BigIntLiteral of ('M * 'M BigIntLiteral.t)
                                 
                                 | Identifier of ('M, 'T) Identifier.t 
                                 | Computed of ('M, 'T) ComputedKey.t 
                               and ('M, 'T) t = ('M * ('M, 'T) t')
                               and ('M, 'T) t' =
                                 {
                                 key: ('M, 'T) key ;
                                 pattern: ('M, 'T) Pattern.t ;
                                 default: ('M, 'T) Expression.t option ;
                                 shorthand: bool }[@@deriving show]
                             end
                             type ('M, 'T) property =
                               | Property of ('M, 'T) Property.t 
                               | RestElement of ('M, 'T) RestElement.t 
                             and ('M, 'T) t =
                               {
                               properties: ('M, 'T) property list ;
                               annot: ('M, 'T) Type.annotation_or_hint ;
                               optional: bool ;
                               comments:
                                 ('M, 'M Comment.t list) Syntax.t option }
                             [@@deriving show]
                           end
                           module Array :
                           sig
                             module Element :
                             sig
                               type ('M, 'T) t = ('M * ('M, 'T) t')
                               and ('M, 'T) t' =
                                 {
                                 argument: ('M, 'T) Pattern.t ;
                                 default: ('M, 'T) Expression.t option }
                               [@@deriving show]
                             end
                             type ('M, 'T) element =
                               | Element of ('M, 'T) Element.t 
                               | RestElement of ('M, 'T) RestElement.t 
                               | Hole of 'M 
                             and ('M, 'T) t =
                               {
                               elements: ('M, 'T) element list ;
                               annot: ('M, 'T) Type.annotation_or_hint ;
                               optional: bool ;
                               comments:
                                 ('M, 'M Comment.t list) Syntax.t option }
                             [@@deriving show]
                           end
                           module Identifier :
                           sig
                             type ('M, 'T) t =
                               {
                               name: ('M, 'T) Identifier.t ;
                               annot: ('M, 'T) Type.annotation_or_hint ;
                               optional: bool }[@@deriving show]
                           end
                           type ('M, 'T) t = ('T * ('M, 'T) t')
                           and ('M, 'T) t' =
                             | Object of ('M, 'T) Object.t 
                             | Array of ('M, 'T) Array.t 
                             | Identifier of ('M, 'T) Identifier.t 
                             | Expression of ('M, 'T) Expression.t [@@deriving
                                                                    show]
                         end =
                 struct
                   module RestElement =
                     struct
                       type ('M, 'T) t = ('M * ('M, 'T) t')
                       and ('M, 'T) t' =
                         {
                         argument: ('M, 'T) Pattern.t ;
                         comments: ('M, unit) Syntax.t option }[@@deriving
                                                                 show]
                     end
                   module Object =
                     struct
                       module Property =
                         struct
                           type ('M, 'T) key =
                             | StringLiteral of ('M * 'M StringLiteral.t) 
                             | NumberLiteral of ('M * 'M NumberLiteral.t) 
                             | BigIntLiteral of ('M * 'M BigIntLiteral.t) 
                             | Identifier of ('M, 'T) Identifier.t 
                             | Computed of ('M, 'T) ComputedKey.t 
                           and ('M, 'T) t = ('M * ('M, 'T) t')
                           and ('M, 'T) t' =
                             {
                             key: ('M, 'T) key ;
                             pattern: ('M, 'T) Pattern.t ;
                             default: ('M, 'T) Expression.t option ;
                             shorthand: bool }[@@deriving show]
                         end
                       type ('M, 'T) property =
                         | Property of ('M, 'T) Property.t 
                         | RestElement of ('M, 'T) RestElement.t 
                       and ('M, 'T) t =
                         {
                         properties: ('M, 'T) property list ;
                         annot: ('M, 'T) Type.annotation_or_hint ;
                         optional: bool ;
                         comments: ('M, 'M Comment.t list) Syntax.t option }
                       [@@deriving show]
                     end
                   module Array =
                     struct
                       module Element =
                         struct
                           type ('M, 'T) t = ('M * ('M, 'T) t')
                           and ('M, 'T) t' =
                             {
                             argument: ('M, 'T) Pattern.t ;
                             default: ('M, 'T) Expression.t option }[@@deriving
                                                                    show]
                         end
                       type ('M, 'T) element =
                         | Element of ('M, 'T) Element.t 
                         | RestElement of ('M, 'T) RestElement.t 
                         | Hole of 'M 
                       and ('M, 'T) t =
                         {
                         elements: ('M, 'T) element list ;
                         annot: ('M, 'T) Type.annotation_or_hint ;
                         optional: bool ;
                         comments: ('M, 'M Comment.t list) Syntax.t option }
                       [@@deriving show]
                     end
                   module Identifier =
                     struct
                       type ('M, 'T) t =
                         {
                         name: ('M, 'T) Identifier.t ;
                         annot: ('M, 'T) Type.annotation_or_hint ;
                         optional: bool }[@@deriving show]
                     end
                   type ('M, 'T) t = ('T * ('M, 'T) t')
                   and ('M, 'T) t' =
                     | Object of ('M, 'T) Object.t 
                     | Array of ('M, 'T) Array.t 
                     | Identifier of ('M, 'T) Identifier.t 
                     | Expression of ('M, 'T) Expression.t [@@deriving show]
                 end and
                      Comment:sig
                                type 'M t = ('M * t')
                                and kind =
                                  | Block 
                                  | Line 
                                and t' =
                                  {
                                  kind: kind ;
                                  text: string ;
                                  on_newline: bool }[@@deriving show]
                              end =
                      struct
                        type 'M t = ('M * t')
                        and kind =
                          | Block 
                          | Line 
                        and t' =
                          {
                          kind: kind ;
                          text: string ;
                          on_newline: bool }[@@deriving show]
                      end and
                           Class:sig
                                   module TSAccessibility :
                                   sig
                                     type kind =
                                       | Public 
                                       | Protected 
                                       | Private 
                                     and 'M t = ('M * 'M t')
                                     and 'M t' =
                                       {
                                       kind: kind ;
                                       comments: ('M, unit) Syntax.t option }
                                     [@@deriving show]
                                   end
                                   module Method :
                                   sig
                                     type ('M, 'T) t = ('T * ('M, 'T) t')
                                     and kind =
                                       | Constructor 
                                       | Method 
                                       | Get 
                                       | Set 
                                     and ('M, 'T) t' =
                                       {
                                       kind: kind ;
                                       key:
                                         ('M, 'T)
                                           Expression.Object.Property.key
                                         ;
                                       value: ('M * ('M, 'T) Function.t) ;
                                       static: bool ;
                                       override: bool ;
                                       ts_accessibility:
                                         'M TSAccessibility.t option ;
                                       decorators:
                                         ('M, 'T) Class.Decorator.t list ;
                                       comments: ('M, unit) Syntax.t option }
                                     [@@deriving show]
                                   end
                                   module DeclareMethod :
                                   sig
                                     type ('M, 'T) t = ('T * ('M, 'T) t')
                                     and ('M, 'T) t' =
                                       {
                                       kind: Method.kind ;
                                       key:
                                         ('M, 'T)
                                           Expression.Object.Property.key
                                         ;
                                       annot: ('M, 'T) Type.annotation ;
                                       static: bool ;
                                       override: bool ;
                                       optional: bool ;
                                       comments: ('M, unit) Syntax.t option }
                                     [@@deriving show]
                                   end
                                   module AbstractMethod :
                                   sig
                                     type ('M, 'T) t = ('T * ('M, 'T) t')
                                     and ('M, 'T) t' =
                                       {
                                       key:
                                         ('M, 'T)
                                           Expression.Object.Property.key
                                         ;
                                       annot: ('M * ('M, 'T) Type.Function.t) ;
                                       override: bool ;
                                       ts_accessibility:
                                         'M TSAccessibility.t option ;
                                       comments: ('M, unit) Syntax.t option }
                                     [@@deriving show]
                                   end
                                   module AbstractProperty :
                                   sig
                                     type ('M, 'T) t = ('T * ('M, 'T) t')
                                     and ('M, 'T) t' =
                                       {
                                       key:
                                         ('M, 'T)
                                           Expression.Object.Property.key
                                         ;
                                       annot:
                                         ('M, 'T) Type.annotation_or_hint ;
                                       override: bool ;
                                       ts_accessibility:
                                         'M TSAccessibility.t option ;
                                       variance: 'M Variance.t option ;
                                       comments: ('M, unit) Syntax.t option }
                                     [@@deriving show]
                                   end
                                   module Property :
                                   sig
                                     type ('M, 'T) t = ('T * ('M, 'T) t')
                                     and ('M, 'T) t' =
                                       {
                                       key:
                                         ('M, 'T)
                                           Expression.Object.Property.key
                                         ;
                                       value: ('M, 'T) value ;
                                       annot:
                                         ('M, 'T) Type.annotation_or_hint ;
                                       static: bool ;
                                       override: bool ;
                                       optional: bool ;
                                       variance: 'M Variance.t option ;
                                       ts_accessibility:
                                         'M TSAccessibility.t option ;
                                       decorators:
                                         ('M, 'T) Class.Decorator.t list ;
                                       comments: ('M, unit) Syntax.t option }
                                     and ('M, 'T) value =
                                       | Declared 
                                       | Uninitialized 
                                       | Initialized of ('M, 'T) Expression.t 
                                     [@@deriving show]
                                   end
                                   module PrivateField :
                                   sig
                                     type ('M, 'T) t = ('T * ('M, 'T) t')
                                     and ('M, 'T) t' =
                                       {
                                       key: 'M PrivateName.t ;
                                       value: ('M, 'T) Class.Property.value ;
                                       annot:
                                         ('M, 'T) Type.annotation_or_hint ;
                                       static: bool ;
                                       override: bool ;
                                       optional: bool ;
                                       variance: 'M Variance.t option ;
                                       ts_accessibility:
                                         'M TSAccessibility.t option ;
                                       decorators:
                                         ('M, 'T) Class.Decorator.t list ;
                                       comments: ('M, unit) Syntax.t option }
                                     [@@deriving show]
                                   end
                                   module StaticBlock :
                                   sig
                                     type ('M, 'T) t = ('M * ('M, 'T) t')
                                     and ('M, 'T) t' =
                                       {
                                       body: ('M, 'T) Statement.t list ;
                                       comments:
                                         ('M, 'M Comment.t list) Syntax.t
                                           option
                                         }[@@deriving show]
                                   end
                                   module Extends :
                                   sig
                                     type ('M, 'T) t = ('M * ('M, 'T) t')
                                     and ('M, 'T) t' =
                                       {
                                       expr: ('M, 'T) Expression.t ;
                                       targs: ('M, 'T) Type.TypeArgs.t option ;
                                       comments: ('M, unit) Syntax.t option }
                                     [@@deriving show]
                                   end
                                   module Implements :
                                   sig
                                     module Interface :
                                     sig
                                       type ('M, 'T) t = ('M * ('M, 'T) t')
                                       and ('M, 'T) t' =
                                         {
                                         id:
                                           ('M, 'T) Type.Generic.Identifier.t ;
                                         targs:
                                           ('M, 'T) Type.TypeArgs.t option }
                                       [@@deriving show]
                                     end
                                     type ('M, 'T) t = ('M * ('M, 'T) t')
                                     and ('M, 'T) t' =
                                       {
                                       interfaces: ('M, 'T) Interface.t list ;
                                       comments: ('M, unit) Syntax.t option }
                                     [@@deriving show]
                                   end
                                   module Body :
                                   sig
                                     type ('M, 'T) t = ('M * ('M, 'T) t')
                                     and ('M, 'T) t' =
                                       {
                                       body: ('M, 'T) element list ;
                                       comments: ('M, unit) Syntax.t option }
                                     and ('M, 'T) element =
                                       | Method of ('M, 'T) Method.t 
                                       | Property of ('M, 'T) Property.t 
                                       | PrivateField of ('M, 'T)
                                       PrivateField.t 
                                       | StaticBlock of ('M, 'T)
                                       StaticBlock.t 
                                       | DeclareMethod of ('M, 'T)
                                       DeclareMethod.t 
                                       | AbstractMethod of ('M, 'T)
                                       AbstractMethod.t 
                                       | AbstractProperty of ('M, 'T)
                                       AbstractProperty.t 
                                       | IndexSignature of ('M, 'T)
                                       Type.Object.Indexer.t [@@deriving
                                                               show]
                                   end
                                   module Decorator :
                                   sig
                                     type ('M, 'T) t = ('M * ('M, 'T) t')
                                     and ('M, 'T) t' =
                                       {
                                       expression: ('M, 'T) Expression.t ;
                                       comments: ('M, unit) Syntax.t option }
                                     [@@deriving show]
                                   end
                                   type ('M, 'T) t =
                                     {
                                     id: ('M, 'T) Identifier.t option ;
                                     body: ('M, 'T) Class.Body.t ;
                                     tparams:
                                       ('M, 'T) Type.TypeParams.t option ;
                                     extends: ('M, 'T) Extends.t option ;
                                     implements: ('M, 'T) Implements.t option ;
                                     class_decorators:
                                       ('M, 'T) Decorator.t list ;
                                     abstract: bool ;
                                     comments: ('M, unit) Syntax.t option }
                                   [@@deriving show]
                                 end =
                           struct
                             module TSAccessibility =
                               struct
                                 type kind =
                                   | Public 
                                   | Protected 
                                   | Private 
                                 and 'M t = ('M * 'M t')
                                 and 'M t' =
                                   {
                                   kind: kind ;
                                   comments: ('M, unit) Syntax.t option }
                                 [@@deriving show]
                               end
                             module Method =
                               struct
                                 type ('M, 'T) t = ('T * ('M, 'T) t')
                                 and kind =
                                   | Constructor 
                                   | Method 
                                   | Get 
                                   | Set 
                                 and ('M, 'T) t' =
                                   {
                                   kind: kind ;
                                   key:
                                     ('M, 'T) Expression.Object.Property.key ;
                                   value: ('M * ('M, 'T) Function.t) ;
                                   static: bool ;
                                   override: bool ;
                                   ts_accessibility:
                                     'M TSAccessibility.t option ;
                                   decorators:
                                     ('M, 'T) Class.Decorator.t list ;
                                   comments: ('M, unit) Syntax.t option }
                                 [@@deriving show]
                               end
                             module DeclareMethod =
                               struct
                                 type ('M, 'T) t = ('T * ('M, 'T) t')
                                 and ('M, 'T) t' =
                                   {
                                   kind: Method.kind ;
                                   key:
                                     ('M, 'T) Expression.Object.Property.key ;
                                   annot: ('M, 'T) Type.annotation ;
                                   static: bool ;
                                   override: bool ;
                                   optional: bool ;
                                   comments: ('M, unit) Syntax.t option }
                                 [@@deriving show]
                               end
                             module AbstractMethod =
                               struct
                                 type ('M, 'T) t = ('T * ('M, 'T) t')
                                 and ('M, 'T) t' =
                                   {
                                   key:
                                     ('M, 'T) Expression.Object.Property.key ;
                                   annot: ('M * ('M, 'T) Type.Function.t) ;
                                   override: bool ;
                                   ts_accessibility:
                                     'M TSAccessibility.t option ;
                                   comments: ('M, unit) Syntax.t option }
                                 [@@deriving show]
                               end
                             module AbstractProperty =
                               struct
                                 type ('M, 'T) t = ('T * ('M, 'T) t')
                                 and ('M, 'T) t' =
                                   {
                                   key:
                                     ('M, 'T) Expression.Object.Property.key ;
                                   annot: ('M, 'T) Type.annotation_or_hint ;
                                   override: bool ;
                                   ts_accessibility:
                                     'M TSAccessibility.t option ;
                                   variance: 'M Variance.t option ;
                                   comments: ('M, unit) Syntax.t option }
                                 [@@deriving show]
                               end
                             module Property =
                               struct
                                 type ('M, 'T) t = ('T * ('M, 'T) t')
                                 and ('M, 'T) t' =
                                   {
                                   key:
                                     ('M, 'T) Expression.Object.Property.key ;
                                   value: ('M, 'T) value ;
                                   annot: ('M, 'T) Type.annotation_or_hint ;
                                   static: bool ;
                                   override: bool ;
                                   optional: bool ;
                                   variance: 'M Variance.t option ;
                                   ts_accessibility:
                                     'M TSAccessibility.t option ;
                                   decorators:
                                     ('M, 'T) Class.Decorator.t list ;
                                   comments: ('M, unit) Syntax.t option }
                                 and ('M, 'T) value =
                                   | Declared 
                                   | Uninitialized 
                                   | Initialized of ('M, 'T) Expression.t 
                                 [@@deriving show]
                               end
                             module PrivateField =
                               struct
                                 type ('M, 'T) t = ('T * ('M, 'T) t')
                                 and ('M, 'T) t' =
                                   {
                                   key: 'M PrivateName.t ;
                                   value: ('M, 'T) Class.Property.value ;
                                   annot: ('M, 'T) Type.annotation_or_hint ;
                                   static: bool ;
                                   override: bool ;
                                   optional: bool ;
                                   variance: 'M Variance.t option ;
                                   ts_accessibility:
                                     'M TSAccessibility.t option ;
                                   decorators:
                                     ('M, 'T) Class.Decorator.t list ;
                                   comments: ('M, unit) Syntax.t option }
                                 [@@deriving show]
                               end
                             module StaticBlock =
                               struct
                                 type ('M, 'T) t = ('M * ('M, 'T) t')
                                 and ('M, 'T) t' =
                                   {
                                   body: ('M, 'T) Statement.t list ;
                                   comments:
                                     ('M, 'M Comment.t list) Syntax.t option }
                                 [@@deriving show]
                               end
                             module Extends =
                               struct
                                 type ('M, 'T) t = ('M * ('M, 'T) t')
                                 and ('M, 'T) t' =
                                   {
                                   expr: ('M, 'T) Expression.t ;
                                   targs: ('M, 'T) Type.TypeArgs.t option ;
                                   comments: ('M, unit) Syntax.t option }
                                 [@@deriving show]
                               end
                             module Implements =
                               struct
                                 module Interface =
                                   struct
                                     type ('M, 'T) t = ('M * ('M, 'T) t')
                                     and ('M, 'T) t' =
                                       {
                                       id: ('M, 'T) Type.Generic.Identifier.t ;
                                       targs: ('M, 'T) Type.TypeArgs.t option }
                                     [@@deriving show]
                                   end
                                 type ('M, 'T) t = ('M * ('M, 'T) t')
                                 and ('M, 'T) t' =
                                   {
                                   interfaces: ('M, 'T) Interface.t list ;
                                   comments: ('M, unit) Syntax.t option }
                                 [@@deriving show]
                               end
                             module Body =
                               struct
                                 type ('M, 'T) t = ('M * ('M, 'T) t')
                                 and ('M, 'T) t' =
                                   {
                                   body: ('M, 'T) element list ;
                                   comments: ('M, unit) Syntax.t option }
                                 and ('M, 'T) element =
                                   | Method of ('M, 'T) Method.t 
                                   | Property of ('M, 'T) Property.t 
                                   | PrivateField of ('M, 'T) PrivateField.t
                                   
                                   | StaticBlock of ('M, 'T) StaticBlock.t 
                                   | DeclareMethod of ('M, 'T)
                                   DeclareMethod.t 
                                   | AbstractMethod of ('M, 'T)
                                   AbstractMethod.t 
                                   | AbstractProperty of ('M, 'T)
                                   AbstractProperty.t 
                                   | IndexSignature of ('M, 'T)
                                   Type.Object.Indexer.t [@@deriving show]
                               end
                             module Decorator =
                               struct
                                 type ('M, 'T) t = ('M * ('M, 'T) t')
                                 and ('M, 'T) t' =
                                   {
                                   expression: ('M, 'T) Expression.t ;
                                   comments: ('M, unit) Syntax.t option }
                                 [@@deriving show]
                               end
                             type ('M, 'T) t =
                               {
                               id: ('M, 'T) Identifier.t option ;
                               body: ('M, 'T) Class.Body.t ;
                               tparams: ('M, 'T) Type.TypeParams.t option ;
                               extends: ('M, 'T) Extends.t option ;
                               implements: ('M, 'T) Implements.t option ;
                               class_decorators: ('M, 'T) Decorator.t list ;
                               abstract: bool ;
                               comments: ('M, unit) Syntax.t option }
                             [@@deriving show]
                           end and
                                Function:sig
                                           module RestParam :
                                           sig
                                             type ('M, 'T) t =
                                               ('M * ('M, 'T) t')
                                             and ('M, 'T) t' =
                                               {
                                               argument: ('M, 'T) Pattern.t ;
                                               comments:
                                                 ('M, unit) Syntax.t option }
                                             [@@deriving show]
                                           end
                                           module Param :
                                           sig
                                             type ('M, 'T) t =
                                               ('M * ('M, 'T) t')
                                             and ('M, 'T) t' =
                                               | RegularParam of
                                               {
                                               argument: ('M, 'T) Pattern.t ;
                                               default:
                                                 ('M, 'T) Expression.t option }
                                               
                                               | ParamProperty of ('M, 
                                               'T) Class.Property.t' 
                                             [@@deriving show]
                                           end
                                           module ThisParam :
                                           sig
                                             type ('M, 'T) t =
                                               ('M * ('M, 'T) t')
                                             and ('M, 'T) t' =
                                               {
                                               annot:
                                                 ('M, 'T) Type.annotation ;
                                               comments:
                                                 ('M, unit) Syntax.t option }
                                             [@@deriving show]
                                           end
                                           module Params :
                                           sig
                                             type ('M, 'T) t =
                                               ('M * ('M, 'T) t')
                                             and ('M, 'T) t' =
                                               {
                                               this_:
                                                 ('M, 'T) ThisParam.t option ;
                                               params: ('M, 'T) Param.t list ;
                                               rest:
                                                 ('M, 'T) RestParam.t option ;
                                               comments:
                                                 ('M, 'M Comment.t list)
                                                   Syntax.t option
                                                 }[@@deriving show]
                                           end
                                           module ReturnAnnot :
                                           sig
                                             type ('M, 'T) t =
                                               | Missing of 'T 
                                               | Available of ('M, 'T)
                                               Type.annotation 
                                               | TypeGuard of ('M, 'T)
                                               Type.type_guard_annotation 
                                             [@@deriving show]
                                           end
                                           type effect_ =
                                             | Hook 
                                             | Arbitrary [@@deriving show]
                                           type ('M, 'T) t =
                                             {
                                             id: ('M, 'T) Identifier.t option ;
                                             params: ('M, 'T) Params.t ;
                                             body: ('M, 'T) body ;
                                             async: bool ;
                                             generator: bool ;
                                             effect_: effect_ ;
                                             predicate:
                                               ('M, 'T) Type.Predicate.t
                                                 option
                                               ;
                                             return: ('M, 'T) ReturnAnnot.t ;
                                             tparams:
                                               ('M, 'T) Type.TypeParams.t
                                                 option
                                               ;
                                             comments:
                                               ('M, unit) Syntax.t option ;
                                             sig_loc: 'M }
                                           and ('M, 'T) body =
                                             | BodyBlock of ('M * ('M, 
                                             'T) Statement.Block.t) 
                                             | BodyExpression of ('M, 
                                             'T) Expression.t [@@deriving
                                                                show]
                                         end =
                                struct
                                  module RestParam =
                                    struct
                                      type ('M, 'T) t = ('M * ('M, 'T) t')
                                      and ('M, 'T) t' =
                                        {
                                        argument: ('M, 'T) Pattern.t ;
                                        comments: ('M, unit) Syntax.t option }
                                      [@@deriving show]
                                    end
                                  module Param =
                                    struct
                                      type ('M, 'T) t = ('M * ('M, 'T) t')
                                      and ('M, 'T) t' =
                                        | RegularParam of
                                        {
                                        argument: ('M, 'T) Pattern.t ;
                                        default: ('M, 'T) Expression.t option }
                                        
                                        | ParamProperty of ('M, 'T)
                                        Class.Property.t' [@@deriving show]
                                    end
                                  module ThisParam =
                                    struct
                                      type ('M, 'T) t = ('M * ('M, 'T) t')
                                      and ('M, 'T) t' =
                                        {
                                        annot: ('M, 'T) Type.annotation ;
                                        comments: ('M, unit) Syntax.t option }
                                      [@@deriving show]
                                    end
                                  module Params =
                                    struct
                                      type ('M, 'T) t = ('M * ('M, 'T) t')
                                      and ('M, 'T) t' =
                                        {
                                        this_: ('M, 'T) ThisParam.t option ;
                                        params: ('M, 'T) Param.t list ;
                                        rest: ('M, 'T) RestParam.t option ;
                                        comments:
                                          ('M, 'M Comment.t list) Syntax.t
                                            option
                                          }[@@deriving show]
                                    end
                                  module ReturnAnnot =
                                    struct
                                      type ('M, 'T) t =
                                        | Missing of 'T 
                                        | Available of ('M, 'T)
                                        Type.annotation 
                                        | TypeGuard of ('M, 'T)
                                        Type.type_guard_annotation [@@deriving
                                                                    show]
                                    end
                                  type effect_ =
                                    | Hook 
                                    | Arbitrary [@@deriving show]
                                  type ('M, 'T) t =
                                    {
                                    id: ('M, 'T) Identifier.t option ;
                                    params: ('M, 'T) Params.t ;
                                    body: ('M, 'T) body ;
                                    async: bool ;
                                    generator: bool ;
                                    effect_: effect_ ;
                                    predicate:
                                      ('M, 'T) Type.Predicate.t option ;
                                    return: ('M, 'T) ReturnAnnot.t ;
                                    tparams:
                                      ('M, 'T) Type.TypeParams.t option ;
                                    comments: ('M, unit) Syntax.t option ;
                                    sig_loc: 'M }
                                  and ('M, 'T) body =
                                    | BodyBlock of ('M * ('M, 'T)
                                    Statement.Block.t) 
                                    | BodyExpression of ('M, 'T) Expression.t 
                                  [@@deriving show]
                                end and
                                     Program:sig
                                               type ('M, 'T) t =
                                                 ('M * ('M, 'T) t')
                                               and ('M, 'T) t' =
                                                 {
                                                 statements:
                                                   ('M, 'T) Statement.t list ;
                                                 interpreter:
                                                   ('M * string) option
                                                   [@ocaml.doc
                                                     " interpreter directive / shebang "];
                                                 comments:
                                                   ('M, unit) Syntax.t option ;
                                                 all_comments:
                                                   'M Comment.t list }
                                               [@@deriving show]
                                             end =
                                     struct
                                       type ('M, 'T) t = ('M * ('M, 'T) t')
                                       and ('M, 'T) t' =
                                         {
                                         statements:
                                           ('M, 'T) Statement.t list ;
                                         interpreter: ('M * string) option
                                           [@ocaml.doc
                                             " interpreter directive / shebang "];
                                         comments: ('M, unit) Syntax.t option ;
                                         all_comments: 'M Comment.t list }
                                       [@@deriving show]
                                     end
