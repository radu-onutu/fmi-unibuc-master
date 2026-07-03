### PV-C01-Quiz1

1. Which of the followings are not formal verification methods?

   - [ ] model checking

   - [ ] abstract interpretation

   - [x] number theory

   - [ ] static analysis

   - [ ] type systems

2. What are the kinds of program analysis?

   - [x] static & dynamic analysis

   - [ ] robust analysis

   - [ ] easy-peasy analysis

   - [ ] introspect analysis

3. How is static analysis of a program performed?

   - [ ] while running the program

   - [x] without running the program

   - [ ] after the execution of the program

   - [ ] none of the above

### PV-C02-Quiz1

1. Hoare logic

   - [x] assumes termination

   - [ ] proves termination

   - [ ] implies termination

   - [ ] none of the above

2. How is reasoning in Hoare logic done?

   - [x] backwards, from postcondition to precondition

   - [ ] forwards, from precondition to postcondition

   - [ ] one step forward, two steps backwards

   - [ ] none of the above

3. Consider the assertions P = (x > 1) and Q = (x = 7). Which of the following is true?

   - [ ] P is stronger than Q

   - [x] P is weaker than Q

   - [ ] Q is weaker than P

   - [ ] P and Q are unrelated

### PV-C03-Quiz1

1. For a Hoare triple of the form {P} C {Q}, which of the followings is false?

   - [ ] P is the precondition

   - [x] C is a first-order formula

   - [ ] Q is the postcondition

   - [ ] P is a first-order formula

2. A loop invariant must hold

   - [ ] throughout the execution of the loop body

   - [x] between loop iterations

   - [ ] never holds

   - [ ] none of the above

3. Which of the followings is true?

   - [ ] The loop invariant can automatically be deduced

   - [x] There is no algorithm to find the loop invariant

   - [ ] Loop invariants are always true

   - [ ] If the loop terminates, the loop condition must be true

### PV-C04-Quiz1

1. Which of the followings is true for Weakest Precondition calculus?

   - [ ] Given a precondition P, some code C, and postcondition Q, it establishes if the Hoare triple {P} C {Q} is true.

   - [ ] Given some code C and a precondition P, it finds some unique Q which is the weakest postcondition for C and P.

   - [ ] Given some code C and a postcondition Q, it finds all P such that the Hoare triple {P} C {Q} is true.

   - [x] Given some code C and a postcondition Q, it finds the unique P which is the weakest precondition for C and Q.

2. What does it mean total correctness?

   - [ ] it is equivalent with partial correctness

   - [x] it is equivalent with termination and partial correctness

   - [ ] it is equivalent with termination

   - [ ] none of the above

3. What is the rule for sequences in Weakest Precondition calculus?

   - [x] wp(C1; C2,Q) ≡ wp(C1,wp(C2,Q))

   - [ ] wp(C1; C2,Q) ≡ wp(C2,wp(C1,Q))

   - [ ] wp(C1; C2,Q) ≡ wp(C1,Q)

   - [ ] wp(C1; C2,Q) ≡ wp(C2,Q)

4. In the Weakest Precondition calculus, finding a loop invariant is

   - [ ] easy

   - [ ] done in PTIME

   - [x] undecidable

   - [ ] done in EXPTIME

### PV-C05-Quiz1

1. How is a state represented in Separation logic?

   - [ ] Store

   - [ ] Heap

   - [x] Store x Heap

   - [ ] none of the above

2. What is aliasing?

   - [x] two different program variables containing the same location

   - [ ] two commands with the same semantics

   - [ ] when a program variable is recaptured

   - [ ] none of the above

3. Which of the following connectives is in separation logic?

   - [x] -

   - [ ] AG

   - [ ] EX

   - [ ] ▢

### PV-C06-Quiz1

1. What is a SAT solver?

   - [ ] an imperative programming language

   - [x] a program that automatically decides whether a propositional formula is satisfiable

   - [ ] a functional programming language

   - [ ] an algorithm for computing the CNF of a formula

2. Which of the following formulas is in CNF, where - stands for negation of a variable?

   - [x] (p \/ -q) /\ (r \/ p)

   - [ ] (p /\ -q) / (r /\ p)

   - [ ] p \/ -q / (r /\ p)

   - [ ] none of the above

3. What clause do you obtain after applying the resolution rule for the clauses {x1, x2, x3} and {-x2,x4}, where - stands for negation of a variable?

   - [ ] {x1,x2,x3,-x2,x4}

   - [ ] {x1,x2,x3,x4}

   - [x] {x1,x3,x4}

   - [ ] {x1,x3} and {x4}

4. Which of the followings is the representation as vectors of vectors of literals forthe CNF formula (x1 / x2) /\ (-x2 / x3), where - stands for negation?

   - [x] [[1,2],[-2,3]]
   - [ ] [1,2,-2,3]
   - [ ] [1,2,3]
   - [ ] [[-1,-2],[2,3]]

### PV-C07-Quiz1

1. Consider a first-order signature with a constant symbol a, a function symbol f of arity 1, and a predicate symbol P of arity 1. Which of the followings is a term?

   - [ ] P(a)

   - [x] f(f(a))

   - [ ] P(a) -> f(a)

   - [ ] f(P(a))

2. Consider a first-order signature with a constant symbol a, a function symbol f of arity 1, and a predicate symbol P of arity 1. Which of the followings is an atomic formula in first-order logic?

   - [x] P(a)

   - [ ] f(f(a))

   - [ ] P(a) -> f(a)

   - [ ] f(P(a))

3. Consider a first-order signature with a constant symbol a, a function symbol f of arity 1, and a predicate symbol P of arity 1. Which of the followings is a formula in first-order logic?

   - [x] P(a) \/ P(f(a))

   - [ ] f(f(a))

   - [ ] P(a) -> f(a)

   - [ ] P(P(a))

### PV-C08-Quiz1

1. For what can we use the Nelson-Oppen method?

   - [ ] to solve the SAT problem

   - [ ] for static analysis

   - [x] for combining theory solvers

   - [ ] none of the above

2. In symbolic execution, at the beginning of the analysis, the path constraint is

   - [ ] undefined

   - [ ] a random first-order formula

   - [x] the syntactic symbol for true

   - [ ] the syntactic symbol for false

3. What is concolic execution good for?

   - [ ] solving the SAT problem

   - [x] driving the symbolic execution

   - [ ] combining theory solvers

   - [ ] none of the above
