## Immense potential of genFerOwL branch

- factor 3.5× for only comparing geneferg and prpll runtimes on similar size primes
- but the number of loops for genFerOwL branch is 24036583/1048576=22.9× smaller as well
- can ETA of 1:02h/22.9=2:42min for <kbd>3843236^1048576+1</kbd> be real?
  (would be 79.6× speedup ...)


From t5k.org:
```
...
   17  2^24036583-1                     7235733 G7    2004 Mersenne 41
   18  107347*2^23427517-1              7052391 A2    2024 
   19c 3843236^1048576+1                6904556 L6094 2024 Generalized Fermat
...
```

Runtimes computed on:
```
hermann@7600x:~/gpuowl$ clinfo | grep Inst
  Device Board Name (AMD)                         AMD Instinct MI50/MI60
hermann@7600x:~/gpuowl$ 
```

(2:35min+0:59h=)1:02h ETA for M_41
```
hermann@7600x:~/gpuowl$ build-release/prpll-amd 
20250227 15:40:56  PRPLL de44a09 starting
20250227 15:40:56  device 0, OpenCL 3635.0 (HSA1.1,LC), unique id 'd64a58a17330f0ed'
20250227 15:40:57 24036583 config: 
20250227 15:40:57 24036583 FFT: 1.25M 512:5:256:0:0 (18.34 bpw)
20250227 15:40:58 24036583 OK         0 on-load: blockSize 1000, 0000000000000003
20250227 15:40:58 24036583 Proof of power 9 requires about 1.5GB of disk space
20250227 15:40:59 24036583 OK      2000 3cb2d899b8b75158  266 ETA 01:46; Z=64 (avg 63.5)
20250227 15:41:02 24036583        20000 f3c44af4cfadbfe0  152
...
20250227 15:43:28 24036583       980000 b2ebc6858bf43b89  153
20250227 15:43:31 24036583 OK   1000000 b82646bde57db8fc  153 ETA 00:59; Z=64 (avg 63.6)
20250227 15:43:35 24036583      1020000 b50870c6e109d398  152
20250227 15:43:38 24036583      1040000 13f32c02115b74eb  153
```

3:35h ETA for slightly smaller generalized Fermat prime "3843236^1048576+1"
```
hermann@7600x:~/genefer22/bin$ ./geneferg -q -n 20 -b 3843236
geneferg version 24.04.1 (linux x64, gcc-13.3.0)
Copyright (c) 2022, Yves Gallot
genefer is free source code, under the MIT license.

Command line: '-q -n 20 -b 3843236'

Running on device 'gfx906:sramecc+:xnack-', vendor 'Advanced Micro Devices, Inc.', version 'OpenCL 2.0 ', driver '3635.0 (HSA1.1,LC)', data size: 36 MB.
0.0778% done, 03:35:37 remaining, 0.564 ms/bit.        
0.163% done, 03:34:02 remaining, 0.561 ms/bit.        
3843236^{2^20} + 1: terminated.                   

hermann@7600x:~/genefer22/bin$ 

```

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
