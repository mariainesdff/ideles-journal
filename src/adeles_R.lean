import valuation
import ring_theory.valuation.integers

noncomputable theory
open_locale classical
open function set

variables {R : Type} {K : Type} [comm_ring R] [is_domain R] [is_dedekind_domain R] [field K]
  [algebra R K] [is_fraction_ring R K] (v : maximal_spectrum R)

instance v_valued_K (v : maximal_spectrum R) : valued K := 
{ Γ₀  := with_zero (multiplicative ℤ),
  grp := infer_instance,
  v   := adic_valuation v }

instance ts' : topological_space K := @valued.topological_space K _ (v_valued_K v)
instance tdr' : @topological_division_ring K _ (ts' v) := 
@valued.topological_division_ring K _ (v_valued_K v)
instance tr' : @topological_ring K  (ts' v) _ := infer_instance
instance tg' : @topological_add_group K (ts' v) _ := infer_instance
instance us' : uniform_space K := @topological_add_group.to_uniform_space K _ (ts' v) (tg' v)
instance ug' : @uniform_add_group K (us' v) _ := 
@topological_add_group_is_uniform K _ (ts' v) (tg' v)
instance cf' : @completable_top_field K _ (us' v) := @valued.completable K _ (v_valued_K v)

instance ss : @separated_space K (us' v) := @valued_ring.separated K _ (v_valued_K v)

variables (K)
def K_v := @uniform_space.completion K (us' v)
instance : field (K_v K v) := @field_completion K _ (us' v) (tdr' v) _ (ug' v) (tr' v)
instance : division_ring (K_v K v) := infer_instance
instance : comm_ring (K_v K v) := infer_instance

variables {K}
instance valued_K_v : valued (K_v K v) := 
{ Γ₀  := with_zero (multiplicative ℤ),
  grp := infer_instance,
  v   := @valued.extension_valuation K _ (v_valued_K v) }

--TODO : ask
instance : covariant_class (valued.Γ₀ (K_v K v)) (valued.Γ₀ (K_v K v)) has_mul.mul has_le.le :=
ordered_comm_monoid.to_covariant_class_left _

instance ts : topological_space (K_v K v) := @valued.topological_space (K_v K v) _ (valued_K_v v)
instance tdr : @topological_division_ring (K_v K v) _ (ts v) := 
@valued.topological_division_ring (K_v K v) _ (valued_K_v v)
instance tr : @topological_ring (K_v K v) (ts v) _ := (tdr v).to_topological_ring
instance tg : @topological_add_group (K_v K v) (ts v) _ := 
@topological_ring.to_topological_add_group (K_v K v) _ (ts v) (tr v)
instance us : uniform_space (K_v K v) := 
@topological_add_group.to_uniform_space (K_v K v) _ (ts v) (tg v)
instance ug : @uniform_add_group (K_v K v) (us v) _ := 
@topological_add_group_is_uniform (K_v K v) _ (ts v) (tg v)

instance : has_lift_t K (@uniform_space.completion K (us' v)) := infer_instance
instance R_v.has_lift_t : has_lift_t K (K_v K v) := uniform_space.completion.has_lift_t v

variables (K)
def R_v : subring (K_v K v) := 
@valuation.integer (K_v K v) (with_zero (multiplicative ℤ)) _ _ (valued_K_v v).v 

instance : topological_space (R_v K v) := infer_instance
--instance : topological_ring (R_v K v)  := 

-- Finite adele ring of R
variables (R)
def R_hat := (Π (v : maximal_spectrum R), (R_v K v))
instance : comm_ring (R_hat R K) := pi.comm_ring
instance : topological_space (R_hat R K) := Pi.topological_space
--instance tr_hat' : topological_ring (Π (v : maximal_spectrum R), (R_v K v)) := pi.topological_ring
--instance : topological_ring (R_hat R K) := tr_hat' R K

def K_hat := (Π (v : maximal_spectrum R), (K_v K v))

instance : comm_ring (K_hat R K) := pi.comm_ring
instance : ring (K_hat R K) := infer_instance
instance : topological_space (K_hat R K) := Pi.topological_space
instance tr_hat : topological_ring (Π (v : maximal_spectrum R), (K_v K v)) := pi.topological_ring
instance : topological_ring (K_hat R K) := tr_hat  R K


lemma valuation.is_integer {R : Type*} {Γ₀ : Type*} [ring R]
  [linear_ordered_comm_group_with_zero Γ₀] (v : valuation R Γ₀) (x : R):
x ∈ valuation.integer v ↔ v(x) ≤ 1 := 
begin
   rw ← subring.mem_carrier,
   refl,
end

lemma K_v.is_integer (x : K_v K v) : x ∈ R_v K v ↔ valued.v x ≤ 1 := 
by { rw R_v, exact valuation.is_integer _ _,}

def inj_R_v' : R → (K_v K v) := λ r, (coe : K → (K_v K v)) (algebra_map R K r)
def inj_R_v : R → (R_v K v) := λ r, ⟨(coe : K → (K_v K v)) (algebra_map R K r), begin 
  change @valued.extension K _ (v_valued_K v) (algebra_map R K r) ≤ 1, --need a coe_to_fun?
  rw @valued.extension_extends K _ (v_valued_K v) (algebra_map R K r),
  exact adic_valuation.le_one v _,
end⟩
def inj_R : R → (R_hat R K) := λ r v, inj_R_v R K v r

-- TODO : PR
lemma uniform_space.completion.injective_coe {α : Type*} [uniform_space α]
[separated_space α] : 
  injective  (coe : α → uniform_space.completion α) := 
begin
  exact @uniform_embedding.inj _ _ _ _ coe 
      (uniform_space.completion.uniform_embedding_coe _),
end

lemma inj_R_v.injective : function.injective (inj_R_v R K v) :=
begin
  intros x y hxy,
  have h_inj : function.injective (coe : K → (K_v K v)) :=
    @uniform_space.completion.injective_coe K (us' v) (ss v),
  rw [inj_R_v, subtype.mk_eq_mk] at hxy,
  exact (is_fraction_ring.injective R K) ((h_inj) hxy),
end

lemma inj_R_v.map_one : inj_R_v R K v 1 = 1 :=  by { rw inj_R_v, simp_rw ring_hom.map_one, refl, }
lemma inj_R.map_one : inj_R R K 1 = 1 := 
by { rw inj_R, ext v, simp_rw inj_R_v.map_one R K v, refl, }

lemma inj_R_v.map_mul (x y : R): inj_R_v R K v (x*y) = (inj_R_v R K v x) * (inj_R_v R K v y) :=
begin
  rw inj_R_v,
  simp_rw ring_hom.map_mul,
  ext,
  rw [subtype.coe_mk, subring.coe_mul, subtype.coe_mk, subtype.coe_mk,
    uniform_space.completion.coe_mul],
end

lemma inj_R.map_mul (x y : R): inj_R R K (x*y) = (inj_R R K x) * (inj_R R K y) :=
by { rw inj_R, ext v, apply congr_arg _ (inj_R_v.map_mul R K v x y), }

def diag_R : submonoid (R_hat R K) := 
{ carrier  := (inj_R R K) '' set.compl {0},
  one_mem' :=  ⟨1, set.mem_compl_singleton_iff.mpr one_ne_zero, inj_R.map_one R K⟩,
  mul_mem' := 
  begin
    rintros a b ⟨za, hza, rfl⟩ ⟨zb, hzb, rfl⟩,
    exact ⟨za*zb, mul_ne_zero hza hzb, inj_R.map_mul R K za zb⟩,
  end }

def finite_adele_ring := localization (diag_R R K)
instance : comm_ring (finite_adele_ring R K) := localization.comm_ring
instance : algebra (R_hat R K) (finite_adele_ring R K) := localization.algebra
instance : is_localization (diag_R R K) (finite_adele_ring R K):= localization.is_localization

lemma preimage_diag_R (x : diag_R R K) : ∃ r : R, r ≠ 0 ∧ inj_R R K r = (x : R_hat R K) := 
x.property

def finite_adele_ring' :=
{ x : (Π v : (maximal_spectrum R), K_v K v) //
  ∀ᶠ (v : maximal_spectrum R) in filter.cofinite, (x v ∈ R_v K v) }

lemma restr_add (x y : finite_adele_ring' R K) : ∀ᶠ (v : maximal_spectrum R) in filter.cofinite,
  ((x.val + y.val) v ∈ R_v K v) := 
begin
  cases x with x hx,
  cases y with y hy,
  rw filter.eventually_cofinite at hx hy ⊢,
  have h_subset : {v : maximal_spectrum R | ¬ (x + y) v ∈  (R_v K v)} ⊆
    {v : maximal_spectrum R | ¬ x v ∈ (R_v K v)} ∪ {v : maximal_spectrum R | ¬ y v ∈ (R_v K v)},
  { intros v hv,
    rw [mem_union, mem_set_of_eq, mem_set_of_eq],
    rw mem_set_of_eq at hv,
    by_contradiction h,
    push_neg at h,
    apply hv,
    rw [K_v.is_integer, K_v.is_integer, ← max_le_iff] at h,
    rw [K_v.is_integer, pi.add_apply],
    exact le_trans (valued.v.map_add' (x v) (y v)) h },
  exact finite.subset (finite.union hx hy) h_subset,
end

def add' (x y : finite_adele_ring' R K) : finite_adele_ring' R K := 
⟨x.val + y.val, restr_add R K x y⟩

lemma restr_zero : ∀ᶠ (v : maximal_spectrum R) in filter.cofinite,
  ((0 : K_v K v) ∈ R_v K v) := 
begin
  rw filter.eventually_cofinite,
  have h_empty : {v : maximal_spectrum R | ¬ ((0 : K_v K v) ∈ R_v K v)} = ∅,
  { ext v, rw mem_empty_eq, split; intro hv,
    { rw mem_set_of_eq at hv, apply hv, rw K_v.is_integer, 
      have h_zero : valued.v (0 : K_v K v) = 0 := valued.v.map_zero',
      rw h_zero, exact zero_le_one' },
    { exfalso, exact hv }},
  rw h_empty,
  exact finite_empty,
end

lemma restr_neg (x : finite_adele_ring' R K)  : ∀ᶠ (v : maximal_spectrum R) in filter.cofinite,
  (-x.val v ∈ R_v K v) := 
begin
  cases x with x hx,
  have h : ∀ (v : maximal_spectrum R), (-x v ∈ R_v K v) ↔ (x v ∈ R_v K v),
  { intro v,
    rw [K_v.is_integer, K_v.is_integer, valuation.map_neg], },
  simp_rw h,
  exact hx,
end

def neg' (x : finite_adele_ring' R K) : finite_adele_ring' R K := ⟨-x.val, restr_neg R K x⟩

lemma restr_mul (x y : finite_adele_ring' R K) : ∀ᶠ (v : maximal_spectrum R) in filter.cofinite,
  ((x.val * y.val) v ∈ R_v K v) := 
begin
  cases x with x hx,
  cases y with y hy,
  rw filter.eventually_cofinite at hx hy ⊢,
  have h_subset : {v : maximal_spectrum R | ¬ (x * y) v ∈  (R_v K v)} ⊆
    {v : maximal_spectrum R | ¬ x v ∈ (R_v K v)} ∪ {v : maximal_spectrum R | ¬ y v ∈ (R_v K v)},
  { intros v hv,
    rw [mem_union, mem_set_of_eq, mem_set_of_eq],
    rw mem_set_of_eq at hv,
    by_contradiction h,
    push_neg at h,
    apply hv,
    rw [K_v.is_integer, K_v.is_integer] at h,
    have h_mul : valued.v (x v * y v) = (valued.v (x v)) * (valued.v (y v)) 
    := (valued.v).map_mul' (x v) (y v),
    rw [K_v.is_integer, pi.mul_apply, h_mul, ← mul_one (1 : with_zero (multiplicative ℤ ))],
    exact @mul_le_one' (valued.Γ₀ (K_v K v)) _ _ 
      (ordered_comm_monoid.to_covariant_class_left _) _ _ _ h.left h.right,  }, --TODO : ask
  exact finite.subset (finite.union hx hy) h_subset,
end

def mul' (x y : finite_adele_ring' R K) : finite_adele_ring' R K := 
⟨x.val * y.val, restr_mul R K x y⟩

lemma restr_one : ∀ᶠ (v : maximal_spectrum R) in filter.cofinite,
  ((1 : K_v K v) ∈ R_v K v) := 
begin
  rw filter.eventually_cofinite,
  have h_empty : {v : maximal_spectrum R | ¬ ((1 : K_v K v) ∈ R_v K v)} = ∅,
  { ext v, rw mem_empty_eq, split; intro hv,
    { rw mem_set_of_eq at hv, apply hv, rw K_v.is_integer, 
      exact le_of_eq valued.v.map_one' },
    { exfalso, exact hv }},
  rw h_empty,
  exact finite_empty,
end

instance : add_comm_group (finite_adele_ring' R K) := 
{ add          := add' R K,
  add_assoc    := λ ⟨x, hx⟩ ⟨y, hy⟩ ⟨z, hz⟩,
  by { dsimp only [add'], rw [subtype.mk_eq_mk], exact add_assoc _ _ _, },
  zero         := ⟨0, restr_zero R K⟩,
  zero_add     := λ x, by { simp_rw [add', zero_add, subtype.val_eq_coe, subtype.coe_eta] },
  add_zero     := λ x, by { simp_rw [add', add_zero, subtype.val_eq_coe, subtype.coe_eta] },
  neg          := λ x, ⟨-x.val, restr_neg R K x⟩,
  add_left_neg := λ x, by { unfold_projs,  dsimp only [add'], ext, 
    rw [subtype.coe_mk, subtype.coe_mk, pi.add_apply, add_left_neg], refl, },
  add_comm     := λ x y, by { unfold_projs,  dsimp only [add'], ext, 
    rw [subtype.coe_mk, subtype.coe_mk, pi.add_apply, pi.add_apply, add_comm], }}

instance : comm_ring (finite_adele_ring' R K) := 
{ mul           := mul' R K,
  mul_assoc     := λ x y z, by { unfold_projs, simp_rw [mul'], 
    rw [subtype.mk_eq_mk, mul_assoc]},
  one           := ⟨1, restr_one R K⟩,
  one_mul       := λ x, by { simp_rw [mul', one_mul, subtype.val_eq_coe, subtype.coe_eta] },
  mul_one       := λ x, by { simp_rw [mul', mul_one, subtype.val_eq_coe, subtype.coe_eta] },
  left_distrib  := λ x y z, by { unfold_projs, simp_rw [mul', add', left_distrib], },
  right_distrib := λ x y z, by { unfold_projs, simp_rw [mul', add', right_distrib], },
  mul_comm      := λ x y, by { unfold_projs, rw [mul', mul', subtype.mk_eq_mk, mul_comm], },
  ..(finite_adele_ring'.add_comm_group R K)}

instance : comm_ring { x : (Π v : (maximal_spectrum R), K_v K v) //
  ∀ᶠ (v : maximal_spectrum R) in filter.cofinite, (x v ∈ R_v K v) } := 
finite_adele_ring'.comm_ring R K

lemma mul_apply (x y : finite_adele_ring' R K) :  
(⟨x.val * y.val, restr_mul R K x y⟩ : finite_adele_ring' R K) = x * y := rfl
lemma mul_apply_val (x y : finite_adele_ring' R K) :  
x.val * y.val = (x * y).val := rfl

--def foo : @subring (K_hat R K) (K_hat.ring R K) := sorry

def group_hom_prod : add_monoid_hom (R_hat R K) (K_hat R K) := 
{ to_fun    := (λ x v, (x v)),
  map_zero' := rfl,
  map_add'  := λ x y, by { ext v, rw [pi.add_apply, pi.add_apply, subring.coe_add], }}

def hom_prod : ring_hom (R_hat R K) (K_hat R K)  := 
{ to_fun   := (λ x v, x v),
  map_one' := rfl,
  map_mul' := λ x y, by {ext p, rw [pi.mul_apply, pi.mul_apply, subring.coe_mul], },
  ..group_hom_prod R K }

lemma hom_prod_diag_unit : ∀ x : (diag_R R K), is_unit (hom_prod R K x) :=
begin
  rintro ⟨x, r, hr, hrx⟩,
  rw [is_unit_iff_exists_inv, subtype.coe_mk],
  use (λ v : maximal_spectrum R, 1/(x v : K_v K v)),
  ext v,
  rw [hom_prod, ring_hom.coe_mk, pi.mul_apply, pi.one_apply, ← mul_div_assoc, mul_one, 
  div_self],
  rw  [ne.def, subring.coe_eq_zero_iff, ← hrx, inj_R],
  simp only [inj_R_v], 
  have h : (0 : K_v K v) ∈ R_v K v,
  { rw [K_v.is_integer R K, valuation.map_zero], exact zero_le_one',},
  have h_zero : (0 : R_v K v) = ⟨(0 : K_v K v), h⟩ := rfl,
  have h_inj : function.injective (coe : K → (K_v K v)) :=
    @uniform_space.completion.injective_coe K (us' v) (ss v),
  rw [h_zero, subtype.mk_eq_mk, ← uniform_space.completion.coe_zero, 
    ← (algebra_map R K).map_zero, ← ne.def, 
    injective.ne_iff (injective.comp h_inj (is_fraction_ring.injective R K))],
  rw [compl_eq_compl, mem_compl_eq, mem_singleton_iff] at hr,
  exact hr,
end

def map_to_K_hat (x : finite_adele_ring R K) : K_hat R K := 
is_localization.lift (hom_prod_diag_unit R K) x

lemma finite_factors (d : R) (hd : (ideal.span{d} : ideal R) ≠ 0) : 
  finite { v : maximal_spectrum R | v.val.as_ideal ∣ (ideal.span({d}) : ideal R)} := 
  begin
  haveI h_fin := unique_factorization_monoid.fintype_subtype_dvd (ideal.span({d}) : ideal R) hd,
  let f' : finset (ideal R) := finset.map 
    ⟨(λ I : {x // x ∣ (ideal.span {d} : ideal R)}, I.val), subtype.coe_injective⟩
    h_fin.elems,
  have h_eq : { v : maximal_spectrum R | v.val.as_ideal ∣ (ideal.span({d}) : ideal R)} = 
    { v : maximal_spectrum R | v.val.as_ideal ∈ f' },
  { ext v,
    rw [mem_set_of_eq, mem_set_of_eq, finset.mem_map], 
    simp_rw exists_prop,
    rw [subtype.exists, embedding.coe_fn_mk],
    simp_rw [exists_and_distrib_right, exists_eq_right],
    split,
    { intro h, use h, exact fintype.complete ⟨v.val.as_ideal, h⟩},
    { intro h, obtain ⟨hv, -⟩ := h, exact hv, }},    
  rw h_eq,
  have hv : ∀ v : maximal_spectrum R, v.val.as_ideal = v.val.val := λ v, rfl,
  have hv_inj : injective (λ (v : maximal_spectrum R), v.val.as_ideal),
  { intros v w hvw, 
    dsimp only at hvw,
    rw [hv v, hv w] at hvw,
    ext, 
    rw [← subtype.val_eq_coe, ← subtype.val_eq_coe, ← subtype.val_eq_coe, 
      ← subtype.val_eq_coe, hvw],},
  exact finite.preimage_embedding ⟨(λ v : maximal_spectrum R, v.val.as_ideal), hv_inj⟩
    (finite_mem_finset (f')),
end

variable {R}
lemma ring.adic_valuation_le_one_iff_dvd {v : maximal_spectrum R} {d : R} (hd : d ≠ 0) :
ring.adic_valuation.def v d < 1 ↔ v.val.as_ideal ∣ ideal.span{d} := 
begin 
  rw [ring.adic_valuation.def, dif_neg hd, ← with_zero.coe_one, with_zero.coe_lt_coe, 
  ← of_add_zero, of_add_lt, neg_lt_zero, ← int.coe_nat_zero, int.coe_nat_lt,
  nat.lt_iff_add_one_le, zero_add, ← associates.prime_pow_dvd_iff_le, pow_one _, 
  associates.mk_le_mk_iff_dvd_iff],
  apply associates.mk_ne_zero'.mpr hd,
  { apply associates.irreducible_of_maximal v },
end
variable (R)
lemma restricted_image (x : finite_adele_ring R K) : 
  set.finite({ v : maximal_spectrum R | ¬ (map_to_K_hat R K x v) ∈ (R_v K v)}) :=
begin
  set supp := { v : maximal_spectrum R | ¬ (map_to_K_hat R K x v) ∈ (R_v K v)} with h_supp,
  obtain ⟨r, d', hx⟩ := is_localization.mk'_surjective (diag_R R K) x,
  obtain ⟨d, hd_ne_zero, hd_inj⟩ := d'.property,
  have hd : ideal.span{d} ≠ (0 : ideal R),
  { rw [ideal.zero_eq_bot, ne.def, ideal.span_singleton_eq_bot],
    exact hd_ne_zero, },
  obtain ⟨f, h_irred, h_assoc⟩:= wf_dvd_monoid.exists_factors (ideal.span{d}) hd,
  have hsubset : supp ⊆ { v : maximal_spectrum R | v.val.as_ideal ∣ ideal.span({d})},
  { rw h_supp,
    intros v hv,
    rw mem_set_of_eq at hv ⊢,
    rw [map_to_K_hat, ← hx] at hv,

    --rw is_fraction_ring.lift_mk' at hv,
    --rw [is_localization.lift_mk', pi.mul_apply] at hv,
    have h2 : ((hom_prod R K).to_monoid_hom.mrestrict _) d' v = ((d' : R_hat R K) v),
    { /- rw [monoid_hom.mrestrict_apply, ring_hom.to_monoid_hom_eq_coe, set_like.coe_mk, hom_prod,
      ring_hom.coe_monoid_hom_mk, monoid_hom.coe_mk], -/
      sorry,
    },
    --simp only [monoid_hom.mrestrict_apply, ring_hom.coe_monoid_hom, ring_hom.to_monoid_hom_eq_coe, subtype.val_eq_coe] at h2,
    --rw h2 at hv,
    sorry },
  exact finite.subset (finite_factors R d hd) hsubset,
end 

lemma map_to_K_hat.map_one : map_to_K_hat R K 1 = 1 := 
by { rw [map_to_K_hat, ring_hom.map_one] }

lemma map_to_K_hat.map_mul (x y : finite_adele_ring R K) : map_to_K_hat R K (x*y) = map_to_K_hat R K x * map_to_K_hat R K y := 
by { rw [map_to_K_hat, map_to_K_hat, map_to_K_hat, ring_hom.map_mul], }

lemma map_to_K_hat.map_add (x y : finite_adele_ring R K) : map_to_K_hat R K (x + y) = map_to_K_hat R K x + map_to_K_hat R K y := 
by { rw [map_to_K_hat, map_to_K_hat, map_to_K_hat, ring_hom.map_add], }

lemma map_to_K_hat.map_zero : map_to_K_hat R K 0 = 0 := 
by { rw [map_to_K_hat, ring_hom.map_zero] }

def finite_adele.hom : (finite_adele_ring R K) →+* (finite_adele_ring' R K) := 
{ to_fun    := λ x, ⟨(map_to_K_hat R K x), restricted_image R K x⟩,
  map_one'  := begin
    have h_one : (1 : finite_adele_ring' R K) = ⟨1, restr_one R K⟩ := rfl,
    rw [h_one, subtype.mk_eq_mk],
    exact map_to_K_hat.map_one R K,
  end,
  map_mul'  := λ x y,
  by { unfold_projs, simp only [mul'], exact subtype.mk_eq_mk.mpr (map_to_K_hat.map_mul R K x y) },
  map_zero' := begin
    have h_zero : (0 : finite_adele_ring' R K) = ⟨0, restr_zero R K⟩ := rfl,
    rw [h_zero, subtype.mk_eq_mk],
    exact map_to_K_hat.map_zero R K,
  end,
  map_add'  := λ x y,
  by { unfold_projs, simp only [add'], exact subtype.mk_eq_mk.mpr (map_to_K_hat.map_add R K x y) }}
  
def finite_adele.inv : (finite_adele_ring' R K) →+* (finite_adele_ring R K) := 
{ to_fun    := sorry,
  map_one'  := sorry,
  map_mul'  := sorry,
  map_zero' := sorry,
  map_add'  := sorry }

lemma finite_adele.hom_inv_id : 
  (finite_adele.inv R K).comp (finite_adele.hom R K) = ring_hom.id (finite_adele_ring R K) := sorry

lemma finite_adele.inv_hom_id :
  (finite_adele.hom R K).comp (finite_adele.inv R K) = ring_hom.id (finite_adele_ring' R K) := sorry

def finite_adele.eq_defs : ring_equiv (finite_adele_ring R K) (finite_adele_ring' R K) :=
  ring_equiv.of_hom_inv (finite_adele.hom R K) (finite_adele.inv R K)
    (finite_adele.hom_inv_id R K) (finite_adele.inv_hom_id R K)


lemma inj_K_image (x : K) : 
  set.finite({ v : maximal_spectrum R | ¬ (coe : K → (K_v K v)) x ∈ (R_v K v)}) := 
begin
  set supp := { v : maximal_spectrum R | ¬ (coe : K → (K_v K v)) x ∈ (R_v K v)} with h_supp,
  obtain ⟨r, ⟨d, hd⟩, hx⟩ := is_localization.mk'_surjective (non_zero_divisors R) x,
  have hd_ne_zero : ideal.span{d} ≠ (0 : ideal R),
  { rw [ideal.zero_eq_bot, ne.def, ideal.span_singleton_eq_bot],
    apply non_zero_divisors.ne_zero hd, },
  obtain ⟨f, h_irred, h_assoc⟩:= wf_dvd_monoid.exists_factors (ideal.span{d}) hd_ne_zero,
  have hsubset : supp ⊆ { v : maximal_spectrum R | v.val.as_ideal ∣ ideal.span({d})},
  { rw h_supp,
    intros v hv,
    rw mem_set_of_eq at hv ⊢,
    have h_val : valued.v ((coe : K → (K_v K v)) x) = @valued.extension K _ (v_valued_K v) x := rfl,
    rw [K_v.is_integer, h_val, valued.extension_extends _] at hv,
    simp only [valued.v] at hv,
    have : (adic_valuation v) x = adic_valuation.def v x := rfl,
    rw this at hv,
    rw adic_valuation.def at hv,
    let sx : non_zero_divisors R := (classical.some (adic_valuation.def._proof_2 x)),
    have h_loc : is_localization.mk' K (classical.some (adic_valuation.def._proof_1 x)) sx
       = is_localization.mk' K r ⟨d, hd⟩,
    { rw hx, exact (classical.some_spec (adic_valuation.def._proof_2 x)) },
      dsimp only at hv,
      rw ← ring.adic_valuation_le_one_iff_dvd (non_zero_divisors.ne_zero hd),
      by_contradiction h_one_le,
      rw [adic_valuation.well_defined K v h_loc, subtype.coe_mk,
        (le_antisymm (ring.adic_valuation.le_one v d) (not_lt.mp h_one_le)), div_one] at hv,
      exact hv (ring.adic_valuation.le_one v r) },
  exact finite.subset (finite_factors R d hd_ne_zero) hsubset,
end

def inj_K : K → finite_adele_ring' R K := 
λ x, ⟨(λ v : maximal_spectrum R, (coe : K → (K_v K v)) x), inj_K_image R K x⟩

@[simp]
lemma inj_K.map_zero : inj_K R K 0 = 0 := by { rw inj_K, ext v, rw [subtype.coe_mk], refl }

@[simp]
lemma inj_K.map_add (x y : K) : inj_K R K (x + y) = (inj_K R K x) + (inj_K R K y) := 
begin
  rw inj_K, ext v, unfold_projs, simp only [add'],
  rw [subtype.coe_mk, subtype.coe_mk, pi.add_apply], 
  norm_cast,
end

@[simp]
lemma inj_K.map_one : inj_K R K 1 = 1 := by { rw inj_K, ext v, rw [subtype.coe_mk], refl }

@[simp]
lemma inj_K.map_mul (x y : K) : inj_K R K (x*y) = (inj_K R K x) * (inj_K R K y) := 
begin
  rw inj_K, ext v, unfold_projs, simp only [mul'],
  rw [subtype.coe_mk, subtype.coe_mk, pi.mul_apply], 
  norm_cast,
end

def inj_K.add_group_hom : add_monoid_hom K (finite_adele_ring' R K) := 
{ to_fun    := inj_K R K,
  map_zero' := inj_K.map_zero R K,
  map_add'  := inj_K.map_add R K, }

def inj_K.ring_hom : ring_hom K (finite_adele_ring' R K)  := 
{ to_fun   := inj_K R K,
  map_one' := inj_K.map_one R K,
  map_mul' := inj_K.map_mul R K,
  ..inj_K.add_group_hom R K }

-- We need to assume that the maximal spectrum of R is nonempty (i.e., R is not a field) for this to
-- work 
lemma inj_K.injective [inh : inhabited (maximal_spectrum R)] : injective (inj_K.ring_hom R K) :=
begin
  rw ring_hom.injective_iff,
  intros x hx,
  rw [inj_K.ring_hom, ring_hom.coe_mk, inj_K] at hx,
  dsimp only at hx,
  unfold_projs at hx,
  rw [subtype.mk_eq_mk] at hx,
  let v : maximal_spectrum R := inh.default,
  have hv := congr_fun hx v,
  dsimp only at hv,
  have h_inj : function.injective (coe : K → (K_v K v)) :=
    @uniform_space.completion.injective_coe K (us' v) (ss v),
  apply h_inj hv,
end