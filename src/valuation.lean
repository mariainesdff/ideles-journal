import algebraic_geometry.prime_spectrum.basic
import ring_theory.dedekind_domain
import topology.algebra.valued_field
import with_zero

noncomputable theory
open_locale classical

variables (R : Type) {K : Type} [comm_ring R] [is_domain R] [is_dedekind_domain R] [field K]
  [algebra R K] [is_fraction_ring R K] 

--def Γ₀ := with_zero (multiplicative ℤ)

-- Note : not the maximal spectrum if R is a field
def maximal_spectrum := {v : prime_spectrum R // v.as_ideal ≠ 0 }
variable (v : maximal_spectrum R)

variable {R}

lemma of_add_le (α : Type*) [has_add α] [partial_order α] (x y : α) :
  multiplicative.of_add x ≤ multiplicative.of_add y ↔ x ≤ y := by refl
lemma of_add_lt (α : Type*) [has_add α] [partial_order α] (x y : α) :
  multiplicative.of_add x < multiplicative.of_add y ↔ x < y := by refl

lemma of_add_inj (α : Type*) [has_add α] (x y : α) 
  (hxy : multiplicative.of_add x = multiplicative.of_add y) : x = y := 
by rw [← to_add_of_add x, ← to_add_of_add y, hxy]

lemma associates.irreducible_of_maximal (v : maximal_spectrum R) :
  irreducible (associates.mk v.val.as_ideal) := 
begin
  rw [associates.irreducible_mk _, unique_factorization_monoid.irreducible_iff_prime],
  apply ideal.prime_of_is_prime v.property v.val.property,
end

lemma ideal.irreducible_of_maximal (v : maximal_spectrum R) :
  irreducible v.val.as_ideal := 
begin
  rw [unique_factorization_monoid.irreducible_iff_prime],
  apply ideal.prime_of_is_prime v.property v.val.property,
end

lemma associates.mk_ne_zero' {x : R} : (associates.mk (ideal.span{x} : ideal R)) ≠ 0 ↔ (x ≠ 0):=
begin
  rw associates.mk_ne_zero,
  rw [ideal.zero_eq_bot, ne.def, ideal.span_singleton_eq_bot],
end

def ring.adic_valuation.def (r : R) : with_zero (multiplicative ℤ) :=
dite (r = 0) (λ (h : r = 0), 0) (λ h : ¬ r = 0, (multiplicative.of_add
  (-(associates.mk v.val.as_ideal).count (associates.mk (ideal.span{r} : ideal R)).factors : ℤ)))

lemma ring.adic_valuation.map_one' : ring.adic_valuation.def v 1 = 1 := 
begin
  rw [ring.adic_valuation.def, dif_neg (ne.symm zero_ne_one)],
  { rw [← with_zero.coe_one, with_zero.coe_inj, ← of_add_zero],
    apply congr_arg,
    rw [neg_eq_zero, int.coe_nat_eq_zero, ideal.span_singleton_one, ← ideal.one_eq_top,
      associates.mk_one, associates.factors_one,
      associates.count_zero _],
    apply associates.irreducible_of_maximal v },
  { by apply_instance }
end

lemma ring.adic_valuation.map_mul' (x y : R) :
  ring.adic_valuation.def v (x * y) = ring.adic_valuation.def v x * ring.adic_valuation.def v y :=
begin
  rw [ring.adic_valuation.def, ring.adic_valuation.def, ring.adic_valuation.def],
  by_cases hx : x = 0,
  { rw [hx, zero_mul, dif_pos (eq.refl _), zero_mul] },
  { by_cases hy : y = 0,
    { rw [hy, mul_zero, dif_pos (eq.refl _), mul_zero] },
    { rw [dif_neg hx, dif_neg hy, dif_neg (mul_ne_zero hx hy), ← with_zero.coe_mul,
        with_zero.coe_inj, ← of_add_add],
      have hx' : associates.mk (ideal.span{x} : ideal R) ≠ 0 := associates.mk_ne_zero'.mpr hx,
      have hy' : associates.mk (ideal.span{y} : ideal R) ≠ 0 := associates.mk_ne_zero'.mpr hy,
      rw [← ideal.span_singleton_mul_span_singleton, ← associates.mk_mul_mk, ← neg_add,
        associates.count_mul hx' hy' _],
      { refl },
      { apply (associates.irreducible_of_maximal v), }}}
end

lemma associates.le_singleton_iff (x : R) (n : ℕ) (I : ideal R) :
  associates.mk I^n ≤ associates.mk (ideal.span {x}) ↔ x ∈ I^n :=
begin
  rw [← associates.dvd_eq_le, ← associates.mk_pow, associates.mk_dvd_mk, ideal.dvd_span_singleton],
end

lemma ring.adic_valuation.map_add' (x y : R) : ring.adic_valuation.def v (x + y) ≤
  max (ring.adic_valuation.def v x) (ring.adic_valuation.def v y) := 
begin
  by_cases hx : x = 0,
  { rw [hx, zero_add],
    conv_rhs {rw [ring.adic_valuation.def, dif_pos (eq.refl _)]},
    rw max_eq_right (with_zero.zero_le (ring.adic_valuation.def v y)),
    exact le_refl _, },
  { by_cases hy : y = 0,
    { rw [hy, add_zero],
      conv_rhs {rw [max_comm, ring.adic_valuation.def, dif_pos (eq.refl _)]},
        rw max_eq_right (with_zero.zero_le (ring.adic_valuation.def v x)), 
        exact le_refl _ },
    { by_cases hxy : x + y = 0,
      { rw [ring.adic_valuation.def, dif_pos hxy], exact zero_le',},
      { rw [ring.adic_valuation.def, ring.adic_valuation.def, ring.adic_valuation.def,
          dif_neg hxy, dif_neg hx, dif_neg hy],
      rw [le_max_iff, with_zero.coe_le_coe, of_add_le, with_zero.coe_le_coe, of_add_le,
        neg_le_neg_iff, neg_le_neg_iff, int.coe_nat_le, int.coe_nat_le, ← min_le_iff],
      set nmin := min 
        ((associates.mk v.val.as_ideal).count (associates.mk (ideal.span {x})).factors)
        ((associates.mk v.val.as_ideal).count (associates.mk (ideal.span {y})).factors),
      have hx' : (associates.mk (ideal.span {x} : ideal R)) ≠ 0 := associates.mk_ne_zero'.mpr hx,
      have hy' : (associates.mk (ideal.span {y} : ideal R)) ≠ 0 := associates.mk_ne_zero'.mpr hy,
      have hxy' : (associates.mk (ideal.span {x + y} : ideal R)) ≠ 0 := 
      associates.mk_ne_zero'.mpr hxy,
      have h_dvd_x : x ∈ v.val.as_ideal ^ (nmin),
      { rw [← associates.le_singleton_iff x nmin _],
       rw [associates.prime_pow_dvd_iff_le hx' _],
       exact min_le_left _ _,
        apply associates.irreducible_of_maximal v,
      },
      have h_dvd_y : y ∈ v.val.as_ideal ^ nmin,
      { rw [← associates.le_singleton_iff y nmin _, associates.prime_pow_dvd_iff_le hy' _],
        exact min_le_right _ _,
        apply associates.irreducible_of_maximal v,
      },
      have h_dvd_xy : associates.mk v.val.as_ideal^nmin ≤ associates.mk (ideal.span {x + y}),
      { rw associates.le_singleton_iff,
        exact ideal.add_mem (v.val.as_ideal^nmin) h_dvd_x h_dvd_y, },
      rw (associates.prime_pow_dvd_iff_le hxy' _) at h_dvd_xy,
      exact h_dvd_xy,
      apply associates.irreducible_of_maximal v, }}}
end

def ring.adic_valuation (v : maximal_spectrum R) : valuation R (with_zero (multiplicative ℤ)) :=
{ to_fun    := ring.adic_valuation.def v, 
  map_zero' := by { rw [ring.adic_valuation.def, dif_pos], refl, },
  map_one'  := ring.adic_valuation.map_one' v,
  map_mul'  := ring.adic_valuation.map_mul' v,
  map_add'  := ring.adic_valuation.map_add' v }

lemma ring.adic_valuation.ne_zero (v : maximal_spectrum R) (x : non_zero_divisors R) :
  ring.adic_valuation.def v x ≠ 0 :=
begin
  rw [ring.adic_valuation.def, dif_neg (non_zero_divisors.coe_ne_zero x)],
  exact with_zero.coe_ne_zero,
end

lemma ring.adic_valuation.ne_zero' (v : maximal_spectrum R) (x : R) (hx : x ≠ 0) :
  ring.adic_valuation.def v x ≠ 0 :=
begin
  rw [ring.adic_valuation.def, dif_neg hx],
  exact with_zero.coe_ne_zero,
end

lemma ring.adic_valuation.zero_le (v : maximal_spectrum R)
(x : non_zero_divisors R) : 0 < ring.adic_valuation.def v x :=
begin
  rw [ring.adic_valuation.def, dif_neg (non_zero_divisors.coe_ne_zero x)],
  exact with_zero.zero_lt_coe _,
end

lemma ring.adic_valuation.le_one (x : R) : ring.adic_valuation.def v x ≤ 1 :=
begin
  rw ring.adic_valuation.def,
  by_cases hx : x = 0,
  { rw dif_pos hx, exact with_zero.zero_le 1,},
  { rw [dif_neg hx, ← with_zero.coe_one, ← of_add_zero, with_zero.coe_le_coe, of_add_le,
      right.neg_nonpos_iff],
    exact int.coe_nat_nonneg _, }
end

set_option profiler true
lemma ring.adic_valuation.exists_uniformizer : 
  ∃ (π : R), ring.adic_valuation.def v π = multiplicative.of_add (-1 : ℤ) := 
begin
  have hv : irreducible (associates.mk v.val.as_ideal) := associates.irreducible_of_maximal v,
  have hlt : v.val.as_ideal^2 < v.val.as_ideal,
  { rw ← ideal.dvd_not_unit_iff_lt,
    use [v.property, v.val.as_ideal],
    split,
    { rw ideal.is_unit_iff,
      exact ideal.is_prime.ne_top v.val.property,  },
    { exact sq v.val.as_ideal }},
  obtain ⟨π, mem, nmem⟩ := set_like.exists_of_lt hlt,
  have hπ : π ≠ 0,
  { intro h,
    rw h at nmem,
    exact nmem (submodule.zero_mem (v.val.as_ideal^2)), },
  use π,
  rw [ring.adic_valuation.def, dif_neg hπ, with_zero.coe_inj],
  apply congr_arg, 
  rw [neg_inj, ← int.coe_nat_one, int.coe_nat_inj'],
  rw [← ideal.dvd_span_singleton, ← associates.mk_le_mk_iff_dvd_iff] at mem nmem,
  rw associates.mk_pow at nmem,
  rw ← pow_one ( associates.mk v.val.as_ideal) at mem,
  rw associates.prime_pow_dvd_iff_le (associates.mk_ne_zero'.mpr hπ) hv at mem nmem,
  linarith,
end
set_option profiler false

def adic_valuation.def (v : maximal_spectrum R) (x : K) : (with_zero (multiplicative ℤ)) :=
let s := classical.some (classical.some_spec (is_localization.mk'_surjective
  (non_zero_divisors R) x)) in (ring.adic_valuation.def v (classical.some
    (is_localization.mk'_surjective (non_zero_divisors R) x)))/(ring.adic_valuation.def v s)

variable (K)
lemma adic_valuation.well_defined (v : maximal_spectrum R) {r r' : R} {s s' : non_zero_divisors R} 
  (h_mk : is_localization.mk' K r s = is_localization.mk' K r' s') :
  (ring.adic_valuation.def v r)/(ring.adic_valuation.def v s) =
  (ring.adic_valuation.def v r')/(ring.adic_valuation.def v s') := 
begin
  rw [div_eq_div_iff (ring.adic_valuation.ne_zero v s) (ring.adic_valuation.ne_zero v s'),
  ← ring.adic_valuation.map_mul' v, ← ring.adic_valuation.map_mul' v,
  is_fraction_ring.injective R K (is_localization.mk'_eq_iff_eq.mp h_mk)],
end

lemma is_localization.mk'_eq_zero_of_num_zero {R : Type*} [comm_ring R] {M : submonoid R}
  {S : Type*} [comm_ring S] [algebra R S] [is_localization M S] {z : S}  {x : R} {y : M}
  (hxyz : z = is_localization.mk' S x y) (hx : x = 0) : z = 0 := 
by rw [hxyz, hx, eq_comm, is_localization.eq_mk'_iff_mul_eq, zero_mul, ring_hom.map_zero]

lemma is_localization.mk'_num_ne_zero_of_ne_zero {R : Type*} [comm_ring R] {M : submonoid R}
  {S : Type*} [comm_ring S] [algebra R S] [is_localization M S] {z : S}  {x : R} {y : M}
  (hxyz : z = is_localization.mk' S x y) (hz : z ≠ 0) : x ≠ 0 := 
begin
  rw is_localization.eq_mk'_iff_mul_eq at hxyz, 
  intro hx,
  exact hz (is_localization.eq_zero_of_fst_eq_zero hxyz hx),
end

/- lemma adic_valuation.ne_zero (v : maximal_spectrum R) (x : K) (hx : x ≠ 0) :
  adic_valuation.def v x ≠ 0 :=
begin
  rw [adic_valuation.def, ne.def, div_eq_zero_iff, decidable.not_or_iff_and_not],
  let rx : R := (classical.some (adic_valuation.def._proof_1 (x : K))),
  let sx : non_zero_divisors R := (classical.some (adic_valuation.def._proof_2 (x : K))),
  have hnum_ne_zero : rx ≠ (0 : R),
  { have hx_loc : x = is_localization.mk' K rx sx :=
    eq.symm (classical.some_spec (adic_valuation.def._proof_2 (x : K))),
    exact is_localization.mk'_num_ne_zero_of_ne_zero hx_loc hx, },
  exact ⟨ring.adic_valuation.ne_zero' v (classical.some (adic_valuation.def._proof_1 (x : K)))
    hnum_ne_zero, ring.adic_valuation.ne_zero' v (sx : R) (non_zero_divisors.coe_ne_zero sx)⟩,
end  -/



variable {K}

variables {A : Type*} [comm_ring A] [is_domain A] {S : Type*} [field S] [algebra A S]
  [is_fraction_ring A S]

lemma is_localization.mk'_eq_zero  {r : A} {s : non_zero_divisors A}
  (h : is_localization.mk' S r s = 0) : r = 0 := 
begin
  rw [is_fraction_ring.mk'_eq_div, div_eq_zero_iff] at h,
  apply is_fraction_ring.injective A S,
  rw (algebra_map A S).map_zero,
  exact or.resolve_right h (is_fraction_ring.to_map_ne_zero_of_mem_non_zero_divisors s.property),
end

variable (S)
lemma is_localization.mk'_eq_one  {r : A} {s : non_zero_divisors A}
  (h : is_localization.mk' S r s = 1) : r = s :=
begin
  rw [is_fraction_ring.mk'_eq_div, div_eq_one_iff_eq] at h,
  exact is_fraction_ring.injective A S h,
  exact is_fraction_ring.to_map_ne_zero_of_mem_non_zero_divisors s.property,
end 

lemma adic_valuation.map_zero' (v : maximal_spectrum R) :
adic_valuation.def v (0 : K) = 0 := 
begin
  rw adic_valuation.def,
  simp_rw is_fraction_ring.mk'_eq_div,
  rw div_eq_zero_iff,
  left,
  rw [ring.adic_valuation.def, dif_pos],
  simp_rw [ ← is_fraction_ring.mk'_eq_div],
  obtain ⟨s, hs⟩ := 
  classical.some_spec(is_localization.mk'_surjective (non_zero_divisors R) (0 : K)),
  apply is_localization.mk'_eq_zero hs,
end

lemma adic_valuation.map_one' (v : maximal_spectrum R) :
adic_valuation.def v (1 : K) = 1 := 
begin
  rw adic_valuation.def,
  simp_rw is_fraction_ring.mk'_eq_div,
  rw div_eq_one_iff_eq (ring.adic_valuation.ne_zero v _),
  apply congr_arg,
  apply is_localization.mk'_eq_one K,
  convert (classical.some_spec (adic_valuation.def._proof_2 (1 : K))),
  { simp only [is_fraction_ring.mk'_eq_div],},
  { simp only [is_fraction_ring.mk'_eq_div],},
  { by apply_instance },
  { by apply_instance },
end

lemma adic_valuation.map_mul' (v : maximal_spectrum R)
(x y : K) : adic_valuation.def v (x * y) = adic_valuation.def v x * adic_valuation.def v y :=
begin
  rw [adic_valuation.def, adic_valuation.def, adic_valuation.def, div_mul_div _ _ _ _,
    ← ring.adic_valuation.map_mul', ← ring.adic_valuation.map_mul', ← submonoid.coe_mul],
  apply adic_valuation.well_defined K v,
  rw [(classical.some_spec (adic_valuation.def._proof_2 (x * y))), is_fraction_ring.mk'_eq_div,
    (algebra_map R K).map_mul, submonoid.coe_mul, (algebra_map R K).map_mul, ← div_mul_div,
    ← is_fraction_ring.mk'_eq_div, ← is_fraction_ring.mk'_eq_div,
    (classical.some_spec (adic_valuation.def._proof_2 x)),
    (classical.some_spec (adic_valuation.def._proof_2 y))],
end

lemma adic_valuation.map_add' (v : maximal_spectrum R) (x y : K) :
  adic_valuation.def v (x + y) ≤ max (adic_valuation.def v x)  (adic_valuation.def v y) := 
begin
  rw [adic_valuation.def, adic_valuation.def, adic_valuation.def, le_max_iff],
  dsimp only,
  let rxy : R := (classical.some (adic_valuation.def._proof_1 (x + y))),
  let sxy : non_zero_divisors R := (classical.some (adic_valuation.def._proof_2 (x + y))),
  let rx : R := (classical.some (adic_valuation.def._proof_1 x)),
  let sx : non_zero_divisors R := (classical.some (adic_valuation.def._proof_2 x)),
  let ry : R := (classical.some (adic_valuation.def._proof_1 y)),
  let sy : non_zero_divisors R := (classical.some (adic_valuation.def._proof_2 y)),
  have h_frac_xy : is_localization.mk' K rxy sxy = 
    is_localization.mk' K (rx*(sy : R) + ry*(sx : R)) (sx*sy),
  { rw [is_localization.mk'_add, classical.some_spec (adic_valuation.def._proof_2 (x + y)),
    classical.some_spec (adic_valuation.def._proof_2 x),
    classical.some_spec (adic_valuation.def._proof_2 y)] },
  have h_frac_x : is_localization.mk' K rx sx = is_localization.mk' K (rx*(sy : R)) (sx*sy),
  { rw [is_localization.mk'_eq_iff_eq, submonoid.coe_mul, mul_assoc, mul_comm (sy : R) _], },
  have h_frac_y : is_localization.mk' K ry sy = is_localization.mk' K (ry*(sx : R)) (sx*sy),
  { rw [is_localization.mk'_eq_iff_eq, submonoid.coe_mul, mul_assoc], },
  have h_denom : 0 < ring.adic_valuation.def v ↑(sx * sy),
  { rw [ring.adic_valuation.def, dif_neg _], 
    exact with_zero.zero_lt_coe _,
    exact non_zero_divisors.ne_zero
      (submonoid.mul_mem (non_zero_divisors R) sx.property sy.property), },

  rw [adic_valuation.well_defined K v h_frac_x, adic_valuation.well_defined K v h_frac_y,
    adic_valuation.well_defined K v h_frac_xy, with_zero.div_le_div_right (ne_of_gt h_denom),
    with_zero.div_le_div_right (ne_of_gt h_denom), ← le_max_iff],
  exact ring.adic_valuation.map_add' v _ _,
end

--set_option pp.implicit true
def adic_valuation (v : maximal_spectrum R) : valuation K (with_zero (multiplicative ℤ)) := { 
  to_fun    := adic_valuation.def v, 
  map_zero' := adic_valuation.map_zero' v,
  map_one'  := adic_valuation.map_one' v, 
  map_mul'  := adic_valuation.map_mul' v, 
  map_add'  := adic_valuation.map_add' v }

lemma adic_valuation.le_one (x : R) : adic_valuation.def v (algebra_map R K x) ≤ 1 :=
begin
  rw adic_valuation.def,
  dsimp only,
  let rx : R := (classical.some (adic_valuation.def._proof_1 (algebra_map R K x))),
  let sx : non_zero_divisors R := 
  (classical.some (adic_valuation.def._proof_2 (algebra_map R K x))),
  have hx : is_localization.mk' K rx sx = is_localization.mk' K x (1 : non_zero_divisors R),
  { rw is_localization.mk'_one,
    exact classical.some_spec (adic_valuation.def._proof_2 (algebra_map R K x)), },
  rw [adic_valuation.well_defined K v hx, with_zero.div_le_iff 
    (ne_of_gt (ring.adic_valuation.zero_le v 1)),
    one_mul, submonoid.coe_one, ring.adic_valuation.map_one' v],
  exact ring.adic_valuation.le_one v x,
end