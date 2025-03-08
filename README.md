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

## second modification

After undoing pevious first modification changes, small working commit [7aff627](https://github.com/Hermann-SW/gpuowl/commit/7aff62799b4f6cfa5c265d3252a80a164afe733f):  
- start with 3^(2^17) instead of 3
- number or squarings reduced by 17
- proof generation turned off for now

Reason for 17 is that it is largest x with 3^(2^x)<2^393216-1.  
For more a mod operation is needed, but I see modmul only.  
This will allow to process Proth primes k*2^n+1 with k<2^17, which covers many k values.

For determining the final res64 value 5a4fc71ea32bbf33 for Mersenne prime 2^393216-1, execute unmodified prpll:
```
hermann@7600x:~/preda/gpuowl$ rm -rf 393216 && build-release/prpll -prp 393216 -fft 256:1:256 2>err
20250308 10:55:21  PRPLL 0.15-125-ga1349df starting
20250308 10:55:21  config: -prp 393216 -fft 256:1:256 
20250308 10:55:21  device 0, OpenCL 3635.0 (HSA1.1,LC), unique id 'd64a58a17330f0ed'
20250308 10:55:21 393216 BPW info for 256:1:256 not found, defaults={19.67, 19.77, 19.77, 19.87}
20250308 10:55:21 393216 config: 
20250308 10:55:21 393216 FFT: 128K 256:1:256:3 (3.00 bpw)
20250308 10:55:21 393216 Using long carry!
20250308 10:55:23 393216 OK         0 on-load: blockSize 1000, 0000000000000003
20250308 10:55:23 393216 Proof of power 6 requires about 0.0GB of disk space
20250308 10:55:23 393216 OK      2000 3e539848c5ad042a   83 ETA 00:01; Z=1650159308834 (avg 1650159308833.7)
20250308 10:55:24 393216        20000 02b0f7395bd4f667   40
...
20250308 10:55:37 393216       360000 0821c32399e6fd7b   40
20250308 10:55:38 393216       380000 3e2efc6c0a54d4b1   40
20250308 10:55:39 393216 CC   393216 / 393216, 5a4fc71ea32bbf33
...
hermann@7600x:~/preda/gpuowl$ 
```

Here is full log of run with starting after 17× squaring of 3.  
It has same res64 value, and the number of loopw reported on left side of "/" is reduced by 17:  
```
20250308 13:11:13 393216 CC   393199 / 393216, 5a4fc71ea32bbf33
```

```
hermann@7600x:~/gpuowl$ rm -rf 393216 && build-release/prpll -prp 393216 -fft 256:1:256
20250308 13:10:55  PRPLL cf63750-dirty starting
20250308 13:10:55  config: -prp 393216 -fft 256:1:256 
20250308 13:10:55  device 0, OpenCL 3635.0 (HSA1.1,LC), unique id 'd64a58a17330f0ed'
20250308 13:10:56 393216 config: 
20250308 13:10:56 393216 FFT: 128K 256:1:256:3 (3.00 bpw)
20250308 13:10:56 393216 Using long carry!
20250308 13:10:57 393216 OK         0 on-load: blockSize 1000, e15c9645d1e80001
20250308 13:10:57 393216 Proof of power 6 requires about 0.0GB of disk space
ok: 0
20250308 13:10:57 393216 OK      2000 b192ad656d2f13fe   82 ETA 00:01; Z=1647538368454 (avg 1647538368454.4)
20250308 13:10:58 393216        20000 78e0172f78f1f0f7   41
20250308 13:10:59 393216        40000 6a70b33d9535f3a6   40
20250308 13:11:00 393216        60000 366a89b689f6af1e   40
20250308 13:11:00 393216        80000 45b5ad4972ff9360   40
20250308 13:11:01 393216       100000 35c33f4c433245f9   40
20250308 13:11:02 393216       120000 fe8a9792aeb98ad4   40
20250308 13:11:03 393216       140000 f4b6d7b96e6e3c17   40
20250308 13:11:04 393216       160000 8fa618787e6bd16f   40
20250308 13:11:04 393216       180000 78b6c3a257e8f2b8   40
20250308 13:11:05 393216       200000 7977e901e4ffb110   40
20250308 13:11:06 393216       220000 7036bff94d861fc9   40
20250308 13:11:07 393216       240000 b7230d749dfe0ed8   40
20250308 13:11:08 393216       260000 917b6d6c1decee31   40
20250308 13:11:09 393216       280000 474f366f18b6fb36   40
20250308 13:11:09 393216       300000 1bc62746d9b8a355   40
20250308 13:11:10 393216       320000 0df633d3d3b7be8d   40
20250308 13:11:11 393216       340000 e3de60bd090f2a41   40
20250308 13:11:12 393216       360000 59d745697c0c9f79   40
20250308 13:11:13 393216       380000 3db4b9c59eeba5b1   40
20250308 13:11:13 393216 CC   393199 / 393216, 5a4fc71ea32bbf33
ok: 0
20250308 13:11:13 393216 OK    394000 137eec8dd9d059f6   40 ETA 00:00; Z=2545104975546 (avg 1797257568970.2)
20250308 13:11:13 393216 {"status":"C", "exponent":393216, "worktype":"PRP-3", "res64":"5a4fc71ea32bbf33", "res2048":"8ccc892782332df135d76d31b3b3029d6a842790791a4e5b0478c7a2cea219ad54a6829d0842d72eef8417f05f069f1de2152f3494a950781c4e5e9f3b8139239fc6aac7a4dedf310d8ae413354df4ad9550ceafb1f6fdec18eb51658b239cb68f5890049bdcba2c58f1e8c438d84ef45e1004232bd24921e288fdb45c2300ebc5c4a1bce93938f1458b7b985fe4cfe7a65a22c18132153a5fe7960664bc996f53e7c531fc6f3c4b97db0ff33db9232782c83436d0100d8d5aae0def3241c61ef230776eb4a1cc437742e1e53c8f9d694d26f17ee4663dd118bf3b8b8ad45e17029de16cfbcbbe1f38e2c15223dbe9973fd816c09aecb5f65a4fc71ea32bbf33", "residue-type":1, "errors":{"gerbicz":0}, "fft-length":131072, "program":{"name":"prpll", "version":"cf63750-dirty", "port":8, "os":{"os":"Linux", "version":"6.8.0-55-generic", "architecture":"x86_64"}}, "uid":"d64a58a17330f0ed", "timestamp":"2025-03-08 12:11:13"}
20250308 13:11:13  Bye
hermann@7600x:~/gpuowl$ 
```

---

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
