	.file	"bench.c"
	.intel_syntax noprefix
	.text
	.p2align 4
	.globl	fill_random
	.type	fill_random, @function
fill_random:
	endbr64
	test	esi, esi
	mov	r9d, esi
	jle	.L7
	movsx	r8, esi
	mov	edx, DWORD PTR rng_state[rip]
	vxorps	xmm3, xmm3, xmm3
	vmovss	xmm2, DWORD PTR .LC0[rip]
	sal	r8, 2
	vmovss	xmm1, DWORD PTR .LC1[rip]
	lea	rsi, [rdi+r8]
	xor	edi, edi
	.p2align 4,,10
	.p2align 3
.L3:
	mov	rcx, rsi
	sub	rcx, r8
	.p2align 4,,10
	.p2align 3
.L4:
	mov	eax, edx
	add	rcx, 4
	sal	eax, 13
	xor	eax, edx
	mov	edx, eax
	shr	edx, 17
	xor	eax, edx
	mov	edx, eax
	sal	edx, 5
	xor	edx, eax
	movzx	eax, dx
	vcvtsi2ss	xmm0, xmm3, eax
	vfmadd132ss	xmm0, xmm1, xmm2
	vmovss	DWORD PTR -4[rcx], xmm0
	cmp	rsi, rcx
	jne	.L4
	add	edi, 1
	add	rsi, r8
	cmp	r9d, edi
	jne	.L3
	mov	DWORD PTR rng_state[rip], edx
.L7:
	ret
	.size	fill_random, .-fill_random
	.p2align 4
	.globl	matmul
	.type	matmul, @function
matmul:
	endbr64
	push	rbp
	mov	rbp, rsp
	push	r15
	push	r14
	push	r13
	mov	r13, rdi
	push	r12
	mov	r12, rdx
	movsx	rdx, ecx
	push	rbx
	mov	rax, rdx
	mov	r14, rdx
	mov	rbx, rsi
	imul	rax, rdx
	xor	esi, esi
	mov	rdi, r12
	and	rsp, -32
	sub	rsp, 96
	mov	QWORD PTR 88[rsp], rdx
	mov	rdx, rax
	sal	rdx, 2
	call	memset@PLT
	test	r14d, r14d
	jle	.L45
	mov	rdx, r14
	lea	ecx, -3[r14]
	mov	rdi, r13
	xor	r13d, r13d
	add	rdx, rdx
	and	ecx, -2
	xor	r15d, r15d
	mov	r9d, r13d
	lea	rsi, 0[0+r14*8]
	mov	QWORD PTR 24[rsp], rdx
	lea	edx, -1[r14]
	mov	QWORD PTR 32[rsp], rsi
	mov	esi, r14d
	lea	rax, 0[0+r14*4]
	and	esi, -8
	mov	DWORD PTR 84[rsp], edx
	mov	edx, r14d
	mov	DWORD PTR 56[rsp], esi
	lea	esi, 2[rcx]
	shr	edx, 3
	mov	DWORD PTR 60[rsp], esi
	sal	rdx, 5
	mov	QWORD PTR 64[rsp], rax
	mov	rax, r12
.L11:
	xor	esi, esi
	cmp	r14d, 2
	jle	.L27
	mov	esi, DWORD PTR 60[rsp]
	mov	DWORD PTR 52[rsp], r9d
	mov	r8, rbx
	lea	r11, 4[rdi]
	mov	DWORD PTR 80[rsp], 0
	mov	r13, QWORD PTR 88[rsp]
	xor	r10d, r10d
	mov	DWORD PTR 48[rsp], esi
	mov	QWORD PTR 72[rsp], rax
	mov	QWORD PTR 40[rsp], rdi
.L15:
	cmp	DWORD PTR 84[rsp], 6
	vmovss	xmm3, DWORD PTR -4[r11]
	jbe	.L30
	mov	rax, QWORD PTR 64[rsp]
	vbroadcastss	ymm1, DWORD PTR [r11]
	vbroadcastss	ymm2, xmm3
	xor	ecx, ecx
	lea	rsi, [rax+r8]
	mov	rax, QWORD PTR 72[rsp]
	.p2align 4,,10
	.p2align 3
.L24:
	vmovups	ymm0, YMMWORD PTR [r8+rcx]
	vfmadd213ps	ymm0, ymm2, YMMWORD PTR [rax+rcx]
	vfmadd231ps	ymm0, ymm1, YMMWORD PTR [rsi+rcx]
	vmovups	YMMWORD PTR [rax+rcx], ymm0
	add	rcx, 32
	cmp	rdx, rcx
	jne	.L24
	mov	edi, DWORD PTR 56[rsp]
	mov	QWORD PTR 72[rsp], rax
	cmp	edi, r14d
	je	.L12
	mov	ecx, edi
	mov	esi, edi
.L23:
	mov	edi, r14d
	sub	edi, ecx
	lea	r9d, -1[rdi]
	cmp	r9d, 2
	jbe	.L13
	lea	r9, [r15+rcx]
	lea	rax, 0[r13+rcx]
	add	rcx, r10
	vshufps	xmm1, xmm3, xmm3, 0
	lea	r9, [r12+r9*4]
	vbroadcastss	xmm0, DWORD PTR [r11]
	vmovups	xmm6, XMMWORD PTR [r9]
	vfmadd132ps	xmm1, xmm6, XMMWORD PTR [rbx+rcx*4]
	mov	ecx, edi
	vfmadd132ps	xmm0, xmm1, XMMWORD PTR [rbx+rax*4]
	and	ecx, -4
	add	esi, ecx
	and	edi, 3
	vmovups	XMMWORD PTR [r9], xmm0
	je	.L12
.L13:
	movsx	rcx, esi
	vmovss	xmm0, DWORD PTR [r11]
	lea	rdi, [rcx+r15]
	lea	r9, [r10+rcx]
	add	rcx, r13
	lea	rdi, [r12+rdi*4]
	vmovss	xmm1, DWORD PTR [rbx+r9*4]
	vfmadd213ss	xmm1, xmm3, DWORD PTR [rdi]
	vfmadd231ss	xmm1, xmm0, DWORD PTR [rbx+rcx*4]
	lea	ecx, 1[rsi]
	cmp	r14d, ecx
	vmovss	DWORD PTR [rdi], xmm1
	jle	.L12
	movsx	rcx, ecx
	lea	rdi, [r15+rcx]
	lea	r9, [r10+rcx]
	add	rcx, r13
	lea	rdi, [r12+rdi*4]
	vmovss	xmm1, DWORD PTR [rbx+r9*4]
	vfmadd213ss	xmm1, xmm3, DWORD PTR [rdi]
	vfmadd231ss	xmm1, xmm0, DWORD PTR [rbx+rcx*4]
	lea	ecx, 2[rsi]
	cmp	r14d, ecx
	vmovss	DWORD PTR [rdi], xmm1
	jle	.L12
	movsx	rcx, ecx
	lea	rsi, [r15+rcx]
	lea	rdi, [r10+rcx]
	add	rcx, r13
	lea	rsi, [r12+rsi*4]
	vmovss	xmm7, DWORD PTR [rsi]
	vfmadd132ss	xmm3, xmm7, DWORD PTR [rbx+rdi*4]
	vfmadd132ss	xmm0, xmm3, DWORD PTR [rbx+rcx*4]
	vmovss	DWORD PTR [rsi], xmm0
.L12:
	mov	rax, QWORD PTR 32[rsp]
	add	DWORD PTR 80[rsp], 2
	add	r11, 8
	mov	edi, DWORD PTR 80[rsp]
	add	r8, rax
	mov	rax, QWORD PTR 24[rsp]
	add	r10, rax
	add	r13, rax
	mov	eax, DWORD PTR 60[rsp]
	cmp	edi, eax
	jne	.L15
	mov	r9d, DWORD PTR 52[rsp]
	mov	esi, DWORD PTR 48[rsp]
	mov	rax, QWORD PTR 72[rsp]
	mov	rdi, QWORD PTR 40[rsp]
.L27:
	mov	r8, QWORD PTR 88[rsp]
	movsx	r11, esi
	mov	DWORD PTR 80[rsp], r9d
	mov	r13d, DWORD PTR 56[rsp]
	imul	r8, r11
	.p2align 4,,10
	.p2align 3
.L22:
	cmp	DWORD PTR 84[rsp], 6
	vmovss	xmm1, DWORD PTR [rdi+r11*4]
	jbe	.L28
.L19:
	lea	rsi, [rbx+r8*4]
	vbroadcastss	ymm2, xmm1
	xor	ecx, ecx
	.p2align 4,,10
	.p2align 3
.L17:
	vmovups	ymm0, YMMWORD PTR [rsi+rcx]
	vfmadd213ps	ymm0, ymm2, YMMWORD PTR [rax+rcx]
	vmovups	YMMWORD PTR [rax+rcx], ymm0
	add	rcx, 32
	cmp	rdx, rcx
	jne	.L17
	cmp	r13d, r14d
	je	.L47
	mov	ecx, r13d
	mov	esi, r13d
.L16:
	mov	r9d, r14d
	sub	r9d, ecx
	lea	r10d, -1[r9]
	cmp	r10d, 2
	jbe	.L20
	lea	r10, [rcx+r15]
	add	rcx, r8
	vshufps	xmm0, xmm1, xmm1, 0
	lea	r10, [r12+r10*4]
	vmovups	xmm4, XMMWORD PTR [r10]
	vfmadd132ps	xmm0, xmm4, XMMWORD PTR [rbx+rcx*4]
	mov	ecx, r9d
	and	ecx, -4
	add	esi, ecx
	and	r9d, 3
	vmovups	XMMWORD PTR [r10], xmm0
	je	.L21
.L20:
	movsx	rcx, esi
	lea	r9, [rcx+r15]
	add	rcx, r8
	lea	r9, [r12+r9*4]
	vmovss	xmm0, DWORD PTR [rbx+rcx*4]
	lea	ecx, 1[rsi]
	vfmadd213ss	xmm0, xmm1, DWORD PTR [r9]
	cmp	ecx, r14d
	vmovss	DWORD PTR [r9], xmm0
	jge	.L21
	movsx	rcx, ecx
	add	esi, 2
	lea	r9, [rcx+r15]
	add	rcx, r8
	cmp	r14d, esi
	lea	r9, [r12+r9*4]
	vmovss	xmm0, DWORD PTR [rbx+rcx*4]
	vfmadd213ss	xmm0, xmm1, DWORD PTR [r9]
	vmovss	DWORD PTR [r9], xmm0
	jle	.L21
	movsx	rsi, esi
	lea	rcx, [rsi+r15]
	add	rsi, r8
	lea	rcx, [r12+rcx*4]
	vmovss	xmm5, DWORD PTR [rcx]
	vfmadd132ss	xmm1, xmm5, DWORD PTR [rbx+rsi*4]
	vmovss	DWORD PTR [rcx], xmm1
.L21:
	mov	rsi, QWORD PTR 88[rsp]
	add	r11, 1
	add	r8, rsi
	cmp	r14d, r11d
	jg	.L22
.L42:
	mov	r9d, DWORD PTR 80[rsp]
	mov	rcx, rsi
	mov	rsi, QWORD PTR 64[rsp]
	add	r15, rcx
	add	r9d, 1
	add	rax, rsi
	add	rdi, rsi
	cmp	r14d, r9d
	jne	.L11
	vzeroupper
.L45:
	lea	rsp, -40[rbp]
	pop	rbx
	pop	r12
	pop	r13
	pop	r14
	pop	r15
	pop	rbp
	ret
	.p2align 4,,10
	.p2align 3
.L47:
	mov	rsi, QWORD PTR 88[rsp]
	add	r11, 1
	add	r8, rsi
	cmp	r13d, r11d
	jle	.L42
	vmovss	xmm1, DWORD PTR [rdi+r11*4]
	jmp	.L19
	.p2align 4,,10
	.p2align 3
.L28:
	xor	ecx, ecx
	xor	esi, esi
	jmp	.L16
.L30:
	xor	ecx, ecx
	xor	esi, esi
	jmp	.L23
	.size	matmul, .-matmul
	.p2align 4
	.globl	blur3x3
	.type	blur3x3, @function
blur3x3:
	endbr64
	push	rbp
	mov	rbp, rsp
	push	r15
	mov	r15d, edx
	push	r14
	push	r13
	mov	r13, rsi
	push	r12
	push	rbx
	mov	rbx, rdi
	movsx	rdi, edx
	mov	r14, rdi
	and	rsp, -32
	sub	rsp, 96
	mov	DWORD PTR 40[rsp], edx
	mov	rdx, rdi
	imul	rdx, rdi
	mov	QWORD PTR 80[rsp], rsi
	mov	rsi, rbx
	mov	QWORD PTR 48[rsp], rdi
	mov	rdi, r13
	sal	rdx, 2
	call	memcpy@PLT
	lea	eax, -1[r15]
	cmp	eax, 1
	mov	DWORD PTR 64[rsp], eax
	jle	.L71
	mov	rax, r14
	mov	r8d, r15d
	mov	rsi, rbx
	mov	rdi, r14
	sal	rax, 2
	vxorps	xmm0, xmm0, xmm0
	vxorps	xmm8, xmm8, xmm8
	sub	r8d, 3
	lea	rdx, [rbx+rax]
	lea	r9, 4[r13+rax]
	mov	QWORD PTR 32[rsp], rax
	vbroadcastss	ymm1, DWORD PTR .LC3[rip]
	lea	rcx, [rdx+rax]
	lea	eax, -2[r15]
	mov	DWORD PTR 44[rsp], r8d
	vmovq	xmm11, QWORD PTR .LC4[rip]
	mov	r8d, eax
	mov	DWORD PTR 8[rsp], eax
	shr	eax, 3
	vxorps	xmm15, xmm15, xmm15
	sal	rax, 5
	mov	QWORD PTR 72[rsp], r9
	vbroadcastss	xmm6, DWORD PTR .LC3[rip]
	vxorps	xmm7, xmm7, xmm7
	mov	QWORD PTR 24[rsp], rax
	mov	eax, r8d
	and	r8d, -8
	and	eax, 7
	mov	DWORD PTR 68[rsp], 1
	mov	DWORD PTR 20[rsp], eax
	mov	DWORD PTR 12[rsp], r8d
	add	r8d, 1
	mov	DWORD PTR 16[rsp], r8d
	xor	r8d, r8d
	.p2align 4,,10
	.p2align 3
.L50:
	mov	rax, QWORD PTR 48[rsp]
	add	DWORD PTR 68[rsp], 1
	mov	QWORD PTR 88[rsp], r8
	mov	r8, rdi
	add	rdi, rax
	cmp	DWORD PTR 44[rsp], 6
	jbe	.L59
	mov	QWORD PTR 56[rsp], rdi
	mov	r9, QWORD PTR 72[rsp]
	lea	r15, 4[rsi]
	xor	eax, eax
	mov	rdi, QWORD PTR 24[rsp]
	lea	r14, 8[rsi]
	lea	r13, 4[rdx]
	lea	r12, 8[rdx]
	lea	r11, 4[rcx]
	lea	r10, 8[rcx]
	.p2align 4,,10
	.p2align 3
.L55:
	vaddps	ymm2, ymm0, YMMWORD PTR [rsi+rax]
	vaddps	ymm2, ymm2, YMMWORD PTR [r15+rax]
	vaddps	ymm2, ymm2, YMMWORD PTR [r14+rax]
	vaddps	ymm2, ymm2, YMMWORD PTR [rdx+rax]
	vaddps	ymm2, ymm2, YMMWORD PTR 0[r13+rax]
	vaddps	ymm2, ymm2, YMMWORD PTR [r12+rax]
	vaddps	ymm2, ymm2, YMMWORD PTR [rcx+rax]
	vaddps	ymm2, ymm2, YMMWORD PTR [r11+rax]
	vaddps	ymm2, ymm2, YMMWORD PTR [r10+rax]
	vmulps	ymm2, ymm2, ymm1
	vmovups	YMMWORD PTR [r9+rax], ymm2
	add	rax, 32
	cmp	rdi, rax
	jne	.L55
	mov	eax, DWORD PTR 20[rsp]
	mov	rdi, QWORD PTR 56[rsp]
	mov	QWORD PTR 72[rsp], r9
	test	eax, eax
	je	.L51
	mov	r10d, DWORD PTR 12[rsp]
	mov	eax, DWORD PTR 16[rsp]
.L57:
	mov	r11d, DWORD PTR 40[rsp]
	sub	r11d, r10d
	lea	r13d, -2[r11]
	sub	r11d, 3
	cmp	r11d, 2
	jbe	.L52
	mov	r14, QWORD PTR 88[rsp]
	lea	r11, [r8+r10]
	mov	r15, QWORD PTR 80[rsp]
	lea	r12, [r10+r14]
	add	r10, rdi
	vaddps	xmm2, xmm7, XMMWORD PTR [rbx+r12*4]
	vaddps	xmm2, xmm2, XMMWORD PTR 4[rbx+r12*4]
	vaddps	xmm2, xmm2, XMMWORD PTR 8[rbx+r12*4]
	vaddps	xmm2, xmm2, XMMWORD PTR [rbx+r11*4]
	vaddps	xmm2, xmm2, XMMWORD PTR 4[rbx+r11*4]
	vaddps	xmm2, xmm2, XMMWORD PTR 8[rbx+r11*4]
	vaddps	xmm2, xmm2, XMMWORD PTR [rbx+r10*4]
	vaddps	xmm2, xmm2, XMMWORD PTR 4[rbx+r10*4]
	vaddps	xmm2, xmm2, XMMWORD PTR 8[rbx+r10*4]
	mov	r10d, r13d
	and	r10d, -4
	add	eax, r10d
	and	r13d, 3
	vmulps	xmm2, xmm2, xmm6
	vmovups	XMMWORD PTR 4[r15+r11*4], xmm2
	je	.L51
.L52:
	movsx	r10, eax
	mov	r14, QWORD PTR 88[rsp]
	mov	r9d, DWORD PTR 8[rsp]
	lea	r15d, 1[rax]
	lea	r11, [r10+rdi]
	add	r14, r10
	lea	r12, [rbx+r11*4]
	lea	r11, [r10+r8]
	cmp	r15d, r9d
	lea	r13, [rbx+r11*4]
	lea	r14, [rbx+r14*4]
	jge	.L58
	vmovq	xmm4, QWORD PTR -4[r14]
	movsx	r10, r15d
	vmovq	xmm13, QWORD PTR [r14]
	mov	r15, QWORD PTR 88[rsp]
	vmovq	xmm9, QWORD PTR -4[r13]
	vaddps	xmm4, xmm4, xmm15
	vmovq	xmm12, QWORD PTR 0[r13]
	vmovq	xmm2, QWORD PTR [r12]
	add	r15, r10
	mov	r14, QWORD PTR 80[rsp]
	vmovq	xmm10, QWORD PTR [rbx+r15*4]
	lea	r15, [r8+r10]
	add	r10, rdi
	vaddps	xmm4, xmm4, xmm13
	vmovq	xmm3, QWORD PTR [rbx+r15*4]
	vmovq	xmm5, QWORD PTR [rbx+r10*4]
	lea	r15d, 2[rax]
	movsx	r10, r15d
	vaddps	xmm4, xmm4, xmm10
	vaddps	xmm4, xmm4, xmm9
	vmovq	xmm9, QWORD PTR -4[r12]
	vaddps	xmm4, xmm4, xmm12
	vaddps	xmm4, xmm4, xmm3
	vaddps	xmm4, xmm4, xmm9
	vaddps	xmm4, xmm4, xmm2
	vaddps	xmm4, xmm4, xmm5
	vmulps	xmm4, xmm4, xmm11
	vmovlps	QWORD PTR [r14+r11*4], xmm4
	lea	r11d, 3[rax]
	cmp	r9d, r11d
	jle	.L54
	vmovshdup	xmm13, xmm13
	vmovshdup	xmm10, xmm10
	mov	r13, QWORD PTR 88[rsp]
	movsx	r11, r11d
	vmovshdup	xmm12, xmm12
	lea	r15d, 4[rax]
	lea	r14, [r10+r8]
	vmovshdup	xmm3, xmm3
	vmovshdup	xmm2, xmm2
	lea	r12, 0[r13+r11]
	movsx	r10, r15d
	lea	r12, [rbx+r12*4]
	vmovshdup	xmm5, xmm5
	vaddss	xmm13, xmm13, xmm8
	vmovss	xmm9, DWORD PTR [r12]
	vmovq	xmm4, QWORD PTR [r12]
	lea	r12, [r8+r11]
	lea	r12, [rbx+r12*4]
	add	r11, rdi
	vmovq	xmm14, QWORD PTR [r12]
	lea	r11, [rbx+r11*4]
	vaddss	xmm13, xmm10, xmm13
	vaddss	xmm10, xmm10, xmm8
	vaddss	xmm13, xmm13, xmm9
	vaddss	xmm9, xmm9, xmm10
	vaddss	xmm13, xmm12, xmm13
	vmovss	xmm12, DWORD PTR [r12]
	lea	r12, 0[r13+r10]
	vmovss	xmm10, DWORD PTR [rbx+r12*4]
	lea	r13, [r8+r10]
	lea	r12, [rdi+r10]
	vmovss	DWORD PTR 56[rsp], xmm10
	vmovshdup	xmm10, xmm4
	vaddss	xmm13, xmm3, xmm13
	vaddss	xmm13, xmm13, xmm12
	vaddss	xmm10, xmm10, xmm9
	vmovss	xmm9, DWORD PTR [rbx+r13*4]
	vaddss	xmm2, xmm2, xmm13
	vmovq	xmm13, QWORD PTR [r11]
	vaddss	xmm3, xmm3, xmm10
	vaddss	xmm2, xmm5, xmm2
	vaddss	xmm10, xmm12, xmm3
	vmovshdup	xmm3, xmm14
	vaddss	xmm3, xmm3, xmm10
	vmovss	xmm10, DWORD PTR [rbx+r12*4]
	vaddss	xmm3, xmm5, xmm3
	vaddss	xmm3, xmm3, DWORD PTR [r11]
	mov	r11, QWORD PTR 80[rsp]
	vunpcklps	xmm2, xmm2, xmm3
	vaddps	xmm2, xmm2, xmm13
	vmulps	xmm2, xmm2, xmm11
	vmovlps	QWORD PTR [r11+r14*4], xmm2
	lea	r11d, 5[rax]
	cmp	r9d, r11d
	jle	.L54
	mov	r14, QWORD PTR 88[rsp]
	movsx	r11, r11d
	vaddps	xmm2, xmm4, xmm15
	lea	r15d, 6[rax]
	vmovss	xmm5, DWORD PTR 56[rsp]
	lea	r12, [r11+r8]
	lea	r10, [r11+r14]
	vinsertps	xmm9, xmm9, DWORD PTR [rbx+r12*4], 0x10
	add	r11, rdi
	mov	r14, QWORD PTR 80[rsp]
	vinsertps	xmm3, xmm5, DWORD PTR [rbx+r10*4], 0x10
	vinsertps	xmm10, xmm10, DWORD PTR [rbx+r11*4], 0x10
	vaddps	xmm2, xmm2, xmm3
	vmovq	xmm3, QWORD PTR [rbx+r10*4]
	movsx	r10, r15d
	vaddps	xmm2, xmm2, xmm3
	vmovq	xmm3, QWORD PTR [rbx+r12*4]
	vaddps	xmm2, xmm2, xmm14
	vaddps	xmm2, xmm2, xmm9
	vaddps	xmm2, xmm2, xmm3
	vmovq	xmm3, QWORD PTR [rbx+r11*4]
	vaddps	xmm2, xmm2, xmm13
	vaddps	xmm2, xmm2, xmm10
	vaddps	xmm2, xmm2, xmm3
	vmulps	xmm2, xmm2, xmm11
	vmovlps	QWORD PTR [r14+r13*4], xmm2
.L54:
	mov	r9, QWORD PTR 88[rsp]
	lea	eax, -1[r15]
	lea	r12d, 1[r15]
	cdqe
	lea	r11, [rax+r9]
	vaddss	xmm3, xmm8, DWORD PTR [rbx+r11*4]
	lea	r11, [r10+r9]
	vmovss	xmm12, DWORD PTR [rbx+r11*4]
	movsx	r11, r12d
	lea	r13, [r11+r9]
	lea	r14, [r8+r11]
	add	r11, rdi
	vaddss	xmm3, xmm3, xmm12
	vmovss	xmm2, DWORD PTR [rbx+r13*4]
	lea	r13, [r8+rax]
	vmovss	xmm10, DWORD PTR [rbx+r14*4]
	add	rax, rdi
	vmovss	xmm5, DWORD PTR [rbx+r11*4]
	vaddss	xmm3, xmm3, xmm2
	vaddss	xmm3, xmm3, DWORD PTR [rbx+r13*4]
	lea	r13, [r8+r10]
	add	r10, rdi
	cmp	DWORD PTR 64[rsp], r12d
	vmovss	xmm9, DWORD PTR [rbx+r13*4]
	vmovss	xmm4, DWORD PTR [rbx+r10*4]
	vaddss	xmm3, xmm3, xmm9
	vaddss	xmm3, xmm3, xmm10
	vaddss	xmm3, xmm3, DWORD PTR [rbx+rax*4]
	mov	rax, QWORD PTR 80[rsp]
	vaddss	xmm3, xmm3, xmm4
	vaddss	xmm3, xmm3, xmm5
	vmulss	xmm3, xmm3, DWORD PTR .LC3[rip]
	vmovss	DWORD PTR [rax+r13*4], xmm3
	jle	.L51
	vaddss	xmm12, xmm12, xmm8
	lea	r10d, 2[r15]
	mov	r13, rax
	movsx	rax, r10d
	lea	r11, [rax+r9]
	vaddss	xmm12, xmm2, xmm12
	vmovss	xmm3, DWORD PTR [rbx+r11*4]
	lea	r11, [r8+rax]
	add	rax, rdi
	cmp	DWORD PTR 64[rsp], r10d
	vaddss	xmm12, xmm12, xmm3
	vaddss	xmm12, xmm9, xmm12
	vmovss	xmm9, DWORD PTR [rbx+r11*4]
	vaddss	xmm12, xmm10, xmm12
	vaddss	xmm12, xmm12, xmm9
	vaddss	xmm12, xmm4, xmm12
	vmovss	xmm4, DWORD PTR [rbx+rax*4]
	vaddss	xmm12, xmm5, xmm12
	vaddss	xmm12, xmm12, xmm4
	vmulss	xmm12, xmm12, DWORD PTR .LC3[rip]
	vmovss	DWORD PTR 0[r13+r14*4], xmm12
	jle	.L51
	vaddss	xmm2, xmm2, xmm8
	lea	eax, 3[r15]
	cdqe
	add	r9, rax
	lea	r10, [r8+rax]
	add	rax, rdi
	vaddss	xmm3, xmm2, xmm3
	vaddss	xmm3, xmm3, DWORD PTR [rbx+r9*4]
	vaddss	xmm3, xmm3, xmm10
	vaddss	xmm2, xmm3, xmm9
	vaddss	xmm2, xmm2, DWORD PTR [rbx+r10*4]
	vaddss	xmm2, xmm2, xmm5
	vaddss	xmm2, xmm2, xmm4
	vaddss	xmm2, xmm2, DWORD PTR [rbx+rax*4]
	vmulss	xmm2, xmm2, DWORD PTR .LC3[rip]
	vmovss	DWORD PTR 0[r13+r11*4], xmm2
.L51:
	mov	rax, QWORD PTR 32[rsp]
	mov	r9d, DWORD PTR 68[rsp]
	add	QWORD PTR 72[rsp], rax
	add	rsi, rax
	add	rdx, rax
	add	rcx, rax
	cmp	DWORD PTR 64[rsp], r9d
	jne	.L50
	vzeroupper
.L71:
	lea	rsp, -40[rbp]
	pop	rbx
	pop	r12
	pop	r13
	pop	r14
	pop	r15
	pop	rbp
	ret
.L59:
	xor	r10d, r10d
	mov	eax, 1
	jmp	.L57
.L58:
	mov	r15d, eax
	jmp	.L54
	.size	blur3x3, .-blur3x3
	.p2align 4
	.globl	checksum
	.type	checksum, @function
checksum:
	endbr64
	movsx	rsi, esi
	imul	rsi, rsi
	test	rsi, rsi
	je	.L76
	vxorps	xmm2, xmm2, xmm2
	lea	rax, [rdi+rsi*4]
	vxorpd	xmm1, xmm1, xmm1
	.p2align 4,,10
	.p2align 3
.L75:
	vcvtss2sd	xmm0, xmm2, DWORD PTR [rdi]
	add	rdi, 4
	vaddsd	xmm1, xmm1, xmm0
	cmp	rax, rdi
	jne	.L75
	vmovsd	xmm0, xmm1, xmm1
	ret
	.p2align 4,,10
	.p2align 3
.L76:
	vxorpd	xmm1, xmm1, xmm1
	vmovsd	xmm0, xmm1, xmm1
	ret
	.size	checksum, .-checksum
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC8:
	.string	"usage: %s [N>=3] [REPEATS>=1]\n"
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC9:
	.string	"out of memory\n"
	.section	.rodata.str1.8
	.align 8
.LC12:
	.string	"N=%d repeats=%d checksum=%.6f time=%.3f s  (%.2f GFLOP/s)\n"
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
	endbr64
	push	r15
	push	r14
	push	r13
	push	r12
	push	rbp
	push	rbx
	mov	ebx, 768
	sub	rsp, 72
	mov	rax, QWORD PTR fs:40
	mov	QWORD PTR 56[rsp], rax
	xor	eax, eax
	cmp	edi, 1
	mov	DWORD PTR 12[rsp], 3
	jg	.L99
.L79:
	movsx	rbp, ebx
	mov	edi, 64
	imul	rbp, rbp
	sal	rbp, 2
	mov	rsi, rbp
	call	aligned_alloc@PLT
	mov	rsi, rbp
	mov	edi, 64
	mov	r14, rax
	call	aligned_alloc@PLT
	mov	rsi, rbp
	mov	edi, 64
	mov	r13, rax
	call	aligned_alloc@PLT
	mov	rsi, rbp
	mov	edi, 64
	mov	r12, rax
	call	aligned_alloc@PLT
	test	r14, r14
	mov	rbp, rax
	je	.L83
	test	r13, r13
	je	.L83
	test	r12, r12
	je	.L83
	test	rax, rax
	je	.L83
	lea	rsi, 32[rsp]
	mov	edi, 1
	xor	r15d, r15d
	mov	QWORD PTR 24[rsp], rsi
	call	clock_gettime@PLT
	vxorpd	xmm6, xmm6, xmm6
	mov	esi, ebx
	mov	rdi, r14
	vcvtsi2sd	xmm0, xmm6, QWORD PTR 32[rsp]
	vcvtsi2sd	xmm1, xmm6, QWORD PTR 40[rsp]
	vfmadd132sd	xmm1, xmm0, QWORD PTR .LC10[rip]
	vmovsd	QWORD PTR 16[rsp], xmm1
	call	fill_random
	mov	esi, ebx
	mov	rdi, r13
	call	fill_random
	mov	QWORD PTR [rsp], 0x000000000
	.p2align 4,,10
	.p2align 3
.L87:
	mov	ecx, ebx
	mov	rdx, r12
	mov	rsi, r13
	mov	rdi, r14
	vzeroupper
	call	matmul
	mov	rsi, rbp
	mov	rdi, r12
	mov	edx, ebx
	add	r15d, 1
	call	blur3x3
	mov	esi, ebx
	mov	rdi, rbp
	call	checksum
	mov	eax, DWORD PTR 12[rsp]
	vaddsd	xmm3, xmm0, QWORD PTR [rsp]
	cmp	r15d, eax
	vmovsd	QWORD PTR [rsp], xmm3
	jne	.L87
	mov	rsi, QWORD PTR 24[rsp]
	mov	edi, 1
	vzeroupper
	call	clock_gettime@PLT
	vxorpd	xmm5, xmm5, xmm5
	mov	ecx, r15d
	mov	edx, ebx
	vcvtsi2sd	xmm0, xmm5, QWORD PTR 32[rsp]
	mov	edi, 2
	mov	eax, 3
	vcvtsi2sd	xmm1, xmm5, QWORD PTR 40[rsp]
	lea	rsi, .LC12[rip]
	vfmadd132sd	xmm1, xmm0, QWORD PTR .LC10[rip]
	vcvtsi2sd	xmm0, xmm5, ebx
	vsubsd	xmm1, xmm1, QWORD PTR 16[rsp]
	vaddsd	xmm2, xmm0, xmm0
	vmulsd	xmm2, xmm2, xmm0
	vmulsd	xmm2, xmm2, xmm0
	vcvtsi2sd	xmm0, xmm5, r15d
	vmulsd	xmm2, xmm2, xmm0
	vmovsd	xmm0, QWORD PTR [rsp]
	vdivsd	xmm2, xmm2, QWORD PTR .LC11[rip]
	vdivsd	xmm2, xmm2, xmm1
	call	__printf_chk@PLT
	mov	rdi, r14
	call	free@PLT
	mov	rdi, r13
	call	free@PLT
	mov	rdi, r12
	call	free@PLT
	mov	rdi, rbp
	call	free@PLT
	xor	eax, eax
.L78:
	mov	rdx, QWORD PTR 56[rsp]
	sub	rdx, QWORD PTR fs:40
	jne	.L100
	add	rsp, 72
	pop	rbx
	pop	rbp
	pop	r12
	pop	r13
	pop	r14
	pop	r15
	ret
.L99:
	mov	ebp, edi
	mov	rdi, QWORD PTR 8[rsi]
	mov	r12, rsi
	mov	edx, 10
	xor	esi, esi
	call	strtol@PLT
	cmp	ebp, 2
	mov	r13, rax
	mov	ebx, eax
	je	.L80
	mov	rdi, QWORD PTR 16[r12]
	mov	edx, 10
	xor	esi, esi
	call	strtol@PLT
	mov	DWORD PTR 12[rsp], eax
.L80:
	cmp	r13d, 2
	jle	.L91
	cmp	DWORD PTR 12[rsp], 0
	jg	.L79
.L91:
	mov	rcx, QWORD PTR [r12]
	mov	rdi, QWORD PTR stderr[rip]
	lea	rdx, .LC8[rip]
	xor	eax, eax
	mov	esi, 2
	call	__fprintf_chk@PLT
.L82:
	mov	eax, 1
	jmp	.L78
.L100:
	call	__stack_chk_fail@PLT
.L83:
	mov	rcx, QWORD PTR stderr[rip]
	mov	edx, 14
	mov	esi, 1
	lea	rdi, .LC9[rip]
	call	fwrite@PLT
	jmp	.L82
	.size	main, .-main
	.data
	.align 4
	.type	rng_state, @object
	.size	rng_state, 4
rng_state:
	.long	-1831433054
	.section	.rodata.cst4,"aM",@progbits,4
	.align 4
.LC0:
	.long	931135488
	.align 4
.LC1:
	.long	-1090519040
	.set	.LC3,.LC4
	.section	.rodata.cst8,"aM",@progbits,8
	.align 8
.LC4:
	.long	1038323257
	.long	1038323257
	.align 8
.LC10:
	.long	-400107883
	.long	1041313291
	.align 8
.LC11:
	.long	0
	.long	1104006501
	.ident	"GCC: (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
