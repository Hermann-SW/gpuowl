## mission statement

prothOwL branch should make <kbd>prpll</kbd> process Proth numbers instead of Mersenne numbers

## potential of prothOwL branch

- factor (10:53h/0:51h=)12.8× for only comparing <kbd>proth20</kbd> and <kbd>prpll</kbd> (GPU) runtimes on similar size primes

From t5k.org:
```
 rank  description                     digits   who   year comment
-----  ------------------------------- -------- ----- ---- --------------
...
   23  202705*2^21320516+1              6418121 L5181 2021 
   24  2^20996011-1                     6320430 G6    2003 Mersenne 40
...
```

Runtimes computed on:
```
hermann@7600x:~/gpuowl$ clinfo | grep Inst
  Device Board Name (AMD)                         AMD Instinct MI50/MI60
hermann@7600x:~/gpuowl$ 
```

0:51h ETA for M_40
```
hermann@7600x:~/gpuowl$ build-release/prpll-amd 
20250301 10:35:54  PRPLL de44a09 starting
20250301 10:35:54  device 0, OpenCL 3635.0 (HSA1.1,LC), unique id 'd64a58a17330f0ed'
20250301 10:35:54 20996011 config: 
20250301 10:35:54 20996011 FFT: 1152K 256:9:256:2:0 (17.80 bpw)
20250301 10:35:56 20996011 OK         0 on-load: blockSize 1000, 0000000000000003
20250301 10:35:56 20996011 Proof of power 9 requires about 1.3GB of disk space
20250301 10:35:56 20996011 OK      2000 9383c48226b1e7b8  241 ETA 01:24; Z=172 (avg 171.8)
20250301 10:35:59 20996011        20000 0cd9c21d8fb4b0d4  143
20250301 10:36:02 20996011        40000 47650baaf967e4ea  144
20250301 10:36:05 20996011        60000 a55c4cde3e20beda  144
20250301 10:36:08 20996011        80000 f5e949a36a5e0140  144
20250301 10:36:11 20996011       100000 f3b0103027fcc59b  144
^C20250301 10:36:12 20996011 Stopping, please wait..
20250301 10:36:12 20996011 OK    108000 6623973f1fcd074d  144 ETA 00:50; Z=182 (avg 173.5)
20250301 10:36:12  Exception "stop requested"
20250301 10:36:12  Bye
hermann@7600x:~/gpuowl$ 
```

10:53h ETA for slightly bigger Proth prime "202705*2^21320516+1"
```
hermann@7600x:~/proth20/bin$ ./proth20 -q "202705*2^21320516+1"
proth20 0.9.1 linux64 gcc-11.4.0
Copyright (c) 2020, Yves Gallot
proth20 is free source code, under the MIT license.

0 - device 'gfx906:sramecc+:xnack-', vendor 'Advanced Micro Devices, Inc.', platform 'AMD Accelerated Parallel Processing'.
1 - device 'gfx1036', vendor 'Advanced Micro Devices, Inc.', platform 'AMD Accelerated Parallel Processing'.

Running on device 'gfx906:sramecc+:xnack-', vendor 'Advanced Micro Devices, Inc.', version 'OpenCL 2.0 ' and driver '3635.0 (HSA1.1,LC)'.
60 compUnits @ 1725MHz, mem=16368MB, cache=16kB, cacheLine=64B, localMem=64kB, constMem=14246707kB, maxWorkGroup=256.

Testing 202705 * 2^21320516 + 1, 6418121 digits, size = 2^22 x 19 bits, plan: 64_16 64_16 64_16 sq_16 p2i_16_16
 0.011% done, 10:52:45 remaining, 1.84 ms/mul.        
 0.022% done, 11:59:59 remaining, 2.03 ms/mul.        
 0.033% done, 10:53:03 remaining, 1.84 ms/mul.        
 0.044% done, 11:44:59 remaining, 1.98 ms/mul.        
 0.055% done, 11:08:37 remaining, 1.88 ms/mul.        
^Chermann@7600x:~/proth20/bin$
```

## now possible to process numbers with as low as 118,371 decimal digits

<kbd>prpll</kbd> PRP test for Mersenne primes  
- worked for <kbd>2^786432-1</kbd> and higher exponents
- for exponents below "FFT size too large" exception

Adding <kbd>-fft 256:1:256</kbd> option
- worked for <kbd>2^393216-1</kbd> and higher exponents
- for exponents below "FFT size too large" exception
- warning <kbd>BPW info for 256:1:256 not found</kbd> was logged

Commit [b86e55a](https://github.com/Hermann-SW/gpuowl/commit/b86e55a4e1d1f71bb199a1f44198112c30e64c51) fixed the warning.  
Still lower than 786432 exponents need <kbd>-fft "256:1:256"</kbd> added to work.  
So with this option numbers with more than 118,370 decimal digits can be processed.  

[![Actions Status](https://github.com/preda/gpuowl/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/preda/gpuowl/actions/workflows/ci.yml)

## Must read papers

### Multiplication by FFT

- [Discrete Weighted Transforms and Large Integer Arithmetic](https://www.ams.org/journals/mcom/1994-62-205/S0025-5718-1994-1185244-1/S0025-5718-1994-1185244-1.pdf), Richard Crandall and Barry Fagin, 1994
- [Rapid Multiplication Modulo the Sum And Difference of Highly Composite Numbers](https://www.daemonology.net/papers/fft.pdf), Colin Percival, 2002

### P-1

- [An FFT Extension to the P-1 Factoring Algorithm](https://www.ams.org/journals/mcom/1990-54-190/S0025-5718-1990-1011444-3/S0025-5718-1990-1011444-3.pdf), Montgomerry & Silverman, 1990
- [Improved Stage 2 to P+/-1 Factoring Algorithms](https://inria.hal.science/inria-00188192v3/document), Montgomerry & Kruppa, 2008


# PRPLL

## PRobable Prime and Lucas-Lehmer mersenne categorizer
(pronounced *purrple categorizer*)

PRPLL implements two primality tests for Mersenne numbers: PRP ("PRobable Prime") and LL ("Lucas-Lehmer") as the name suggests.

PRPLL is an OpenCL (GPU) program for primality testing Mersenne numbers.


## Build

Invoke `make` in the source directory.


## Use
See `prpll -h` for the command line options.


## Why LL

For Mersenne primes search, the PRP test is by far preferred over LL, such that LL is not used anymore for search.
But LL is still used to verify a prime found by PRP (which is a very rare occurence).


### Lucas-Lehmer (LL)
This is a test that proves whether a Mersenne number is prime or not, but without providing a factor in the case where it is not prime.
The Lucas-Lehmer test is very simple to describe: iterate the function f(x)=(x^2 - 2) modulo M(p) starting with the number 4. If
after p-2 iterations the result is 0, then M(p) is certainly prime, otherwise M(p) is certainly not prime.

Lucas-Lehmer, while a very efficient primality test, still takes a rather long time for large Mersenne numbers
(on the order of weeks of intense compute), thus it is only applied to the Mersenne candidates that survived the cheaper preliminary
filters TF and P-1.

### PRP
The probable prime test can prove that a candidate is composite (without providing a factor), but does not prove that a candidate
is prime (only stating that it _probably_ is prime) -- although in practice the difference between probable prime and proved
prime is extremely small for large Mersenne candidates.

The PRP test is very similar computationally to LL: PRP iterates f(x) = x^2 modulo M(p) starting from 3. If after p iterations the result is 9 modulo M(p), then M(p) is probably prime, otherwise M(p) is certainly not prime. The cost
of PRP is exactly the same as LL.
