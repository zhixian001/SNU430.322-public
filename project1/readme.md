# Project 1

## 테스트벤치 결과

### 3월 18일

```log
TEST             Add-1 :
FAILED
A = 0, B = 0, Cin = 0, C = zzzzzzzzzzzzzzzz (Ans : 0), Cout = z (Ans : 0)

TEST             Add-2 :
FAILED
A = 0, B = 0, Cin = 1, C = zzzzzzzzzzzzzzzz (Ans : 1), Cout = z (Ans : 0)

TEST             Add-3 :
FAILED
A = 10, B = 11, Cin = 0, C = zzzzzzzzzzzzzzzz (Ans : 101), Cout = z (Ans : 0)

TEST             Add-4 :
FAILED
A = 11, B = 10, Cin = 0, C = zzzzzzzzzzzzzzzz (Ans : 101), Cout = z (Ans : 0)

TEST             Add-5 :
FAILED
A = 10, B = 11, Cin = 1, C = zzzzzzzzzzzzzzzz (Ans : 110), Cout = z (Ans : 0)

TEST             Add-6 :
FAILED
A = 11, B = 10, Cin = 1, C = zzzzzzzzzzzzzzzz (Ans : 110), Cout = z (Ans : 0)

TEST             Add-7 :
FAILED
A = 1000000000000000, B = 1000000000000000, Cin = 0, C = zzzzzzzzzzzzzzzz (Ans : 0), Cout = z (Ans : 1)

TEST             Add-8 :
FAILED
A = 1111111111111111, B = 1, Cin = 0, C = zzzzzzzzzzzzzzzz (Ans : 0), Cout = z (Ans : 1)

TEST             Add-9 :
FAILED
A = 1111111111111111, B = 1111111111111111, Cin = 0, C = zzzzzzzzzzzzzzzz (Ans : 1111111111111110), Cout = z (Ans : 1)

TEST             Sub-1 :
FAILED
A = 0, B = 0, Cin = 0, C = zzzzzzzzzzzzzzzz (Ans : 0), Cout = z (Ans : 0)

TEST             Sub-2 :
FAILED
A = 1, B = 0, Cin = 0, C = zzzzzzzzzzzzzzzz (Ans : 1), Cout = z (Ans : 0)

TEST             Sub-3 :
FAILED
A = 0, B = 1, Cin = 0, C = zzzzzzzzzzzzzzzz (Ans : 1111111111111111), Cout = z (Ans : 1)

TEST             Sub-4 :
FAILED
A = 0, B = 0, Cin = 1, C = zzzzzzzzzzzzzzzz (Ans : 1111111111111111), Cout = z (Ans : 1)

TEST             Sub-5 :
FAILED
A = 11, B = 10, Cin = 0, C = zzzzzzzzzzzzzzzz (Ans : 1), Cout = z (Ans : 0)

TEST             Sub-6 :
FAILED
A = 11, B = 10, Cin = 1, C = zzzzzzzzzzzzzzzz (Ans : 0), Cout = z (Ans : 0)

TEST             Sub-7 :
FAILED
A = 0, B = 1111111111111111, Cin = 1, C = zzzzzzzzzzzzzzzz (Ans : 0), Cout = z (Ans : 1)

TEST              Id-1 :
PASSED

TEST              Id-2 :
PASSED

TEST              Id-3 :
PASSED

TEST            Nand-1 :
FAILED
A = 11001100110011, B = 101010101010101, Cin = 0, C = 1000100010000 (Ans : 1110111011101110), Cout = 0 (Ans : 0)

TEST            Nand-2 :
FAILED
A = 1100110011001100, B = 101010101010101, Cin = 0, C = 100010001000101 (Ans : 1011101110111011), Cout = 0 (Ans : 0)

TEST             Nor-1 :
FAILED
A = 11001100110011, B = 101010101010101, Cin = 0, C = 111011101110110 (Ans : 1000100010001000), Cout = 0 (Ans : 0)

TEST             Nor-2 :
FAILED
A = 1100110011001100, B = 101010101010101, Cin = 0, C = 1101110111011100 (Ans : 10001000100010), Cout = 0 (Ans : 0)

TEST            Xnor-1 :
FAILED
A = 11001100110011, B = 101010101010101, Cin = 0, C = 110011001100111 (Ans : 1001100110011001), Cout = 0 (Ans : 0)

TEST            Xnor-2 :
FAILED
A = 1100110011001100, B = 101010101010101, Cin = 0, C = 1001100110011000 (Ans : 110011001100110), Cout = 0 (Ans : 0)

TEST             Not-1 :
FAILED
A = 0, B = 0, Cin = 0, C = 1 (Ans : 1111111111111111), Cout = 0 (Ans : 0)

TEST             Not-2 :
FAILED
A = 1, B = 0, Cin = 0, C = 0 (Ans : 1111111111111110), Cout = 0 (Ans : 0)

TEST             Not-3 :
FAILED
A = 1010101111001101, B = 0, Cin = 0, C = 1010101111001100 (Ans : 101010000110010), Cout = 0 (Ans : 0)

TEST             And-1 :
PASSED

TEST             And-2 :
PASSED

TEST              Or-1 :
PASSED

TEST              Or-2 :
PASSED

TEST             Xor-1 :
PASSED

TEST             Xor-2 :
PASSED

TEST             Lrs-1 :
PASSED

TEST             Lrs-2 :
PASSED

TEST             Lrs-3 :
PASSED

TEST             Lrs-4 :
PASSED

TEST             Ars-1 :
PASSED

TEST             Ars-2 :
PASSED

TEST             Ars-3 :
FAILED
A = 1111111111111010, B = 0, Cin = 0, C = 111111111111101 (Ans : 1111111111111101), Cout = 0 (Ans : 0)

TEST             Ars-4 :
FAILED
A = 1111111111111111, B = 0, Cin = 0, C = 111111111111111 (Ans : 1111111111111111), Cout = 0 (Ans : 0)

TEST              Rr-1 :
PASSED

TEST              Rr-2 :
PASSED

TEST             Lls-1 :
PASSED

TEST             Lls-2 :
PASSED

TEST             Als-1 :
PASSED

TEST             Als-2 :
PASSED

TEST              Rl-1 :
PASSED

TEST              Rl-2 :
PASSED
Passed = 23, Failed = 27

```

#### 이슈

- ARS를 수행 시 비트 수 하나가 모자람
- 논리 연산 중 not이 포함된 경우 비트가 하나 모자람 -> 각각의 비트에 대해 뒤집는 방법 찾기
- add, sub는 하나도 안됨. sign extend에 대한 예시를 발견함.


### 3월 19일

```log
TEST             Add-1 :
FAILED
A = 0, B = 0, Cin = 0, C = 0 (Ans : 0), Cout = z (Ans : 0)
TEST             Add-2 :
FAILED
A = 0, B = 0, Cin = 1, C = 1 (Ans : 1), Cout = z (Ans : 0)
TEST             Add-3 :
FAILED
A = 10, B = 11, Cin = 0, C = 101 (Ans : 101), Cout = z (Ans : 0)
TEST             Add-4 :
FAILED
A = 11, B = 10, Cin = 0, C = 101 (Ans : 101), Cout = z (Ans : 0)
TEST             Add-5 :
FAILED
A = 10, B = 11, Cin = 1, C = 110 (Ans : 110), Cout = z (Ans : 0)
TEST             Add-6 :
FAILED
A = 11, B = 10, Cin = 1, C = 110 (Ans : 110), Cout = z (Ans : 0)
TEST             Add-7 :
FAILED
A = 1000000000000000, B = 1000000000000000, Cin = 0, C = 0 (Ans : 0), Cout = z (Ans : 1)
TEST             Add-8 :
FAILED
A = 1111111111111111, B = 1, Cin = 0, C = 0 (Ans : 0), Cout = z (Ans : 1)
TEST             Add-9 :
FAILED
A = 1111111111111111, B = 1111111111111111, Cin = 0, C = 1111111111111110 (Ans : 1111111111111110), Cout = z (Ans : 1)
TEST             Sub-1 :
FAILED
A = 0, B = 0, Cin = 0, C = 0 (Ans : 0), Cout = z (Ans : 0)
TEST             Sub-2 :
FAILED
A = 1, B = 0, Cin = 0, C = 1 (Ans : 1), Cout = z (Ans : 0)
TEST             Sub-3 :
FAILED
A = 0, B = 1, Cin = 0, C = 1111111111111111 (Ans : 1111111111111111), Cout = z (Ans : 1)
TEST             Sub-4 :
FAILED
A = 0, B = 0, Cin = 1, C = 1111111111111111 (Ans : 1111111111111111), Cout = z (Ans : 1)
TEST             Sub-5 :
FAILED
A = 11, B = 10, Cin = 0, C = 1 (Ans : 1), Cout = z (Ans : 0)
TEST             Sub-6 :
FAILED
A = 11, B = 10, Cin = 1, C = 0 (Ans : 0), Cout = z (Ans : 0)
TEST             Sub-7 :
FAILED
A = 0, B = 1111111111111111, Cin = 1, C = 0 (Ans : 0), Cout = z (Ans : 1)
TEST              Id-1 :
PASSED
TEST              Id-2 :
PASSED
TEST              Id-3 :
PASSED
TEST            Nand-1 :
PASSED
TEST            Nand-2 :
PASSED
TEST             Nor-1 :
PASSED
TEST             Nor-2 :
PASSED
TEST            Xnor-1 :
PASSED
TEST            Xnor-2 :
PASSED
TEST             Not-1 :
PASSED
TEST             Not-2 :
PASSED
TEST             Not-3 :
PASSED
TEST             And-1 :
PASSED
TEST             And-2 :
PASSED
TEST              Or-1 :
PASSED
TEST              Or-2 :
PASSED
TEST             Xor-1 :
PASSED
TEST             Xor-2 :
PASSED
TEST             Lrs-1 :
PASSED
TEST             Lrs-2 :
PASSED
TEST             Lrs-3 :
PASSED
TEST             Lrs-4 :
PASSED
TEST             Ars-1 :
PASSED
TEST             Ars-2 :
PASSED
TEST             Ars-3 :
PASSED
TEST             Ars-4 :
PASSED
TEST              Rr-1 :
PASSED
TEST              Rr-2 :
PASSED
TEST             Lls-1 :
PASSED
TEST             Lls-2 :
PASSED
TEST             Als-1 :
PASSED
TEST             Als-2 :
PASSED
TEST              Rl-1 :
PASSED
TEST              Rl-2 :
PASSED
Passed = 34, Failed = 16
```

#### 이슈

- add, sub만 해결하면 됨

### 3월 19일 2번째 

```log
TEST             Add-1 :
PASSED
TEST             Add-2 :
PASSED
TEST             Add-3 :
PASSED
TEST             Add-4 :
PASSED
TEST             Add-5 :
PASSED
TEST             Add-6 :
PASSED
TEST             Add-7 :
PASSED
TEST             Add-8 :
FAILED
A = 1111111111111111, B = 1, Cin = 0, C = 0 (Ans : 0), Cout = 0 (Ans : 1)
TEST             Add-9 :
FAILED
A = 1111111111111111, B = 1111111111111111, Cin = 0, C = 1111111111111110 (Ans : 1111111111111110), Cout = 0 (Ans : 1)
TEST             Sub-1 :
PASSED
TEST             Sub-2 :
PASSED
TEST             Sub-3 :
FAILED
A = 0, B = 1, Cin = 0, C = 1111111111111111 (Ans : 1111111111111111), Cout = 0 (Ans : 1)
TEST             Sub-4 :
FAILED
A = 0, B = 0, Cin = 1, C = 1111111111111111 (Ans : 1111111111111111), Cout = 0 (Ans : 1)
TEST             Sub-5 :
PASSED
TEST             Sub-6 :
PASSED
TEST             Sub-7 :
FAILED
A = 0, B = 1111111111111111, Cin = 1, C = 0 (Ans : 0), Cout = 0 (Ans : 1)
TEST              Id-1 :
PASSED
TEST              Id-2 :
PASSED
TEST              Id-3 :
PASSED
TEST            Nand-1 :
PASSED
TEST            Nand-2 :
PASSED
TEST             Nor-1 :
PASSED
TEST             Nor-2 :
PASSED
TEST            Xnor-1 :
PASSED
TEST            Xnor-2 :
PASSED
TEST             Not-1 :
PASSED
TEST             Not-2 :
PASSED
TEST             Not-3 :
PASSED
TEST             And-1 :
PASSED
TEST             And-2 :
PASSED
TEST              Or-1 :
PASSED
TEST              Or-2 :
PASSED
TEST             Xor-1 :
PASSED
TEST             Xor-2 :
PASSED
TEST             Lrs-1 :
PASSED
TEST             Lrs-2 :
PASSED
TEST             Lrs-3 :
PASSED
TEST             Lrs-4 :
PASSED
TEST             Ars-1 :
PASSED
TEST             Ars-2 :
PASSED
TEST             Ars-3 :
PASSED
TEST             Ars-4 :
PASSED
TEST              Rr-1 :
PASSED
TEST              Rr-2 :
PASSED
TEST             Lls-1 :
PASSED
TEST             Lls-2 :
PASSED
TEST             Als-1 :
PASSED
TEST             Als-2 :
PASSED
TEST              Rl-1 :
PASSED
TEST              Rl-2 :
PASSED
Passed = 45, Failed = 5
```
