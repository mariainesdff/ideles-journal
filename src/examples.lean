/-
Copyright (c) 2022 María Inés de Frutos-Fernández. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: María Inés de Frutos-Fernández
-/
import ideles_number_field
import number_theory.zsqrtd.gaussian_int

/-!
# Examples
We instantiate some concrete examples of the definitions formalized in this project:
- We compute the `2`-adic valuation of some elements of `ℤ` and `ℚ`.
- We define the finite adèle ring and finite idèle group of the Dedekind domains `ℤ` and `ℤ[i]`.
- We define the (finite) adèle ring and (finite) idèle group of the number field `ℚ`.
-/

noncomputable theory

/-- The ideal generated by `2`, as a maximal ideal of `ℤ`. -/
def v2 : maximal_spectrum ℤ :=
{ as_ideal := ideal.span{(2 : ℤ)},
  is_prime := (ideal.span_singleton_prime (@two_ne_zero ℤ _ _)).mpr int.prime_two,
  ne_bot   := by {simp only [ne.def, ideal.span_singleton_eq_bot, two_ne_zero, not_false_iff] }}

/-- The `2`-adic valuation on `ℤ`. -/
def v2_int_adic_valuation : valuation ℤ (with_zero (multiplicative ℤ)) := v2.int_valuation

open_locale classical

example : v2_int_adic_valuation (4 : ℤ) = multiplicative.of_add (-2 : ℤ) := 
begin
  have hv2 : v2.as_ideal = ideal.span{(2 : ℤ)} := rfl,
  have h_irr : irreducible (associates.mk v2.as_ideal) := v2.associates_irreducible,
  have h_ne_0 : associates.mk (ideal.span {(2 : ℤ)} : ideal ℤ) ≠ 0,
  { exact associates.mk_ne_zero.mpr v2.ne_bot},
  have : (4 : ℤ) = 2^2 := rfl,
  simp only [v2_int_adic_valuation, v2.int_valuation_apply, v2.int_valuation_def_if_neg
    four_ne_zero, ideal.zero_eq_bot, ne.def, ideal.span_singleton_eq_bot,
    bit0_eq_zero, one_ne_zero, not_false_iff, of_add_neg, inv_inj, with_zero.coe_inj,
    embedding_like.apply_eq_iff_eq],
  rw [this, ← ideal.span_singleton_pow],
  norm_cast,
  rw [associates.mk_pow, associates.count_pow h_ne_0 h_irr],
  conv_rhs{rw ← mul_one 2},
  rw hv2 at h_irr ⊢,
  rw associates.count_self h_irr,
end

/-- The `2`-adic valuation on `ℚ`. -/
def v2_adic_valuation : valuation ℚ (with_zero (multiplicative ℤ )) := v2.valuation

example : v2_adic_valuation (3/2 : ℚ) = multiplicative.of_add (1 : ℤ) := 
begin
  have hv2 : v2.as_ideal = ideal.span{(2 : ℤ)} := rfl,
  have h_irr : irreducible (associates.mk v2.as_ideal) := v2.associates_irreducible,
  have h_ne_0 : associates.mk (ideal.span {(2 : ℤ)} : ideal ℤ) ≠ 0,
  { exact associates.mk_ne_zero.mpr v2.ne_bot},
  have h2 : (2 : ℤ) ∈ non_zero_divisors ℤ := mem_non_zero_divisors_iff_ne_zero.mpr two_ne_zero,
  have : (3/2 : ℚ) = is_localization.mk' ℚ (3 : ℤ) (⟨2, h2⟩ : non_zero_divisors ℤ),
  { rw [is_fraction_ring.mk'_eq_div, set_like.coe_mk, ring_hom.eq_int_cast, ring_hom.eq_int_cast,
      int.cast_two, int.cast_bit1, int.cast_one] },
  have h_irr3 : irreducible (associates.mk (ideal.span {(3 : ℤ)} : ideal ℤ)),
  { rw [associates.irreducible_mk _, unique_factorization_monoid.irreducible_iff_prime,
      ideal.prime_iff_is_prime],
    exact (ideal.span_singleton_prime (@three_ne_zero ℤ _ _)).mpr int.prime_three,
    simp only [ne.def, ideal.span_singleton_eq_bot, three_ne_zero, not_false_iff] ,},
  have h_ne : associates.mk (ideal.span {(2 : ℤ)} : ideal ℤ) ≠ 
    associates.mk (ideal.span {(3 : ℤ)} : ideal ℤ),
  { rw [ne.def, associates.mk_eq_mk_iff_associated,  associated_iff_eq,
      ideal.span_singleton_eq_span_singleton, int.associated_iff],
    apply not_or; linarith,},
  simp only [v2_adic_valuation, v2.valuation_apply, this, maximal_spectrum.valuation_of_mk',
    set_like.coe_mk, v2.int_valuation_def_if_neg two_ne_zero, 
    v2.int_valuation_def_if_neg three_ne_zero],
  norm_cast,
  rw hv2 at h_irr ⊢,
  simp only [associates.count_self h_irr, of_add_neg, int.coe_nat_succ, int.coe_nat_zero, zero_add,
    inv_div_inv, div_eq_self, of_add_eq_one, int.coe_nat_eq_zero],
  apply associates.count_eq_zero_of_ne h_irr h_irr3 h_ne,
end

/-- The finite adèle ring of `ℤ`.-/
def finite_adeles_Z := finite_adele_ring' ℤ ℚ
instance : inhabited (finite_adeles_Z) := ⟨inj_K ℤ ℚ 0⟩

/-- The finite idèle group of `ℤ`.-/
def finite_ideles_Z := finite_idele_group' ℤ ℚ
instance : inhabited (finite_ideles_Z) := ⟨inj_units_K ℤ ℚ 1⟩

/-- The finite adèle ring of `ℚ`.-/
def finite_adeles_Q := number_field.A_K_f ℚ
instance : inhabited (finite_adeles_Q) := ⟨number_field.inj_K_f ℚ 0⟩

/-- The adèle ring of `ℚ`.-/
def adeles_Q := number_field.A_K ℚ
instance : inhabited (adeles_Q) := ⟨number_field.inj_K ℚ 0⟩

/-- The finite idèle group of `ℚ`.-/
def finite_ideles_Q := number_field.I_K_f ℚ
instance : inhabited (finite_ideles_Q) := ⟨number_field.inj_units_K_f ℚ 1⟩

/-- The idèle group of `ℚ`.-/
def ideles_Q := number_field.I_K ℚ
instance : inhabited (ideles_Q) := ⟨number_field.inj_units_K ℚ 1⟩

/-- The finite adèle ring of `ℤ[i]`.-/
def finite_adeles_Zi := finite_adele_ring' gaussian_int (fraction_ring gaussian_int)
instance : inhabited (finite_adeles_Zi) := ⟨inj_K gaussian_int (fraction_ring gaussian_int) 0⟩

/-- The finite idèle group of `ℤ[i]`.-/
def finite_ideles_Zi := finite_idele_group' gaussian_int (fraction_ring gaussian_int)
instance : inhabited (finite_ideles_Zi) := ⟨inj_units_K gaussian_int (fraction_ring gaussian_int) 1⟩