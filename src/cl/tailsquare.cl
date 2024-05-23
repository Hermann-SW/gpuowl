// Copyright (C) Mihai Preda and George Woltman

#include "tailutil.cl"
#include "trig.cl"
#include "fftheight.cl"

// Why does this alternate implementation work?  Let t' be the conjugate of t and note that t*t' = 1.
// Now consider these lines from the original implementation (comments appear alongside):
//      b = mul_by_conjugate(b, t); 			bt'
//      X2(a, b);					a + bt', a - bt'
//      a = sq(a);					a^2 + 2abt' + (bt')^2
//      b = sq(b);					a^2 - 2abt' + (bt')^2
//      X2(a, b);					2a^2 + 2(bt')^2, 4abt'
//      b = mul(b, t);					                 4ab

void onePairSq(T2* pa, T2* pb, T2 conjugate_t_squared) {
  T2 a = *pa;
  T2 b = *pb;

  X2conjb(a, b);

  T2 tmp = a;
  a = sqa(a, mul(sq(b), conjugate_t_squared));
  b = 2 * mul(tmp, b);

  X2conja(a, b);

  *pa = a;
  *pb = b;
}

void pairSq(u32 N, T2 *u, T2 *v, T2 base_squared, bool special) {
  u32 me = get_local_id(0);

  for (i32 i = 0; i < NH / 4; ++i, base_squared = mul_t8(base_squared)) {
    if (special && i == 0 && me == 0) {
      u[i] = 2 * foo(conjugate(u[i]));
      v[i] = 4 * sq(conjugate(v[i]));
    } else {
      onePairSq(&u[i], &v[i], -base_squared);
    }

    if (N == NH) {
      onePairSq(&u[i+NH/2], &v[i+NH/2], base_squared);
    }

    // T2 new_base_squared = mul(base_squared, U2(0, -1));
    T2 new_base_squared = U2(base_squared.y, -base_squared.x);
    onePairSq(&u[i+NH/4], &v[i+NH/4], -new_base_squared);

    if (N == NH) {
      onePairSq(&u[i+3*NH/4], &v[i+3*NH/4], new_base_squared);
    }
  }
}

KERNEL(G_H) tailSquare(P(T2) out, CP(T2) in, Trig smallTrig, BigTab tailTrig) {
  local T2 lds[SMALL_HEIGHT / 2];

  T2 u[NH], v[NH];

  // u32 W = SMALL_HEIGHT;
  u32 H = ND / SMALL_HEIGHT;

  u32 line1 = get_group_id(0);
  u32 line2 = line1 ? H - line1 : (H / 2);
  u32 memline1 = transPos(line1, MIDDLE, WIDTH);
  u32 memline2 = transPos(line2, MIDDLE, WIDTH);

  readTailFusedLine(in, u, line1);
  readTailFusedLine(in, v, line2);
  fft_HEIGHT(lds, u, smallTrig);
  bar();
  fft_HEIGHT(lds, v, smallTrig);

  u32 me = get_local_id(0);

  if (line1 == 0) {
#if 0 && !TAIL_TABLE
    T2 trig1 = slowTrig_N(me * H, ND / NH, NULL);     // slowTrig_2SH(2 * me, SMALL_HEIGHT / 2, TRIG_2SH)
    T2 trig2 = slowTrig_N(H/2 + me * H, ND/NH, NULL); // slowTrig_2SH(1 + 2 * me, SMALL_HEIGHT / 2, TRIG_2SH)
#else
    T2 trigMe   = tailTrig[me];
    T2 trigLine = tailTrig[G_H + line1];
    T2 trig1 = trigMe;
    T2 trig2 = fancyMulTrig(trigMe, trigLine);
#endif

    // Line 0 is special: it pairs with itself, offseted by 1.
    reverse(G_H, lds, u + NH/2, true);
    pairSq(NH/2, u,   u + NH/2, trig1, true);
    reverse(G_H, lds, u + NH/2, true);

    // Line H/2 also pairs with itself (but without offset).
    reverse(G_H, lds, v + NH/2, false);
    pairSq(NH/2, v,   v + NH/2, trig2, false);
    reverse(G_H, lds, v + NH/2, false);
  } else {    
    reverseLine(G_H, lds, v);

#if !TAIL_TABLE
    T2 trig = slowTrig_N(line1 + me * H, ND / NH, NULL);
#else
    T2 trigMe   = tailTrig[me];
    T2 trigLine = tailTrig[G_H + line1];
    T2 trig = fancyMulTrig(trigMe, trigLine);
    // tailTrig[line1 * G_H + me]
#endif
    pairSq(NH, u, v, trig, false);
    reverseLine(G_H, lds, v);
  }

  bar();
  fft_HEIGHT(lds, v, smallTrig);
  bar();
  fft_HEIGHT(lds, u, smallTrig);
  write(G_H, NH, v, out, memline2 * SMALL_HEIGHT);
  write(G_H, NH, u, out, memline1 * SMALL_HEIGHT);
}
