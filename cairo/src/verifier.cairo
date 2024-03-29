use core::traits::Into;
use core::traits::Destruct;
use core::array::SpanTrait;
use ml_checker_cairo::pattern::PatternTrait;
use core::clone::Clone;
use core::box::BoxTrait;
use core::array::ArrayTrait;
use core::option::OptionTrait;
use debug::PrintTrait;
use ml_checker_cairo::pattern;
use ml_checker_cairo::term::Term;
use ml_checker_cairo::stack::{StackStructure, StackTrait, ClaimTrait};

use core::option::Option::{None, Some};

use pattern::Pattern;
use pattern::Pattern::{EVar, SVar, Symbol, Implies, App, Exists, Mu, MetaVar, ESubst, SSubst};
use pattern::{
    evar, svar, symbol, implies, app, exists, mu, metavar, metavar_unconstrained, metavar_e_fresh,
    metavar_s_fresh, esubst, ssubst, bot, not, forall
};
use pattern::{
    Id, IdList, ImpliesType, AppType, ExistsType, MuType, ESubstType, SSubstType, MetaVarType
};

use pattern::PatternOptionBoxClone;

const MAJOR_VERSION: u8 = 0;
const MINOR_VERSION: u8 = 1;

// Instructions
// ============
//
// Instructions are used to define the on-the-wire representation of matching
// logic proofs.

#[cairofmt::skip]
#[derive(Debug, Eq, PartialEq)]
enum Instruction {
    // Patterns
    EVar, SVar, Symbol, Implies, App, Exists, Mu,
    // Meta Patterns,
    MetaVar, ESubst, SSubst,
    // Axiom Schemas,
    Prop1, Prop2, Prop3, Quantifier, PropagationOr, PropagationExists,
    PreFixpoint, Existence, Singleton,
    // Inference rules,
    ModusPonens, Generalization, Framing, Substitution, KnasterTarski,
    // Meta Incference rules,
    Instantiate,
    // Stack Manipulation,
    Pop,
    // Memory Manipulation,
    Save,
    Load,
    // Journal Manipulation,
    Publish,
    // Version Control
    Version,
    // Metavar with no constraints
    CleanMetaVar,
    // NoOp to fill Cairo match requirements
    NoOp
}

type InstByte = u8;

#[derive(Debug, Eq, PartialEq)]
fn from(value: felt252) -> Instruction {
    match value {
        0 => Instruction::NoOp,
        1 => Instruction::NoOp,
        2 => Instruction::EVar,
        3 => Instruction::SVar,
        4 => Instruction::Symbol,
        5 => Instruction::Implies,
        6 => Instruction::App,
        7 => Instruction::Mu,
        8 => Instruction::Exists,
        9 => Instruction::MetaVar,
        10 => Instruction::ESubst,
        11 => Instruction::SSubst,
        12 => Instruction::Prop1,
        13 => Instruction::Prop2,
        14 => Instruction::Prop3,
        15 => Instruction::Quantifier,
        16 => Instruction::PropagationOr,
        17 => Instruction::PropagationExists,
        18 => Instruction::PreFixpoint,
        19 => Instruction::Existence,
        20 => Instruction::Singleton,
        21 => Instruction::ModusPonens,
        22 => Instruction::Generalization,
        23 => Instruction::Framing,
        24 => Instruction::Substitution,
        25 => Instruction::KnasterTarski,
        26 => Instruction::Instantiate,
        27 => Instruction::Pop,
        28 => Instruction::Save,
        29 => Instruction::Load,
        30 => Instruction::Publish,
        31 => Instruction::Version,
        32 => Instruction::NoOp,
        33 => Instruction::NoOp,
        34 => Instruction::NoOp,
        35 => Instruction::NoOp,
        36 => Instruction::NoOp,
        37 => Instruction::NoOp,
        38 => Instruction::NoOp,
        39 => Instruction::NoOp,
        40 => Instruction::NoOp,
        41 => Instruction::NoOp,
        42 => Instruction::NoOp,
        43 => Instruction::NoOp,
        44 => Instruction::NoOp,
        45 => Instruction::NoOp,
        46 => Instruction::NoOp,
        47 => Instruction::NoOp,
        48 => Instruction::NoOp,
        49 => Instruction::NoOp,
        50 => Instruction::NoOp,
        51 => Instruction::NoOp,
        52 => Instruction::NoOp,
        53 => Instruction::NoOp,
        54 => Instruction::NoOp,
        55 => Instruction::NoOp,
        56 => Instruction::NoOp,
        57 => Instruction::NoOp,
        58 => Instruction::NoOp,
        59 => Instruction::NoOp,
        60 => Instruction::NoOp,
        61 => Instruction::NoOp,
        62 => Instruction::NoOp,
        63 => Instruction::NoOp,
        64 => Instruction::NoOp,
        65 => Instruction::NoOp,
        66 => Instruction::NoOp,
        67 => Instruction::NoOp,
        68 => Instruction::NoOp,
        69 => Instruction::NoOp,
        70 => Instruction::NoOp,
        71 => Instruction::NoOp,
        72 => Instruction::NoOp,
        73 => Instruction::NoOp,
        74 => Instruction::NoOp,
        75 => Instruction::NoOp,
        76 => Instruction::NoOp,
        77 => Instruction::NoOp,
        78 => Instruction::NoOp,
        79 => Instruction::NoOp,
        80 => Instruction::NoOp,
        81 => Instruction::NoOp,
        82 => Instruction::NoOp,
        83 => Instruction::NoOp,
        84 => Instruction::NoOp,
        85 => Instruction::NoOp,
        86 => Instruction::NoOp,
        87 => Instruction::NoOp,
        88 => Instruction::NoOp,
        89 => Instruction::NoOp,
        90 => Instruction::NoOp,
        91 => Instruction::NoOp,
        92 => Instruction::NoOp,
        93 => Instruction::NoOp,
        94 => Instruction::NoOp,
        95 => Instruction::NoOp,
        96 => Instruction::NoOp,
        97 => Instruction::NoOp,
        98 => Instruction::NoOp,
        99 => Instruction::NoOp,
        100 => Instruction::NoOp,
        101 => Instruction::NoOp,
        102 => Instruction::NoOp,
        103 => Instruction::NoOp,
        104 => Instruction::NoOp,
        105 => Instruction::NoOp,
        106 => Instruction::NoOp,
        107 => Instruction::NoOp,
        108 => Instruction::NoOp,
        109 => Instruction::NoOp,
        110 => Instruction::NoOp,
        111 => Instruction::NoOp,
        112 => Instruction::NoOp,
        113 => Instruction::NoOp,
        114 => Instruction::NoOp,
        115 => Instruction::NoOp,
        116 => Instruction::NoOp,
        117 => Instruction::NoOp,
        118 => Instruction::NoOp,
        119 => Instruction::NoOp,
        120 => Instruction::NoOp,
        121 => Instruction::NoOp,
        122 => Instruction::NoOp,
        123 => Instruction::NoOp,
        124 => Instruction::NoOp,
        125 => Instruction::NoOp,
        126 => Instruction::NoOp,
        127 => Instruction::NoOp,
        128 => Instruction::NoOp,
        129 => Instruction::NoOp,
        130 => Instruction::NoOp,
        131 => Instruction::NoOp,
        132 => Instruction::NoOp,
        133 => Instruction::NoOp,
        134 => Instruction::NoOp,
        135 => Instruction::NoOp,
        136 => Instruction::NoOp,
        137 => Instruction::CleanMetaVar,
        _ => panic!("Bad Instruction!"),
    }
}

/// Substitution utilities
/// ----------------------

fn apply_esubst(pattern: @Pattern, evar_id: Id, plug: @Pattern) -> Pattern {
    let wrap_subst = esubst(pattern.clone(), evar_id, plug.clone());

    match pattern {
        Pattern::EVar(e) => { if *e == evar_id {
            plug.clone()
        } else {
            pattern.clone()
        } },
        Pattern::Implies(ImpliesType{left,
        right }) => {
            let left = left.clone().unwrap().unbox();
            let right = right.clone().unwrap().unbox();

            implies(apply_esubst(@left, evar_id, plug), apply_esubst(@right, evar_id, plug))
        },
        Pattern::App(AppType{left,
        right }) => {
            let left = left.clone().unwrap().unbox();
            let right = right.clone().unwrap().unbox();

            app(apply_esubst(@left, evar_id, plug), apply_esubst(@right, evar_id, plug))
        },
        Pattern::Exists(ExistsType{var,
        subpattern }) => {
            if *var == evar_id {
                pattern.clone()
            } else {
                if !plug.e_fresh(*var) {
                    panic!("EVar substitution would capture free variable {}!", *var);
                }

                let subpattern = subpattern.clone().unwrap().unbox();
                exists(*var, apply_esubst(@subpattern, evar_id, plug))
            }
        },
        Pattern::Mu(MuType{var,
        subpattern }) => {
            let subpattern = subpattern.clone().unwrap().unbox();
            mu(*var, apply_esubst(@subpattern, evar_id, plug))
        },
        Pattern::MetaVar(_) => wrap_subst,
        Pattern::ESubst(_) => wrap_subst,
        Pattern::SSubst(_) => wrap_subst,
        _ => pattern.clone(),
    }
}

fn apply_ssubst(pattern: @Pattern, svar_id: Id, plug: @Pattern) -> Pattern {
    let wrap_subst = ssubst(pattern.clone(), svar_id, plug.clone());

    match pattern {
        Pattern::SVar(s) => { if *s == svar_id {
            plug.clone()
        } else {
            pattern.clone()
        } },
        Pattern::Implies(ImpliesType{left,
        right }) => {
            let left = left.clone().unwrap().unbox();
            let right = right.clone().unwrap().unbox();

            implies(apply_ssubst(@left, svar_id, plug), apply_ssubst(@right, svar_id, plug))
        },
        Pattern::App(AppType{left,
        right }) => {
            let left = left.clone().unwrap().unbox();
            let right = right.clone().unwrap().unbox();

            app(apply_ssubst(@left, svar_id, plug), apply_ssubst(@right, svar_id, plug))
        },
        Pattern::Exists(ExistsType{var,
        subpattern }) => {
            let subpattern = subpattern.clone().unwrap().unbox();
            exists(*var, apply_ssubst(@subpattern, svar_id, plug))
        },
        Pattern::Mu(MuType{var,
        subpattern }) => {
            if *var == svar_id {
                pattern.clone()
            } else {
                if !plug.s_fresh(*var) {
                    panic!("SVar substitution would capture free variable {}!", *var);
                }

                let subpattern = subpattern.clone().unwrap().unbox();
                mu(*var, apply_ssubst(@subpattern, svar_id, plug))
            }
        },
        Pattern::MetaVar(_) => wrap_subst,
        Pattern::ESubst(_) => wrap_subst,
        Pattern::SSubst(_) => wrap_subst,
        _ => pattern.clone(),
    }
}

fn instantiate_internal(
    ref p: Pattern, ref vars: IdList, ref plugs: Array<Pattern>,
) -> Option<Pattern> {
    match p.clone() {
        Pattern::EVar(_) => Option::None,
        Pattern::SVar(_) => Option::None,
        Pattern::Symbol(_) => Option::None,
        Pattern::Implies(ImpliesType{left,
        right }) => {
            let mut left = left.unwrap().unbox();
            let mut right = right.unwrap().unbox();

            let mut inst_left = instantiate_internal(ref left, ref vars, ref plugs);
            let mut inst_right = instantiate_internal(ref right, ref vars, ref plugs);

            if inst_left.is_none() && inst_right.is_none() {
                return Option::None;
            } else {
                if inst_left.is_none() {
                    inst_left = Option::Some(left.clone());
                }
                if inst_right.is_none() {
                    inst_right = Option::Some(right.clone());
                }
                return Option::Some(implies(inst_left.unwrap(), inst_right.unwrap()));
            }
        },
        Pattern::App(AppType{left,
        right }) => {
            let mut left = left.unwrap().unbox();
            let mut right = right.unwrap().unbox();

            let mut inst_left = instantiate_internal(ref left, ref vars, ref plugs);
            let mut inst_right = instantiate_internal(ref right, ref vars, ref plugs);

            if inst_left.is_none() && inst_right.is_none() {
                return Option::None;
            } else {
                if inst_left.is_none() {
                    inst_left = Option::Some(left.clone());
                }
                if inst_right.is_none() {
                    inst_right = Option::Some(right.clone());
                }
                return Option::Some(app(inst_left.unwrap(), inst_right.unwrap()));
            }
        },
        Pattern::Exists(ExistsType{var,
        subpattern }) => {
            let mut subpattern = subpattern.unwrap().unbox();

            let mut new_sub = instantiate_internal(ref subpattern, ref vars, ref plugs);

            if new_sub.is_none() {
                Option::None
            } else {
                Option::Some(exists(var, new_sub.unwrap()))
            }
        },
        Pattern::Mu(MuType{var,
        subpattern }) => {
            let mut subpattern = subpattern.unwrap().unbox();

            let mut new_sub = instantiate_internal(ref subpattern, ref vars, ref plugs);

            if new_sub.is_none() {
                Option::None
            } else {
                Option::Some(mu(var, new_sub.unwrap()))
            }
        },
        Pattern::MetaVar(MetaVarType{id,
        e_fresh,
        s_fresh,
        positive,
        negative,
        app_ctx_holes, }) => {
            let mut pos: u32 = 0;
            let mut e_fresh = e_fresh.clone();
            let mut s_fresh = s_fresh.clone();
            let mut negative = negative.clone();
            let mut positive = positive.clone();
            let mut app_ctx_holes = app_ctx_holes.clone();
            let mut ret: Option<Pattern> = Option::None;
            let plugs_as_ref: @Array<Pattern> = @plugs;
            let mut vars_clone = vars.clone();
            loop {
                match vars_clone.pop_front() {
                    Option::Some(var) => {
                        if var == id {
                            loop {
                                match e_fresh.pop_front() {
                                    Option::Some(evar) => {
                                        let plug: @Pattern = plugs_as_ref.at(pos);
                                        if !plug.e_fresh(evar) {
                                            panic!(
                                                "Instantiation of MetaVar {} breaks a freshness constraint: EVar {}",
                                                id,
                                                evar
                                            );
                                        }
                                    },
                                    Option::None => { break; }
                                }
                            };

                            loop {
                                match s_fresh.pop_front() {
                                    Option::Some(svar) => {
                                        let plug: @Pattern = plugs_as_ref.at(pos);
                                        if !plug.s_fresh(svar) {
                                            panic!(
                                                "Instantiation of MetaVar {} breaks a freshness constraint: SVar {}",
                                                id,
                                                svar
                                            );
                                        }
                                    },
                                    Option::None => { break; }
                                }
                            };

                            loop {
                                match positive.pop_front() {
                                    Option::Some(svar) => {
                                        let plug: @Pattern = plugs_as_ref.at(pos);
                                        if !plug.positive(svar) {
                                            panic!(
                                                "Instantiation of MetaVar {} breaks a positivity constraint: SVar {:?}",
                                                id,
                                                svar
                                            );
                                        }
                                    },
                                    Option::None => { break; }
                                }
                            };

                            loop {
                                match negative.pop_front() {
                                    Option::Some(svar) => {
                                        let plug: @Pattern = plugs_as_ref.at(pos);
                                        if !plug.negative(svar) {
                                            panic!(
                                                "Instantiation of MetaVar {} breaks a negativity constraint: SVar {:?}",
                                                id,
                                                svar
                                            );
                                        }
                                    },
                                    Option::None => { break; }
                                }
                            };

                            loop {
                                match app_ctx_holes.pop_front() {
                                    Option::Some(evar) => {
                                        let plug: @Pattern = plugs_as_ref.at(pos);
                                        if !plug.app_ctx_hole(evar) {
                                            panic!(
                                                "Instantiation of MetaVar {} breaks an application context hole constraint: EVar {}",
                                                id,
                                                evar
                                            );
                                        }
                                    },
                                    Option::None => { break; }
                                }
                            };

                            if pos >= plugs_as_ref.len() {
                                panic!("Substitution does not contain a corresponding value.")
                            }

                            ret = Option::Some(plugs_as_ref.at(pos).clone());
                            break;
                        }
                        pos += 1;
                    },
                    Option::None => { break; }
                }
            };
            return ret;
        },
        Pattern::ESubst(ESubstType{pattern,
        evar_id,
        plug }) => {
            let mut pattern = pattern.unwrap().unbox();
            let mut plug = plug.unwrap().unbox();

            let mut inst_pattern = instantiate_internal(ref pattern, ref vars, ref plugs);
            let mut inst_plug = instantiate_internal(ref plug, ref vars, ref plugs);

            if inst_pattern.is_none() && inst_plug.is_none() {
                return Option::None;
            } else {
                if inst_pattern.is_none() {
                    inst_pattern = Option::Some(pattern.clone());
                }
                if inst_plug.is_none() {
                    inst_plug = Option::Some(plug.clone());
                }

                return Option::Some(
                    apply_esubst(@inst_pattern.unwrap(), evar_id, @inst_plug.unwrap())
                );
            }
        },
        Pattern::SSubst(SSubstType{pattern,
        svar_id,
        plug }) => {
            let mut pattern = pattern.unwrap().unbox();
            let mut plug = plug.unwrap().unbox();

            let mut inst_pattern = instantiate_internal(ref pattern, ref vars, ref plugs);
            let mut inst_plug = instantiate_internal(ref plug, ref vars, ref plugs);

            if inst_pattern.is_none() && inst_plug.is_none() {
                return Option::None;
            } else {
                if inst_pattern.is_none() {
                    inst_pattern = Option::Some(pattern.clone());
                }
                if inst_plug.is_none() {
                    inst_plug = Option::Some(plug.clone());
                }

                return Option::Some(
                    apply_ssubst(@inst_pattern.unwrap(), svar_id, @inst_plug.unwrap())
                );
            }
        },
    }
}

fn instantiate_in_place(ref p: Pattern, ref ids: IdList, ref plugs: Array<Pattern>) {
    let option_ret = instantiate_internal(ref p, ref ids, ref plugs);
    match option_ret {
        Option::Some(ret) => { p = ret; },
        Option::None => { panic!("Instantiation failed!"); },
    }
}

/// Proof checker
/// =============

type Stack = StackStructure<Term>;
type Claims = StackStructure<Pattern>;
type Memory = Array<Term>;

/// Stack manipulation
/// ------------------
#[inline(always)]
fn pop_stack(ref stack: Stack) -> Term {
    return stack.pop();
}

fn pop_stack_pattern(ref stack: Stack) -> Pattern {
    let term = pop_stack(ref stack);
    match term {
        Term::Pattern(pat) => { return pat; },
        Term::Proved(_) => panic!("Expected pattern on stack."),
    }
}

fn pop_stack_proved(ref stack: Stack) -> Pattern {
    let term = pop_stack(ref stack);
    match term {
        Term::Pattern(_) => panic!("Expected proved on stack."),
        Term::Proved(pat) => { return pat; },
    }
}

/// Main implementation
/// -------------------

#[derive(Drop, Copy)]
enum ExecutionPhase {
    Gamma,
    Claim,
    Proof,
}

fn read_u8_vec(ref buffer: Array<u8>) -> Array<u8> {
    let mut result = array![];
    let mut i = 0;
    let len: u8 = buffer.pop_front().expect('Expected length for array');
    loop {
        if i == len {
            break;
        }
        result.append(buffer.pop_front().unwrap());
        i += 1;
    };
    return result;
}

fn execute_instructions(
    mut buffer: Array<u8>,
    ref stack: Stack,
    ref memory: Memory,
    ref claims: Claims,
    phase: ExecutionPhase,
) {
    // Metavars
    let phi0 = metavar_unconstrained(0);
    let phi1 = metavar_unconstrained(1);
    let phi2 = metavar_unconstrained(2);

    // Axioms
    let prop1 = implies(phi0.clone(), implies(phi1.clone(), phi0.clone()));

    let prop2 = implies(
        implies(phi0.clone(), implies(phi1.clone(), phi2.clone())),
        implies(implies(phi0.clone(), phi1), implies(phi0.clone(), phi2))
    );
    let prop3 = implies(not(not(phi0.clone())), phi0.clone());
    let quantifier = implies(esubst(phi0.clone(), 0, evar(1)), exists(0, phi0));

    let existence = exists(0, evar(0));

    // For enums we must implement all cases to make match works
    loop {
        match (buffer.pop_front()) {
            Some(inst) => {
                let inst_felt252 = U8IntoFelt252::into(inst);
                match from(inst_felt252) {
                    Instruction::EVar => {
                        let id = buffer.pop_front().expect('Expected id for the EVar').into();
                        stack.push(Term::Pattern(evar(id)));
                    },
                    Instruction::SVar => {
                        let id = buffer.pop_front().expect('Expected id for the SVar').into();
                        stack.push(Term::Pattern(svar(id)));
                    },
                    Instruction::Symbol => {
                        let id = buffer.pop_front().expect('Expected id for the Symbol').into();
                        stack.push(Term::Pattern(symbol(id)));
                    },
                    Instruction::Implies => {
                        let right = pop_stack_pattern(ref stack);
                        let left = pop_stack_pattern(ref stack);
                        stack.push(Term::Pattern(implies(left, right)));
                    },
                    Instruction::App => {
                        let right = pop_stack_pattern(ref stack);
                        let left = pop_stack_pattern(ref stack);
                        stack.push(Term::Pattern(app(left, right)));
                    },
                    Instruction::Exists => {
                        let id = buffer.pop_front().expect('Expected var_id for the Exists').into();
                        let subpattern = pop_stack_pattern(ref stack);
                        stack.push(Term::Pattern(exists(id, subpattern)))
                    },
                    Instruction::Mu => {
                        let id = buffer.pop_front().expect('Expected var_id for the Mu').into();
                        let subpattern = pop_stack_pattern(ref stack);

                        let mu_pat = mu(id, subpattern);
                        if !mu_pat.well_formed() {
                            panic!("Constructed mu-pattern {:?} is ill-formed", mu_pat);
                        }

                        stack.push(Term::Pattern(mu_pat))
                    },
                    Instruction::MetaVar => {
                        let id = buffer.pop_front().expect('Expected id for the MetaVar').into();
                        let e_fresh = read_u8_vec(ref buffer);
                        let s_fresh = read_u8_vec(ref buffer);
                        let positive = read_u8_vec(ref buffer);
                        let negative = read_u8_vec(ref buffer);
                        let app_ctx_holes = read_u8_vec(ref buffer);

                        let metavar_pat = metavar(
                            id, e_fresh, s_fresh, positive, negative, app_ctx_holes
                        );
                        if !metavar_pat.well_formed() {
                            panic!("Constructed meta-var {:?} is ill-formed.", metavar_pat);
                        }

                        stack.push(Term::Pattern(metavar_pat));
                    },
                    Instruction::ESubst => {
                        let evar_id = buffer
                            .pop_front()
                            .expect('Insufficient params for ESubst')
                            .into();
                        let pattern = pop_stack_pattern(ref stack);
                        let plug = pop_stack_pattern(ref stack);

                        let esubst_pat = esubst(pattern, evar_id, plug);
                        if !esubst_pat.well_formed() {
                            panic!("Creating an ill-formed esubst {:?}", esubst_pat);
                        }

                        stack.push(Term::Pattern(esubst_pat));
                    },
                    Instruction::SSubst => {
                        let svar_id = buffer
                            .pop_front()
                            .expect('Insufficient params for SSubst')
                            .into();
                        let pattern = pop_stack_pattern(ref stack);
                        let plug = pop_stack_pattern(ref stack);

                        let ssubst_pat = ssubst(pattern, svar_id, plug);
                        if !ssubst_pat.well_formed() {
                            panic!("Creating an ill-formed ssubst {:?}", ssubst_pat);
                        }

                        stack.push(Term::Pattern(ssubst_pat));
                    },
                    Instruction::Prop1 => stack.push(Term::Proved(prop1.clone())),
                    Instruction::Prop2 => stack.push(Term::Proved(prop2.clone())),
                    Instruction::Prop3 => stack.push(Term::Proved(prop3.clone())),
                    Instruction::Quantifier => stack.push(Term::Proved(quantifier.clone())),
                    Instruction::Existence => stack.push(Term::Proved(existence.clone())),
                    Instruction::ModusPonens => {
                        let premise2 = pop_stack_proved(ref stack);
                        let premise1: Pattern = pop_stack_proved(ref stack);
                        match premise1 {
                            Pattern::Implies(ImpliesType{left,
                            right }) => {
                                let left = left.unwrap().unbox();
                                if left != premise2 {
                                    panic!(
                                        "Antecedents do not match for modus ponens.\nleft.psi:\n{:?}\n\n right:\n{:?}\n",
                                        left,
                                        premise2
                                    );
                                }
                                stack.push(Term::Proved(right.unwrap().unbox().clone()))
                            },
                            _ => { panic!("Expected an implication as a first parameter."); }
                        };
                    },
                    Instruction::Generalization => {
                        match pop_stack_proved(ref stack) {
                            Pattern::Implies(ImpliesType{left,
                            right }) => {
                                let evar_id = buffer
                                    .pop_front()
                                    .expect('Insufficient params General')
                                    .into();

                                let left = left.unwrap().unbox();
                                let right = right.unwrap().unbox();
                                if !right.e_fresh(evar_id) {
                                    panic!("The binding variable has to be fresh.");
                                }

                                stack
                                    .push(
                                        Term::Proved(
                                            implies(exists(evar_id, left.clone()), right.clone())
                                        )
                                    );
                            },
                            _ => { panic!("Expected an implication as a first parameter."); }
                        };
                    },
                    Instruction::Substitution => {
                        let svar_id = buffer.pop_front().expect('Insufficient params Subst').into();
                        let pattern = pop_stack_proved(ref stack);
                        let plug = pop_stack_pattern(ref stack);

                        stack.push(Term::Proved(apply_ssubst(@pattern, svar_id, @plug)));
                    },
                    Instruction::Instantiate => {
                        let n: u8 = buffer.pop_front().expect('Insufficient parms Instantiate');
                        let mut ids: IdList = ArrayTrait::new();
                        let mut plugs: Array<Pattern> = ArrayTrait::new();

                        let metaterm = pop_stack(ref stack);

                        let mut i = 0;
                        loop {
                            if i == n {
                                break;
                            }
                            ids
                                .append(
                                    buffer.pop_front().expect('Expected id for Instantiate').into()
                                );
                            plugs.append(pop_stack_pattern(ref stack));
                            i += 1;
                        };

                        match metaterm {
                            Term::Pattern(mut p) => {
                                instantiate_in_place(ref p, ref ids, ref plugs);
                                stack.push(Term::Pattern(p));
                            },
                            Term::Proved(mut p) => {
                                instantiate_in_place(ref p, ref ids, ref plugs);
                                stack.push(Term::Proved(p));
                            }
                        }
                    },
                    Instruction::Pop => { let _ = pop_stack(ref stack); },
                    Instruction::Save => memory
                        .append(stack.last().expect('Save needs term on the stack').clone()),
                    Instruction::Load => {
                        let index: u32 = buffer
                            .pop_front()
                            .expect('Error on Load instruction')
                            .into();
                        stack
                            .push(
                                memory
                                    .get(index)
                                    .expect('Load needs term on Memory')
                                    .unbox()
                                    .clone()
                            );
                    },
                    Instruction::Publish => match phase {
                        ExecutionPhase::Gamma => memory
                            .append(Term::Proved(pop_stack_pattern(ref stack))),
                        ExecutionPhase::Claim => {
                            let claim = pop_stack_pattern(ref stack);
                            claims.push(claim)
                        },
                        ExecutionPhase::Proof => {
                            let claim = claims.pop();
                            let theorem = pop_stack_proved(ref stack);
                            // Missing PartialEq for Terms and Pattern
                            if claim != theorem {
                                panic!(
                                    "This proof does not prove the requested claim: {:?}, theorem: {:?}",
                                    claim,
                                    theorem
                                );
                            }
                        },
                    },
                    Instruction::Version => {
                        let major = buffer.pop_front().expect('Expected major version').into();
                        let minor = buffer.pop_front().expect('Expected minor version').into();
                        if major != MAJOR_VERSION || minor != MINOR_VERSION {
                            panic!(
                                "Version mismatch: expected {}.{} but got {}.{}",
                                MAJOR_VERSION,
                                MINOR_VERSION,
                                major,
                                minor
                            );
                        }
                    },
                    Instruction::CleanMetaVar => {
                        let id = buffer.pop_front().expect('Expected id for MetaVar').into();

                        let metavar_pat = metavar_unconstrained(id);

                        // Clean metavars are always well-formed
                        stack.push(Term::Pattern(metavar_pat));
                    },
                    _ => { panic!("Instruction: {} not implemented!", inst_felt252); },
                }
            },
            Option::None => { break; }
        }
    }
}

fn verify(
    gamma_buffer: Array<InstByte>, claims_buffer: Array<InstByte>, proof_buffer: Array<InstByte>
) {
    let mut stack: Stack = StackTrait::new();
    let mut memory: Memory = array![];
    let mut claims: Claims = ClaimTrait::new();
    'Executing Gamma phase'.print();
    execute_instructions(
        gamma_buffer,
        ref stack, // stack is empty initially.
        ref memory, // memory is empty initially.
        ref claims, // claims is unused in this phase.
        ExecutionPhase::Gamma
    );

    stack.clear();

    'Executing Claim phase'.print();
    execute_instructions(
        claims_buffer,
        ref stack, // stack is empty initially.
        ref memory, // reuse memory.
        ref claims, // claims populated in this phase.
        ExecutionPhase::Claim
    );

    stack.clear();

    'Executing Proof phase'.print();
    execute_instructions(
        proof_buffer,
        ref stack, // stack is empty initially.
        ref memory, // axioms are used as initial memory.
        ref claims, // claims are consumed by publish instruction.
        ExecutionPhase::Proof
    );

    assert(claims.is_empty(), 'Claims should be empty!');
}

// Unit tests module
#[cfg(test)]
mod tests {
    use core::clone::Clone;
    use core::traits::Into;
    use core::box::BoxTrait;
    use core::option::OptionTrait;
    use core::array::ArrayTrait;
    use super::verify;

    #[test]
    #[available_gas(1000000000000000)]
    fn it_works() {
        let mut gamma = array![];
        let mut claims = array![];
        let mut proofs = array![];

        verify(gamma, claims, proofs);
    }

    use super::StackTrait;
    use super::Term;
    use super::bot;
    use super::Stack;
    #[test]
    #[available_gas(1000000000000000)]
    fn test_stack_push() {
        let mut stack: Stack = StackTrait::new();
        let term = Term::Pattern(bot());
        stack.push(term);
        assert(stack.len() == 1, 'Hmm.. stack_size should be 1!');
    }

    use super::pop_stack;
    #[test]
    #[available_gas(1000000000000000)]
    fn test_stack_pop() {
        let mut stack: Stack = StackTrait::new();
        let term = Term::Pattern(bot());
        stack.push(term.clone());
        let pop_term = pop_stack(ref stack);
        assert(stack.is_empty(), 'Hmm.. stack_size should be 0!');
        assert(pop_term == term, 'Hmm.. pop_term should be term!');
    }

    use super::pop_stack_pattern;
    #[test]
    #[available_gas(1000000000000000)]
    fn test_stack_pop_pattern() {
        let mut stack: Stack = StackTrait::new();
        let pat = bot();
        stack.push(Term::Pattern(pat.clone()));
        let pop_term = pop_stack_pattern(ref stack);
        assert(stack.is_empty(), 'Hmm.. stack_size should be 0!');
        // This test ins't possible yet because of the lack of equality
        assert(pop_term == pat, 'Hmm.. pop_term should be term!');
    }

    use super::pop_stack_proved;
    #[test]
    #[available_gas(1000000000000000)]
    fn test_stack_pop_proved() {
        let mut stack: Stack = StackTrait::new();
        let pat = bot();
        stack.push(Term::Proved(pat.clone()));
        let pop_term = pop_stack_proved(ref stack);
        assert(stack.is_empty(), 'Hmm.. stack_size should be 0!');
        // This test ins't possible yet because of the lack of equality
        assert(pop_term == pat, 'Hmm.. pop_term should be term!');
    }

    use super::read_u8_vec;
    #[test]
    #[available_gas(1000000000000000)]
    fn test_read_u8_vec() {
        let mut buffer = array![];
        buffer.append(3);
        buffer.append(1);
        buffer.append(2);
        buffer.append(3);
        let result = read_u8_vec(ref buffer);
        assert(result.len() == 3, 'Hmm this should have length 3!');
    }

    use super::implies;
    use super::metavar_unconstrained;
    use super::InstByte;
    use super::Instruction;
    use super::execute_instructions;
    use super::ExecutionPhase;
    use super::ClaimTrait;
    use super::Memory;
    use super::Claims;
    #[test]
    #[available_gas(1000000000000000)]
    fn test_save_and_load() {
        #[cairofmt::skip]
        let proof: Array<InstByte> = array![
            137, // CleanMetaVar
            0,
            28, // Save
        ];

        let mut stack: Stack = StackTrait::new();
        let mut memory: Memory = array![];
        let mut claims: Claims = ClaimTrait::new();

        let phi = metavar_unconstrained(0);

        execute_instructions(proof, ref stack, ref memory, ref claims, ExecutionPhase::Gamma);
        let mut pattern_phi: Term = memory.get(0).expect('Expected memory element').unbox().clone();
        assert(pattern_phi == Term::Pattern(phi.clone()), 'Expect pattern::phi');
        execute_instructions(
            array![29, 0], ref stack, ref memory, ref claims, ExecutionPhase::Gamma
        );
        pattern_phi = stack.pop();
        assert(pattern_phi == Term::Pattern(phi.clone()), 'Expect pattern::phi');
    }

    #[test]
    #[available_gas(1000000000000000)]
    fn test_pattern_construction() {
        #[cairofmt::skip]
        let instructions: Array<InstByte> = array![
            3, // Svar
            0,
            137, // CleanMetaVar
            0,
            10, // ESubst
            0
        ];

        let mut stack = StackTrait::new();
        let mut memory = array![];
        let mut claims = ClaimTrait::new();
        execute_instructions(
            instructions, ref stack, ref memory, ref claims, ExecutionPhase::Gamma,
        );
        assert_eq!(stack.len(), 1);
        assert_eq!(stack.pop(), Term::Pattern(esubst(metavar_unconstrained(0), 0, svar(0))));
    }

    #[test]
    #[should_panic]
    #[available_gas(1000000000000000)]
    fn test_pop_instruction() {
        let instructions = array![27];
        let mut stack = StackTrait::new();
        let mut memory = array![];
        let mut claims = ClaimTrait::new();
        execute_instructions(
            instructions, ref stack, ref memory, ref claims, ExecutionPhase::Gamma,
        );
    }

    use super::metavar_s_fresh;
    #[test]
    #[should_panic]
    #[available_gas(1000000000000000)]
    fn test_instantiate_fresh() {
        let svar_0 = svar(0);
        let mut phi0_s_fresh_0 = metavar_s_fresh(0, 0, array![0], array![0]);
        let mut vars = array![0];
        let mut plugs = array![svar_0];
        let _ = instantiate_internal(ref phi0_s_fresh_0, ref vars, ref plugs);
    }

    use core::option::Option::{Some, None};
    use super::evar;
    use super::instantiate_internal;
    use super::Pattern;
    #[test]
    #[available_gas(1000000000000000)]
    fn test_instantiate() {
        let mut x0 = evar(0);
        let mut xs0 = svar(0);
        let mut c0 = symbol(0);
        let mut x0_implies_x0 = implies(x0.clone(), x0.clone());
        let mut appx0x0 = app(x0.clone(), x0.clone());
        let mut existsx0x0 = exists(0, x0.clone());
        let mut mux0x0 = mu(0, x0.clone());

        let option_none: Option<Pattern> = Option::None;
        let mut array_0 = array![0];
        let mut array_1 = array![1];
        let mut array_x0 = array![x0.clone()];
        let mut array_xs0 = array![xs0.clone()];

        // Concrete patterns are unaffected by instantiate
        assert_eq!(instantiate_internal(ref x0, ref array_0, ref array_xs0), option_none);
        assert_eq!(instantiate_internal(ref x0, ref array_1, ref array_xs0), option_none);
        assert_eq!(instantiate_internal(ref xs0, ref array_0, ref array_x0), option_none);
        assert_eq!(instantiate_internal(ref xs0, ref array_1, ref array_x0), option_none);
        assert_eq!(instantiate_internal(ref c0, ref array_0, ref array_x0), option_none);
        assert_eq!(instantiate_internal(ref c0, ref array_1, ref array_x0), option_none);
        assert_eq!(instantiate_internal(ref x0_implies_x0, ref array_0, ref array_x0), option_none);
        assert_eq!(instantiate_internal(ref x0_implies_x0, ref array_1, ref array_x0), option_none);
        assert_eq!(instantiate_internal(ref appx0x0, ref array_0, ref array_x0), option_none);
        assert_eq!(instantiate_internal(ref appx0x0, ref array_1, ref array_x0), option_none);
        assert_eq!(instantiate_internal(ref existsx0x0, ref array_0, ref array_xs0), option_none);
        assert_eq!(instantiate_internal(ref existsx0x0, ref array_1, ref array_xs0), option_none);
        assert_eq!(instantiate_internal(ref mux0x0, ref array_0, ref array_x0), option_none);
        assert_eq!(instantiate_internal(ref mux0x0, ref array_1, ref array_x0), option_none);

        let mut phi0 = metavar_unconstrained(0);
        let mut phi0_implies_phi0 = implies(phi0.clone(), phi0.clone());
        let mut appphi0phi0 = app(phi0.clone(), phi0.clone());
        let mut existsx0phi0 = exists(0, phi0.clone());
        let mut mux0phi0 = mu(0, phi0.clone());
        let mut existsx0xs0 = exists(0, xs0.clone());

        assert_eq!(
            instantiate_internal(ref phi0_implies_phi0, ref array_0, ref array_x0),
            Option::Some(x0_implies_x0.clone())
        );

        assert_eq!(
            instantiate_internal(ref phi0_implies_phi0, ref array_1, ref array_x0), option_none
        );
        assert_eq!(
            instantiate_internal(ref appphi0phi0, ref array_0, ref array_x0),
            Option::Some(appx0x0.clone())
        );
        assert_eq!(instantiate_internal(ref appphi0phi0, ref array_1, ref array_x0), option_none);
        assert_eq!(
            instantiate_internal(ref existsx0phi0, ref array_0, ref array_x0),
            Option::Some(existsx0x0.clone())
        );
        assert_eq!(instantiate_internal(ref existsx0phi0, ref array_1, ref array_x0), option_none);
        assert_eq!(
            instantiate_internal(ref mux0phi0, ref array_0, ref array_x0),
            Option::Some(mux0x0.clone())
        );
        assert_eq!(instantiate_internal(ref mux0phi0, ref array_1, ref array_x0), option_none);

        // Simultaneous instantiations
        let mut phi1 = metavar_unconstrained(1);
        let mut mux0phi1 = mu(0, phi1.clone());
        let mut mux0xs0 = mu(0, xs0.clone());
        let mut array_12 = array![1, 2];
        let mut array_21 = array![2, 1];
        let mut array_x0xs0 = array![x0.clone(), xs0.clone()];
        // Empty substs have no effect
        assert_eq!(
            instantiate_internal(ref existsx0phi0, ref array_12, ref array_x0xs0), option_none
        );
        assert_eq!(
            instantiate_internal(ref existsx0phi0, ref array_21, ref array_x0xs0), option_none
        );
        assert_eq!(instantiate_internal(ref mux0phi0, ref array_12, ref array_x0xs0), option_none);
        assert_eq!(instantiate_internal(ref mux0phi0, ref array_21, ref array_x0xs0), option_none);

        // Order matters if corresponding value is not moved
        let mut array_01 = array![0, 1];
        let mut array_10 = array![1, 0];
        assert_eq!(
            instantiate_internal(ref existsx0phi0, ref array_10, ref array_x0xs0),
            Option::Some(existsx0xs0.clone())
        );
        assert_eq!(
            instantiate_internal(ref existsx0phi0, ref array_01, ref array_x0xs0),
            Option::Some(existsx0x0.clone())
        );
        assert_eq!(
            instantiate_internal(ref mux0phi0, ref array_10, ref array_x0xs0),
            Option::Some(mux0xs0.clone())
        );
        assert_eq!(
            instantiate_internal(ref mux0phi0, ref array_01, ref array_x0xs0),
            Option::Some(mux0x0.clone())
        );

        // Order does not matter if corresponding value is moved
        let mut mux0phi0_implies_ph1 = implies(mux0phi0.clone(), phi1.clone());
        let mut mux0x0_implies_xs0 = implies(mux0x0.clone(), xs0.clone());
        let mut array_xs0x0 = array![xs0.clone(), x0.clone()];
        assert_eq!(
            instantiate_internal(ref mux0phi0_implies_ph1, ref array_01, ref array_x0xs0),
            Option::Some(mux0x0_implies_xs0.clone())
        );
        assert_eq!(
            instantiate_internal(ref mux0phi0_implies_ph1, ref array_10, ref array_xs0x0),
            Option::Some(mux0x0_implies_xs0.clone())
        );
        let mut mux0phi0_app_ph1 = app(mux0phi0.clone(), phi1.clone());
        let mut mux0x0_app_xs0 = app(mux0x0.clone(), xs0.clone());

        assert_eq!(
            instantiate_internal(ref mux0phi0_app_ph1, ref array_01, ref array_x0xs0),
            Option::Some(mux0x0_app_xs0.clone())
        );
        assert_eq!(
            instantiate_internal(ref mux0phi0_app_ph1, ref array_10, ref array_xs0x0),
            Option::Some(mux0x0_app_xs0.clone())
        );

        // No side-effects
        let mut mux0ph1_implies_xs0 = implies(mux0phi1.clone(), xs0.clone());
        let mut array_phi1xs0 = array![phi1.clone(), xs0.clone()];
        let mut array_xs0phi1 = array![xs0.clone(), phi1.clone()];
        assert_eq!(
            instantiate_internal(ref mux0phi0_implies_ph1, ref array_01, ref array_phi1xs0),
            Option::Some(mux0ph1_implies_xs0.clone())
        );
        assert_eq!(
            instantiate_internal(ref mux0phi0_implies_ph1, ref array_10, ref array_xs0phi1),
            Option::Some(mux0ph1_implies_xs0.clone())
        );
        let mux0ph1_app_xs0 = app(mux0phi1.clone(), xs0.clone());
        assert_eq!(
            instantiate_internal(ref mux0phi0_app_ph1, ref array_01, ref array_phi1xs0),
            Option::Some(mux0ph1_app_xs0.clone())
        );
        assert_eq!(
            instantiate_internal(ref mux0phi0_app_ph1, ref array_10, ref array_xs0phi1),
            Option::Some(mux0ph1_app_xs0.clone())
        );

        let mut array_011 = array![0, 1, 1];
        let mut array_100 = array![1, 0, 0];
        let mut array_phi1xs0x0 = array![phi1.clone(), xs0.clone(), x0.clone()];
        let mut array_xs0phi1x0 = array![xs0.clone(), phi1.clone(), x0.clone()];
        // First comes first
        assert_eq!(
            instantiate_internal(ref mux0phi0_app_ph1, ref array_011, ref array_phi1xs0x0),
            Option::Some(mux0ph1_app_xs0.clone())
        );
        assert_eq!(
            instantiate_internal(ref mux0phi0_app_ph1, ref array_100, ref array_xs0phi1x0),
            Option::Some(mux0ph1_app_xs0.clone())
        );

        // Extra values are ignored
        let mut array_phi1xs0x0duplicate = array![
            phi1.clone(),
            xs0.clone(),
            x0.clone(),
            x0.clone(),
            x0.clone(),
            x0.clone(),
            x0.clone(),
            x0.clone()
        ];
        let mut array_012 = array![0, 1, 2];
        assert_eq!(
            instantiate_internal(ref mux0phi0_app_ph1, ref array_011, ref array_phi1xs0x0duplicate),
            Option::Some(mux0ph1_app_xs0.clone())
        );
        assert_eq!(
            instantiate_internal(ref mux0phi0_app_ph1, ref array_012, ref array_phi1xs0),
            Option::Some(mux0ph1_app_xs0.clone())
        );

        // Instantiate with concrete patterns applies pending substitutions
        let mut val = esubst(phi0.clone(), 0, c0.clone());
        assert_eq!(
            instantiate_internal(ref val, ref array_0, ref array_x0), Option::Some(c0.clone())
        );
        let mut val = ssubst(phi0.clone(), 0, c0.clone());
        assert_eq!(
            instantiate_internal(ref val, ref array_0, ref array_xs0), Option::Some(c0.clone())
        );
        let mut val = ssubst(esubst(phi0.clone(), 0, xs0.clone()), 0, c0.clone());
        assert_eq!(
            instantiate_internal(ref val, ref array_0, ref array_xs0), Option::Some(c0.clone())
        );

        // Instantiate with metavar keeps pending substitutions
        let mut val = esubst(phi0.clone(), 0, c0.clone());
        let mut array_phi1 = array![phi1.clone()];
        assert_eq!(
            instantiate_internal(ref val, ref array_0, ref array_phi1),
            Option::Some(esubst(phi1.clone(), 0, c0.clone()))
        );
        let mut val = ssubst(phi0.clone(), 0, c0.clone());
        assert_eq!(
            instantiate_internal(ref val, ref array_0, ref array_phi1),
            Option::Some(ssubst(phi1.clone(), 0, c0.clone()))
        );

        // The plug in a subst. needs to be instantiated as well
        let mut val = ssubst(phi0.clone(), 0, phi0.clone());
        assert_eq!(
            instantiate_internal(ref val, ref array_0, ref array_xs0), Option::Some(xs0.clone())
        );
        let mut val = ssubst(phi0.clone(), 0, phi1.clone());
        let mut array_xs0c0 = array![xs0.clone(), c0.clone()];
        assert_eq!(
            instantiate_internal(ref val, ref array_01, ref array_xs0c0), Option::Some(c0.clone())
        );
    }

    use super::metavar;
    #[test]
    #[should_panic]
    #[available_gas(1000000000000000)]
    fn test_instantiation_breaking_constraints1() {
        let mut pattern = metavar(0, array![0], array![], array![], array![], array![]);
        let mut vars = array![0];
        let mut plugs = array![evar(0)];
        let _ = instantiate_internal(ref pattern, ref vars, ref plugs);
    }

    #[test]
    #[should_panic]
    #[available_gas(1000000000000000)]
    fn test_instantiation_breaking_constraints2() {
        let mut pattern = metavar(0, array![], array![0], array![], array![], array![]);
        let mut vars = array![0];
        let mut plugs = array![svar(0)];
        let _ = instantiate_internal(ref pattern, ref vars, ref plugs);
    }

    use super::not;
    #[test]
    #[should_panic]
    #[available_gas(1000000000000000)]
    fn test_instantiation_breaking_constraints3() {
        let mut pattern = metavar(0, array![], array![], array![0], array![], array![]);
        let mut vars = array![0];
        let mut plugs = array![not(svar(0))];
        let _ = instantiate_internal(ref pattern, ref vars, ref plugs);
    }

    #[test]
    #[should_panic]
    #[available_gas(1000000000000000)]
    fn test_instantiation_breaking_constraints4() {
        let mut pattern = metavar(0, array![], array![], array![], array![0], array![]);
        let mut vars = array![0];
        let mut plugs = array![svar(0)];
        let _ = instantiate_internal(ref pattern, ref vars, ref plugs);
    }

    #[test]
    #[should_panic]
    #[available_gas(1000000000000000)]
    fn test_instantiation_breaking_constraints5() {
        let mut pattern = metavar(0, array![], array![], array![0], array![0], array![]);
        let mut vars = array![0];
        let mut plugs = array![svar(0)];
        let _ = instantiate_internal(ref pattern, ref vars, ref plugs);
    }

    #[test]
    #[available_gas(1000000000000000)]
    fn test_instantiation_breaking_constraints6() {
        let mut pattern = metavar(0, array![], array![], array![0], array![0], array![]);
        let mut vars = array![0];
        let mut plugs = array![svar(1)];
        let _ = instantiate_internal(ref pattern, ref vars, ref plugs);
    }

    #[test]
    #[should_panic]
    #[available_gas(1000000000000000)]
    fn test_illformed_instantiation() {
        let mut phi0 = metavar_unconstrained(0);
        let mut vars = array![1, 0];
        let mut plugs = array![phi0.clone()];
        let _ = instantiate_internal(ref phi0, ref vars, ref plugs);
    }

    #[test]
    #[available_gas(1000000000000000)]
    fn test_publish() {
        let proof = array![30]; // Instruction::Publish

        let mut stack = StackTrait::new();
        stack.push(Term::Pattern(symbol(0)));
        let mut memory = array![];
        let mut claims = ClaimTrait::new();
        execute_instructions(
            proof.clone(), ref stack, ref memory, ref claims, ExecutionPhase::Gamma,
        );
        assert_eq!(stack, StackTrait::new());
        assert_eq!(claims, ClaimTrait::new());
        assert_eq!(memory, array![Term::Proved(symbol(0))]);

        let mut stack = StackTrait::new();
        stack.push(Term::Pattern(symbol(0)));
        let mut memory = array![];
        let mut claims = ClaimTrait::new();
        execute_instructions(
            proof.clone(), ref stack, ref memory, ref claims, ExecutionPhase::Claim,
        );
        let mut expected_claims = ClaimTrait::new();
        expected_claims.push(symbol(0));
        assert_eq!(stack, StackTrait::new());
        assert_eq!(memory, array![]);
        assert_eq!(claims, expected_claims);

        let mut stack = StackTrait::new();
        stack.push(Term::Proved(symbol(0)));
        let mut memory = array![];
        let mut claims = ClaimTrait::new();
        claims.push(symbol(0));
        execute_instructions(proof, ref stack, ref memory, ref claims, ExecutionPhase::Proof,);
        assert_eq!(stack, StackTrait::new());
        assert_eq!(memory, array![]);
        assert_eq!(claims, ClaimTrait::new());
    }

    #[test]
    #[available_gas(1000000000000000)]
    fn test_construct_phi_implies_phi() {
        #[cairofmt::skip]
        let proof = array![
            9, 0, 0, 0, 0, 0, 0, // Instruction::MetaVar, Stack: Phi
            28,                  // Instruction::Save, @ 0
            29, 0,               // Instruction::Load, Phi ; Phi
            5,                   // Instruction::Implies, Phi -> Phi
        ];

        let mut stack = StackTrait::new();
        let mut memory = array![];
        let mut claims = ClaimTrait::new();
        execute_instructions(proof, ref stack, ref memory, ref claims, ExecutionPhase::Proof,);
        let phi0 = metavar_unconstrained(0);
        let mut expected_stack = StackTrait::new();
        expected_stack.push(Term::Pattern(implies(phi0.clone(), phi0.clone())));
        assert_eq!(stack, expected_stack);
    }

    #[test]
    #[available_gas(1000000000000000)]
    fn test_phi_implies_phi_impl() {
        #[cairofmt::skip]
        let proof = array![
            9, 0, 0, 0, 0, 0, 0, // Instruction::MetaVar, Stack: $ph0
            28,                  // Instruction::Save, @0
            29, 0,               // Instruction::Load, Stack: $ph0; ph0
            29, 0,               // Instruction::Load, Stack: $ph0; $ph0; ph0
            5,                   // Instruction::Implies, Stack: $ph0; ph0 -> ph0
            28,                  // Instruction::Save, @1
            13,                  // Instruction::Prop2, Stack: $ph0; $ph0 -> ph0; [prop2: (ph0 -> (ph1 -> ph2)) -> ((ph0 -> ph1) -> (ph0 -> ph2))]
            26, 1, 1,            // Instruction::Instantiate, Stack: $ph0; [p1: (ph0 -> ((ph0 -> ph0) -> ph2)) -> (ph0 -> (ph0 -> ph0)) -> (ph0 -> ph2)]
            26, 1, 2,            // Instruction::Instantiate, Stack: [p1: (ph0 -> ((ph0 -> ph0) -> ph0)) -> (ph0 -> (ph0 -> ph0)) -> (ph0 -> ph0)]
            29, 1,               // Instruction::Load, Stack: p1 ; $ph0 -> ph0
            12,                  // Instruction::Prop1, Stack: p1 ; $ph0 -> ph0; [prop1: ph0 -> (ph1 -> ph0)

            26, 1, 1,            // Instruction::Instantiate, Stack: p1 ; [p2: (ph0 -> (ph0 -> ph0) -> ph0) ]

            21,                  // Instruction::ModusPonens, Stack: [p3: (ph0 -> (ph0 -> ph0)) -> (ph0 -> ph0)]
            29, 0,               // Instruction::Load, Stack: p3 ; ph0;
            12,                  // Instruction::Prop1, Stack: p3 ; ph0; prop1

            26, 1, 1,            // Instruction::Instantiate, Stack: p3 ; ph0 -> (ph0 -> ph0)

            21,                  // Instruction::Instantiate, Stack: ph0 -> ph0
        ];

        let mut stack = StackTrait::new();
        let mut memory = array![];
        let mut claims = ClaimTrait::new();
        execute_instructions(proof, ref stack, ref memory, ref claims, ExecutionPhase::Proof,);
        let phi0 = metavar_unconstrained(0);
        let mut expected_stack = StackTrait::new();
        expected_stack.push(Term::Proved(implies(phi0.clone(), phi0.clone())));
        assert_eq!(stack, expected_stack);
    }

    #[test]
    #[available_gas(1000000000000000)]
    fn test_universal_quantification() {
        let proof = array![22, 0]; // Generalization
        let mut stack = StackTrait::new();
        stack.push(Term::Proved(implies(symbol(0), symbol(1))));
        let mut memory = array![];
        let mut claims = ClaimTrait::new();
        execute_instructions(proof, ref stack, ref memory, ref claims, ExecutionPhase::Proof,);

        let mut expected_stack = StackTrait::new();
        expected_stack.push(Term::Proved(implies(exists(0, symbol(0)), symbol(1))));
        assert_eq!(stack, expected_stack);
        assert_eq!(memory, array![]);
        assert_eq!(claims, ClaimTrait::new());
    // TODO: Test case for when 0 is not fresh in rhs
    }

    use super::apply_esubst;
    use super::{svar, symbol, app, exists, mu, esubst, ssubst};
    #[test]
    #[available_gas(1000000000000000)]
    fn test_apply_esubst() {
        let mut result = apply_esubst(@evar(0), 0, @symbol(1));
        assert_eq!(result, symbol(1));

        result = apply_esubst(@evar(0), 0, @evar(2));
        assert_eq!(result, evar(2));

        result = apply_esubst(@evar(0), 1, @evar(2));
        assert_eq!(result, evar(0));

        result = apply_esubst(@svar(0), 0, @symbol(0));
        assert_eq!(result, svar(0));

        result = apply_esubst(@svar(1), 0, @evar(0));
        assert_eq!(result, svar(1));

        result = apply_esubst(@symbol(0), 0, @symbol(1));
        assert_eq!(result, symbol(0));

        // Distribute over subpatterns
        result = apply_esubst(@implies(evar(7), symbol(1)), 7, @symbol(0));
        assert_eq!(result, implies(symbol(0), symbol(1)));

        result = apply_esubst(@implies(evar(7), symbol(1)), 6, @symbol(0));
        assert_eq!(result, implies(evar(7), symbol(1)));

        result = apply_esubst(@app(evar(7), symbol(1)), 7, @symbol(0));
        assert_eq!(result, app(symbol(0), symbol(1)));

        result = apply_esubst(@app(evar(7), symbol(1)), 6, @symbol(0));
        assert_eq!(result, app(evar(7), symbol(1)));

        // Distribute over subpatterns unless evar_id = binder
        result = apply_esubst(@exists(1, evar(1)), 0, @symbol(2));
        assert_eq!(result, exists(1, evar(1)));

        result = apply_esubst(@exists(0, evar(1)), 1, @symbol(2));
        assert_eq!(result, exists(0, symbol(2)));

        result = apply_esubst(@mu(1, evar(1)), 0, @symbol(2));
        assert_eq!(result, mu(1, evar(1)));

        result = apply_esubst(@mu(1, evar(1)), 1, @symbol(2));
        assert_eq!(result, mu(1, symbol(2)));

        // Subst on metavar should wrap in constructor
        result = apply_esubst(@metavar_unconstrained(0), 0, @symbol(1));
        assert_eq!(result, esubst(metavar_unconstrained(0), 0, symbol(1)));

        // Subst when evar_id is fresh should do nothing
        //(metavar_(0).with_e_fresh((evar(0), evar(1))), 0, symbol(1), metavar_unconstrained(0).with_e_fresh((evar(0), evar(1)))),
        // Subst on substs should stack
        result = apply_esubst(@esubst(metavar_unconstrained(0), 0, symbol(1)), 0, @symbol(1));
        assert_eq!(result, esubst(esubst(metavar_unconstrained(0), 0, symbol(1)), 0, symbol(1)));

        result = apply_esubst(@ssubst(metavar_unconstrained(0), 0, symbol(1)), 0, @symbol(1));
        assert_eq!(result, esubst(ssubst(metavar_unconstrained(0), 0, symbol(1)), 0, symbol(1)));
    }

    #[test]
    #[should_panic]
    #[available_gas(1000000000000000)]
    fn test_apply_esubst_negative() {
        let _ = apply_esubst(@exists(0, evar(1)), 1, @evar(0));
    }

    use super::apply_ssubst;
    #[test]
    #[available_gas(1000000000000000)]
    fn test_apply_ssubst() {
        let mut result = apply_ssubst(@evar(0), 0, @symbol(1));
        assert_eq!(result, evar(0));

        result = apply_ssubst(@evar(0), 1, @evar(2));
        assert_eq!(result, evar(0));

        result = apply_ssubst(@svar(0), 0, @symbol(0));
        assert_eq!(result, symbol(0));

        result = apply_ssubst(@svar(1), 0, @evar(0));
        assert_eq!(result, svar(1));

        result = apply_ssubst(@symbol(0), 0, @symbol(1));
        assert_eq!(result, symbol(0));

        // Distribute over subpatterns
        result = apply_ssubst(@implies(svar(7), symbol(1)), 7, @symbol(0));
        assert_eq!(result, implies(symbol(0), symbol(1)));

        result = apply_ssubst(@implies(svar(7), symbol(1)), 6, @symbol(0));
        assert_eq!(result, implies(svar(7), symbol(1)));

        result = apply_ssubst(@app(svar(7), symbol(1)), 7, @symbol(0));
        assert_eq!(result, app(symbol(0), symbol(1)));

        result = apply_ssubst(@app(svar(7), symbol(1)), 6, @symbol(0));
        assert_eq!(result, app(svar(7), symbol(1)));

        // Distribute over subpatterns unless svar_id = binder
        result = apply_ssubst(@exists(1, svar(0)), 0, @symbol(2));
        assert_eq!(result, exists(1, symbol(2)));

        result = apply_ssubst(@exists(1, symbol(1)), 1, @symbol(2));
        assert_eq!(result, exists(1, symbol(1)));

        result = apply_ssubst(@mu(1, svar(1)), 0, @symbol(2));
        assert_eq!(result, mu(1, svar(1)));

        result = apply_ssubst(@mu(1, svar(1)), 1, @symbol(2));
        assert_eq!(result, mu(1, svar(1)));

        result = apply_ssubst(@mu(1, svar(2)), 2, @symbol(2));
        assert_eq!(result, mu(1, symbol(2)));

        // Subst on metavar should wrap in constructor
        result = apply_ssubst(@metavar_unconstrained(0), 0, @symbol(1));
        assert_eq!(result, ssubst(metavar_unconstrained(0), 0, symbol(1)));

        // Subst when evar_id is fresh should do nothing
        //(metavar_unconstrained(0).with_s_fresh((svar(0), svar(1))), 0, symbol(1), metavar_unconstrained(0).with_s_fresh((svar(0), svar(1)))),
        // Subst on substs should stack
        result = apply_ssubst(@esubst(metavar_unconstrained(0), 0, symbol(1)), 0, @symbol(1));
        assert_eq!(result, ssubst(esubst(metavar_unconstrained(0), 0, symbol(1)), 0, symbol(1)));

        result = apply_ssubst(@ssubst(metavar_unconstrained(0), 0, symbol(1)), 0, @symbol(1));
        assert_eq!(result, ssubst(ssubst(metavar_unconstrained(0), 0, symbol(1)), 0, symbol(1)));
    }

    #[test]
    #[should_panic]
    #[available_gas(1000000000000000)]
    fn test_apply_ssubst_negative() {
        let _ = apply_ssubst(@mu(0, svar(1)), 1, @svar(0));
    }

    #[test]
    #[should_panic]
    #[available_gas(1000000000000000)]
    fn test_no_remaining_claims() {
        let gamma = array![];
        #[cairofmt::skip]
        let claims = array![
            4, // Instruction::Symbol as InstByte
            0,
            30, // Instruction::Publish as InstByte
        ];
        let proof = array![];

        verify(gamma, claims, proof);
    }

    // Testing version instruction
    #[test]
    #[available_gas(1000000000000000)]
    fn test_version_ok() {
        let gamma = array![31, 0, 1];
        let claims = array![];
        let proof = array![];
        verify(gamma, claims, proof);
    }

    #[test]
    #[should_panic]
    #[available_gas(1000000000000000)]
    fn test_version_fail() {
        let gamma = array![31, 0, 0];
        let claims = array![];
        let proof = array![];
        verify(gamma, claims, proof);
    }
}
