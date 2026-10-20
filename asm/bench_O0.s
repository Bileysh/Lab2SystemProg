	.file	"bench.c"
	.intel_syntax noprefix
	.text
	.data
	.align 4
	.type	rng_state, @object
	.size	rng_state, 4
rng_state:
	.long	-1831433054
	.text
	.type	xorshift32, @function
xorshift32:
	push	rbp
	mov	rbp, rsp
	mov	eax, DWORD PTR rng_state[rip]
	mov	DWORD PTR -4[rbp], eax
	mov	eax, DWORD PTR -4[rbp]
	sal	eax, 13
	xor	DWORD PTR -4[rbp], eax
	mov	eax, DWORD PTR -4[rbp]
	shr	eax, 17
	xor	DWORD PTR -4[rbp], eax
	mov	eax, DWORD PTR -4[rbp]
	sal	eax, 5
	xor	DWORD PTR -4[rbp], eax
	mov	eax, DWORD PTR -4[rbp]
	mov	DWORD PTR rng_state[rip], eax
	mov	eax, DWORD PTR rng_state[rip]
	pop	rbp
	ret
	.size	xorshift32, .-xorshift32
	.type	at, @function
at:
	push	rbp
	mov	rbp, rsp
	mov	QWORD PTR -8[rbp], rdi
	mov	DWORD PTR -12[rbp], esi
	mov	DWORD PTR -16[rbp], edx
	mov	DWORD PTR -20[rbp], ecx
	mov	eax, DWORD PTR -16[rbp]
	movsx	rdx, eax
	mov	eax, DWORD PTR -12[rbp]
	cdqe
	imul	rdx, rax
	mov	eax, DWORD PTR -20[rbp]
	cdqe
	add	rax, rdx
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -8[rbp]
	add	rax, rdx
	pop	rbp
	ret
	.size	at, .-at
	.globl	fill_random
	.type	fill_random, @function
fill_random:
	endbr64
	push	rbp
	mov	rbp, rsp
	sub	rsp, 32
	mov	QWORD PTR -24[rbp], rdi
	mov	DWORD PTR -28[rbp], esi
	mov	DWORD PTR -8[rbp], 0
	jmp	.L6
.L11:
	mov	DWORD PTR -4[rbp], 0
	jmp	.L7
.L10:
	call	xorshift32
	movzx	eax, ax
	mov	eax, eax
	test	rax, rax
	js	.L8
	pxor	xmm0, xmm0
	cvtsi2ss	xmm0, rax
	jmp	.L9
.L8:
	mov	rdx, rax
	shr	rdx
	and	eax, 1
	or	rdx, rax
	pxor	xmm0, xmm0
	cvtsi2ss	xmm0, rdx
	addss	xmm0, xmm0
.L9:
	movss	xmm1, DWORD PTR .LC0[rip]
	divss	xmm0, xmm1
	movss	DWORD PTR -32[rbp], xmm0
	mov	ecx, DWORD PTR -4[rbp]
	mov	edx, DWORD PTR -8[rbp]
	mov	esi, DWORD PTR -28[rbp]
	mov	rax, QWORD PTR -24[rbp]
	mov	rdi, rax
	call	at
	movss	xmm1, DWORD PTR .LC1[rip]
	movss	xmm0, DWORD PTR -32[rbp]
	subss	xmm0, xmm1
	movss	DWORD PTR [rax], xmm0
	add	DWORD PTR -4[rbp], 1
.L7:
	mov	eax, DWORD PTR -4[rbp]
	cmp	eax, DWORD PTR -28[rbp]
	jl	.L10
	add	DWORD PTR -8[rbp], 1
.L6:
	mov	eax, DWORD PTR -8[rbp]
	cmp	eax, DWORD PTR -28[rbp]
	jl	.L11
	nop
	nop
	leave
	ret
	.size	fill_random, .-fill_random
	.globl	matmul
	.type	matmul, @function
matmul:
	endbr64
	push	rbp
	mov	rbp, rsp
	sub	rsp, 48
	mov	QWORD PTR -24[rbp], rdi
	mov	QWORD PTR -32[rbp], rsi
	mov	QWORD PTR -40[rbp], rdx
	mov	DWORD PTR -44[rbp], ecx
	mov	eax, DWORD PTR -44[rbp]
	movsx	rdx, eax
	mov	eax, DWORD PTR -44[rbp]
	cdqe
	imul	rax, rdx
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -40[rbp]
	mov	esi, 0
	mov	rdi, rax
	call	memset@PLT
	mov	DWORD PTR -16[rbp], 0
	jmp	.L13
.L18:
	mov	DWORD PTR -12[rbp], 0
	jmp	.L14
.L17:
	mov	eax, DWORD PTR -16[rbp]
	movsx	rdx, eax
	mov	eax, DWORD PTR -44[rbp]
	cdqe
	imul	rdx, rax
	mov	eax, DWORD PTR -12[rbp]
	cdqe
	add	rax, rdx
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -24[rbp]
	add	rax, rdx
	movss	xmm0, DWORD PTR [rax]
	movss	DWORD PTR -4[rbp], xmm0
	mov	DWORD PTR -8[rbp], 0
	jmp	.L15
.L16:
	mov	eax, DWORD PTR -16[rbp]
	movsx	rdx, eax
	mov	eax, DWORD PTR -44[rbp]
	cdqe
	imul	rdx, rax
	mov	eax, DWORD PTR -8[rbp]
	cdqe
	add	rax, rdx
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -40[rbp]
	add	rax, rdx
	movss	xmm1, DWORD PTR [rax]
	mov	eax, DWORD PTR -12[rbp]
	movsx	rdx, eax
	mov	eax, DWORD PTR -44[rbp]
	cdqe
	imul	rdx, rax
	mov	eax, DWORD PTR -8[rbp]
	cdqe
	add	rax, rdx
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -32[rbp]
	add	rax, rdx
	movss	xmm0, DWORD PTR [rax]
	mulss	xmm0, DWORD PTR -4[rbp]
	mov	eax, DWORD PTR -16[rbp]
	movsx	rdx, eax
	mov	eax, DWORD PTR -44[rbp]
	cdqe
	imul	rdx, rax
	mov	eax, DWORD PTR -8[rbp]
	cdqe
	add	rax, rdx
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -40[rbp]
	add	rax, rdx
	addss	xmm0, xmm1
	movss	DWORD PTR [rax], xmm0
	add	DWORD PTR -8[rbp], 1
.L15:
	mov	eax, DWORD PTR -8[rbp]
	cmp	eax, DWORD PTR -44[rbp]
	jl	.L16
	add	DWORD PTR -12[rbp], 1
.L14:
	mov	eax, DWORD PTR -12[rbp]
	cmp	eax, DWORD PTR -44[rbp]
	jl	.L17
	add	DWORD PTR -16[rbp], 1
.L13:
	mov	eax, DWORD PTR -16[rbp]
	cmp	eax, DWORD PTR -44[rbp]
	jl	.L18
	nop
	nop
	leave
	ret
	.size	matmul, .-matmul
	.globl	blur3x3
	.type	blur3x3, @function
blur3x3:
	endbr64
	push	rbp
	mov	rbp, rsp
	sub	rsp, 64
	mov	QWORD PTR -40[rbp], rdi
	mov	QWORD PTR -48[rbp], rsi
	mov	DWORD PTR -52[rbp], edx
	mov	eax, DWORD PTR -52[rbp]
	movsx	rdx, eax
	mov	eax, DWORD PTR -52[rbp]
	cdqe
	imul	rax, rdx
	lea	rdx, 0[0+rax*4]
	mov	rcx, QWORD PTR -40[rbp]
	mov	rax, QWORD PTR -48[rbp]
	mov	rsi, rcx
	mov	rdi, rax
	call	memcpy@PLT
	movss	xmm0, DWORD PTR .LC2[rip]
	movss	DWORD PTR -4[rbp], xmm0
	mov	DWORD PTR -24[rbp], 1
	jmp	.L20
.L27:
	mov	DWORD PTR -20[rbp], 1
	jmp	.L21
.L26:
	pxor	xmm0, xmm0
	movss	DWORD PTR -16[rbp], xmm0
	mov	DWORD PTR -12[rbp], -1
	jmp	.L22
.L25:
	mov	DWORD PTR -8[rbp], -1
	jmp	.L23
.L24:
	mov	edx, DWORD PTR -24[rbp]
	mov	eax, DWORD PTR -12[rbp]
	add	eax, edx
	movsx	rdx, eax
	mov	eax, DWORD PTR -52[rbp]
	cdqe
	imul	rdx, rax
	mov	ecx, DWORD PTR -20[rbp]
	mov	eax, DWORD PTR -8[rbp]
	add	eax, ecx
	cdqe
	add	rax, rdx
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -40[rbp]
	add	rax, rdx
	movss	xmm0, DWORD PTR [rax]
	movss	xmm1, DWORD PTR -16[rbp]
	addss	xmm0, xmm1
	movss	DWORD PTR -16[rbp], xmm0
	add	DWORD PTR -8[rbp], 1
.L23:
	cmp	DWORD PTR -8[rbp], 1
	jle	.L24
	add	DWORD PTR -12[rbp], 1
.L22:
	cmp	DWORD PTR -12[rbp], 1
	jle	.L25
	mov	eax, DWORD PTR -24[rbp]
	movsx	rdx, eax
	mov	eax, DWORD PTR -52[rbp]
	cdqe
	imul	rdx, rax
	mov	eax, DWORD PTR -20[rbp]
	cdqe
	add	rax, rdx
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -48[rbp]
	add	rax, rdx
	movss	xmm0, DWORD PTR -16[rbp]
	mulss	xmm0, DWORD PTR -4[rbp]
	movss	DWORD PTR [rax], xmm0
	add	DWORD PTR -20[rbp], 1
.L21:
	mov	eax, DWORD PTR -52[rbp]
	sub	eax, 1
	cmp	DWORD PTR -20[rbp], eax
	jl	.L26
	add	DWORD PTR -24[rbp], 1
.L20:
	mov	eax, DWORD PTR -52[rbp]
	sub	eax, 1
	cmp	DWORD PTR -24[rbp], eax
	jl	.L27
	nop
	nop
	leave
	ret
	.size	blur3x3, .-blur3x3
	.globl	checksum
	.type	checksum, @function
checksum:
	endbr64
	push	rbp
	mov	rbp, rsp
	mov	QWORD PTR -24[rbp], rdi
	mov	DWORD PTR -28[rbp], esi
	pxor	xmm0, xmm0
	movsd	QWORD PTR -16[rbp], xmm0
	mov	QWORD PTR -8[rbp], 0
	jmp	.L29
.L30:
	mov	rax, QWORD PTR -8[rbp]
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -24[rbp]
	add	rax, rdx
	movss	xmm0, DWORD PTR [rax]
	cvtss2sd	xmm0, xmm0
	movsd	xmm1, QWORD PTR -16[rbp]
	addsd	xmm0, xmm1
	movsd	QWORD PTR -16[rbp], xmm0
	add	QWORD PTR -8[rbp], 1
.L29:
	mov	eax, DWORD PTR -28[rbp]
	movsx	rdx, eax
	mov	eax, DWORD PTR -28[rbp]
	cdqe
	imul	rax, rdx
	cmp	QWORD PTR -8[rbp], rax
	jb	.L30
	movsd	xmm0, QWORD PTR -16[rbp]
	pop	rbp
	ret
	.size	checksum, .-checksum
	.type	now_sec, @function
now_sec:
	endbr64
	push	rbp
	mov	rbp, rsp
	sub	rsp, 32
	mov	rax, QWORD PTR fs:40
	mov	QWORD PTR -8[rbp], rax
	xor	eax, eax
	lea	rax, -32[rbp]
	mov	rsi, rax
	mov	edi, 1
	call	clock_gettime@PLT
	mov	rax, QWORD PTR -32[rbp]
	pxor	xmm1, xmm1
	cvtsi2sd	xmm1, rax
	mov	rax, QWORD PTR -24[rbp]
	pxor	xmm2, xmm2
	cvtsi2sd	xmm2, rax
	movsd	xmm0, QWORD PTR .LC5[rip]
	mulsd	xmm0, xmm2
	addsd	xmm0, xmm1
	mov	rax, QWORD PTR -8[rbp]
	sub	rax, QWORD PTR fs:40
	je	.L34
	call	__stack_chk_fail@PLT
.L34:
	leave
	ret
	.size	now_sec, .-now_sec
	.section	.rodata
	.align 8
.LC6:
	.string	"usage: %s [N>=3] [REPEATS>=1]\n"
.LC7:
	.string	"out of memory\n"
	.align 8
.LC9:
	.string	"N=%d repeats=%d checksum=%.6f time=%.3f s  (%.2f GFLOP/s)\n"
	.text
	.globl	main
	.type	main, @function
main:
	endbr64
	push	rbp
	mov	rbp, rsp
	sub	rsp, 112
	mov	DWORD PTR -100[rbp], edi
	mov	QWORD PTR -112[rbp], rsi
	cmp	DWORD PTR -100[rbp], 1
	jle	.L36
	mov	rax, QWORD PTR -112[rbp]
	add	rax, 8
	mov	rax, QWORD PTR [rax]
	mov	rdi, rax
	call	atoi@PLT
	jmp	.L37
.L36:
	mov	eax, 768
.L37:
	mov	DWORD PTR -80[rbp], eax
	cmp	DWORD PTR -100[rbp], 2
	jle	.L38
	mov	rax, QWORD PTR -112[rbp]
	add	rax, 16
	mov	rax, QWORD PTR [rax]
	mov	rdi, rax
	call	atoi@PLT
	jmp	.L39
.L38:
	mov	eax, 3
.L39:
	mov	DWORD PTR -76[rbp], eax
	cmp	DWORD PTR -80[rbp], 2
	jle	.L40
	cmp	DWORD PTR -76[rbp], 0
	jg	.L41
.L40:
	mov	rax, QWORD PTR -112[rbp]
	mov	rdx, QWORD PTR [rax]
	mov	rax, QWORD PTR stderr[rip]
	lea	rcx, .LC6[rip]
	mov	rsi, rcx
	mov	rdi, rax
	mov	eax, 0
	call	fprintf@PLT
	mov	eax, 1
	jmp	.L42
.L41:
	mov	eax, DWORD PTR -80[rbp]
	movsx	rdx, eax
	mov	eax, DWORD PTR -80[rbp]
	cdqe
	imul	rax, rdx
	sal	rax, 2
	mov	QWORD PTR -64[rbp], rax
	mov	rax, QWORD PTR -64[rbp]
	mov	rsi, rax
	mov	edi, 64
	call	aligned_alloc@PLT
	mov	QWORD PTR -56[rbp], rax
	mov	rax, QWORD PTR -64[rbp]
	mov	rsi, rax
	mov	edi, 64
	call	aligned_alloc@PLT
	mov	QWORD PTR -48[rbp], rax
	mov	rax, QWORD PTR -64[rbp]
	mov	rsi, rax
	mov	edi, 64
	call	aligned_alloc@PLT
	mov	QWORD PTR -40[rbp], rax
	mov	rax, QWORD PTR -64[rbp]
	mov	rsi, rax
	mov	edi, 64
	call	aligned_alloc@PLT
	mov	QWORD PTR -32[rbp], rax
	cmp	QWORD PTR -56[rbp], 0
	je	.L43
	cmp	QWORD PTR -48[rbp], 0
	je	.L43
	cmp	QWORD PTR -40[rbp], 0
	je	.L43
	cmp	QWORD PTR -32[rbp], 0
	jne	.L44
.L43:
	mov	rax, QWORD PTR stderr[rip]
	mov	rcx, rax
	mov	edx, 14
	mov	esi, 1
	lea	rax, .LC7[rip]
	mov	rdi, rax
	call	fwrite@PLT
	mov	eax, 1
	jmp	.L42
.L44:
	call	now_sec
	movq	rax, xmm0
	mov	QWORD PTR -24[rbp], rax
	mov	edx, DWORD PTR -80[rbp]
	mov	rax, QWORD PTR -56[rbp]
	mov	esi, edx
	mov	rdi, rax
	call	fill_random
	mov	edx, DWORD PTR -80[rbp]
	mov	rax, QWORD PTR -48[rbp]
	mov	esi, edx
	mov	rdi, rax
	call	fill_random
	pxor	xmm0, xmm0
	movsd	QWORD PTR -72[rbp], xmm0
	mov	DWORD PTR -84[rbp], 0
	jmp	.L45
.L46:
	mov	ecx, DWORD PTR -80[rbp]
	mov	rdx, QWORD PTR -40[rbp]
	mov	rsi, QWORD PTR -48[rbp]
	mov	rax, QWORD PTR -56[rbp]
	mov	rdi, rax
	call	matmul
	mov	edx, DWORD PTR -80[rbp]
	mov	rcx, QWORD PTR -32[rbp]
	mov	rax, QWORD PTR -40[rbp]
	mov	rsi, rcx
	mov	rdi, rax
	call	blur3x3
	mov	edx, DWORD PTR -80[rbp]
	mov	rax, QWORD PTR -32[rbp]
	mov	esi, edx
	mov	rdi, rax
	call	checksum
	movsd	xmm1, QWORD PTR -72[rbp]
	addsd	xmm0, xmm1
	movsd	QWORD PTR -72[rbp], xmm0
	add	DWORD PTR -84[rbp], 1
.L45:
	mov	eax, DWORD PTR -84[rbp]
	cmp	eax, DWORD PTR -76[rbp]
	jl	.L46
	call	now_sec
	movq	rax, xmm0
	mov	QWORD PTR -16[rbp], rax
	pxor	xmm0, xmm0
	cvtsi2sd	xmm0, DWORD PTR -80[rbp]
	movapd	xmm1, xmm0
	addsd	xmm1, xmm0
	pxor	xmm0, xmm0
	cvtsi2sd	xmm0, DWORD PTR -80[rbp]
	mulsd	xmm1, xmm0
	pxor	xmm0, xmm0
	cvtsi2sd	xmm0, DWORD PTR -80[rbp]
	mulsd	xmm1, xmm0
	pxor	xmm0, xmm0
	cvtsi2sd	xmm0, DWORD PTR -76[rbp]
	mulsd	xmm0, xmm1
	movsd	xmm1, QWORD PTR .LC8[rip]
	divsd	xmm0, xmm1
	movsd	QWORD PTR -8[rbp], xmm0
	movsd	xmm0, QWORD PTR -16[rbp]
	movapd	xmm1, xmm0
	subsd	xmm1, QWORD PTR -24[rbp]
	movsd	xmm0, QWORD PTR -8[rbp]
	movapd	xmm2, xmm0
	divsd	xmm2, xmm1
	movsd	xmm0, QWORD PTR -16[rbp]
	subsd	xmm0, QWORD PTR -24[rbp]
	mov	rcx, QWORD PTR -72[rbp]
	mov	edx, DWORD PTR -76[rbp]
	mov	eax, DWORD PTR -80[rbp]
	movapd	xmm1, xmm0
	movq	xmm0, rcx
	mov	esi, eax
	lea	rax, .LC9[rip]
	mov	rdi, rax
	mov	eax, 3
	call	printf@PLT
	mov	rax, QWORD PTR -56[rbp]
	mov	rdi, rax
	call	free@PLT
	mov	rax, QWORD PTR -48[rbp]
	mov	rdi, rax
	call	free@PLT
	mov	rax, QWORD PTR -40[rbp]
	mov	rdi, rax
	call	free@PLT
	mov	rax, QWORD PTR -32[rbp]
	mov	rdi, rax
	call	free@PLT
	mov	eax, 0
.L42:
	leave
	ret
	.size	main, .-main
	.section	.rodata
	.align 4
.LC0:
	.long	1199570944
	.align 4
.LC1:
	.long	1056964608
	.align 4
.LC2:
	.long	1038323257
	.align 8
.LC5:
	.long	-400107883
	.long	1041313291
	.align 8
.LC8:
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
