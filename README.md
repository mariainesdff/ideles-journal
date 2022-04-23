# Adèles and idèles of global fields

This repository contains the source code for the paper  "Formalizing the ring of adèles of a global field", [to be presented at ITP 2022](https://itpconference.github.io/ITP22/cfp.html). The code runs over Lean 3.42.1 and mathlib's version [0f9edf98f8](https://github.com/leanprover-community/mathlib/tree/0f9edf98f8cd8a99a6694f19e0b3f47e7e12c165) (21st April, 2022).

The ring of adèles of a global field and its group of units, the group of idèles, are fundamental objects in modern number theory. We formalize the finite adèle ring and finite idèle group of a Dedekind domain. Building on this, we formalize the (finite) adèle ring, (finite) idèle group and idèle class group of any number field or function field.

We provide two applications: the statement of the main theorem of global class field theory, and a proof that the ideal class group is isomorphic to an explicit quotient of the idèle class group.

As a prerequisite, we formalize adic valuations on Dedekind domains and the associated completions.

The code developped in this project is in the process of being integrated into the mathlib library, but we keep a complete version here for ease of reference. To check which parts of the code are available in mathlib at any given time, please visit [mariainesdff/ideles](https://github.com/mariainesdff/ideles).

## Installation instructions
The formalization has been developed over Lean 3 and its matemathical library mathlib. For detailed instructions to install Lean, mathlib, and supporting tools, visit the [Lean Community website](https://leanprover-community.github.io/get_started.html).

After installation, run the command `leanproject get mariainesdff/ideles-journal-repository` to obtain a copy of the project's source files and dependencies. To open the project in VS Code, either run `path/to/ideles-journal-repository` on the command line, or use the "Open Folder" menu option to open the project's root directory.

## Documentation

The documentation automatically generated from the source files of the submitted version of the project is available on [this link](https://mariainesdff.github.io/ideles-journal-repository). Note that it includes documentation for the versions of Lean and  mathlib used by the project.

See also [Lean's general documentation](https://leanprover.github.io/documentation/) and the [current mathlib docs](https://leanprover-community.github.io/mathlib_docs).

## Code overview

We indicate which source files contain the main definitions and results described in the paper.

### Section 2
* Adic valuations on Dedekind domains: [src/valuation.lean](https://github.com/mariainesdff/ideles-journal-repository/blob/master/src/valuation.lean).
* The finite adèle ring of a Dedekind domain: [src/adeles_R.lean](https://github.com/mariainesdff/ideles-journal-repository/blob/master/src/adeles_R.lean).
* The finite idèle group of a Dedekind domain: [src/ideles_R.lean](https://github.com/mariainesdff/ideles-journal-repository/blob/master/src/ideles_R.lean).
* Factorization of fractional ideals: [src/fractional_ideal.lean](https://github.com/mariainesdff/ideles-journal-repository/blob/master/src/fractional_ideal.lean).

### Section 3
* The ring of adèles of a number field: [src/adeles_number_field.lean](https://github.com/mariainesdff/ideles-journal-repository/blob/master/src/adeles_number_field.lean).
* The group of idèles of a number field: [src/ideles_number_field.lean](https://github.com/mariainesdff/ideles-journal-repository/blob/master/src/ideles_number_field.lean).
* The idèle class group of a number field: [src/ideles_number_field.lean](https://github.com/mariainesdff/ideles-journal-repository/blob/master/src/ideles_number_field.lean).

### Section 4
* The place at infinity on `k(t)`: [function_field.lean](https://github.com/mariainesdff/ideles-journal-repository/blob/master/src/function_field.lean).
* The ring of adèles of a function field: [src/adeles_function_field.lean](https://github.com/mariainesdff/ideles-journal-repository/blob/master/src/adeles_function_field.lean).
* The group of idèles of a function field: [src/ideles_function_field.lean](https://github.com/mariainesdff/ideles-journal-repository/blob/master/src/ideles_function_field.lean).
* The idèle class group of a function field: [src/ideles_function_field.lean](https://github.com/mariainesdff/ideles-journal-repository/blob/master/src/ideles_function_field.lean).

### Section 5
* The ideal class group of a number field is a quotient of the idèle class group: [src/ideles_number_field.lean](https://github.com/mariainesdff/ideles-journal-repository/blob/master/src/ideles_number_field.lean).
* The ideal class group of a function field is a quotient of the idèle class group: [src/ideles_function_field.lean](https://github.com/mariainesdff/ideles-journal-repository/blob/master/src/ideles_function_field.lean).
* The statement of the main theorem of global class field theory: [src/main_theorem_GCFT.lean](https://github.com/mariainesdff/ideles-journal-repository/blob/master/src/main_theorem_GCFT.lean).
* The abelianization of the absolute Galois group: [src/galois.lean](https://github.com/mariainesdff/ideles-journal-repository/blob/master/src/galois.lean).

Copyright (C) 2022, María Inés de Frutos-Fernández
