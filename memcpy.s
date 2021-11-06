.text
.align 2
.global MEMCPY

		/*Dictionary registers:
		x0 -> pointer to destination
		x1 -> Pointer to source
		x2-> length of copy
		

/* In this Memcpy I did my best to try and unroll the loop
	similar to MemCpy4 in the spec */

MEMCPY: 	stp			x29, x30, [sp, -16]!
			stp 		x19, x20, [sp, -16]!
			stp 		x21, x22, [sp, -16]!
			stp 		x23, x24, [sp, -16]!
			stp 		x25, x26, [sp, -16]!

			mov 		x20, 0
			mov 		x25, 16
			mov 		x26, 8
			udiv		x21, x2, x25
			mov 		x23, x21
			msub 		x21, x24, x26, x23
			sub 		x23, x26, x23 
			mul 		x23, x23, x26

			ldr 		x19, =Jumptable
			add 		x19, x19, x23
			br 			x19
			cmp 		x21,0
			beq			bottom

			b 			MEMCPY

		/*Using the Jumptable to copy a specific memory on the table
			then branching to the original byte continuing it in an a unrolled loop, In the function there were
			certain parameters that follows the duff device in having and are seperated by cases */	

Jumptable:	
			add			x21, x21, 1
			ldr 		q1,[x22], 16	// Should load the 16 bytes, 1st case with none remaining
			str			q1,[x21], 16	//Stores the 16 bytes
			sub			x23,x23, 16		
			cbz 		x23, bottom   // This should compare and break the loop once it is finished copying
			mov 		x0, x23
			mov 		x1, 16
			udiv		x2, x0, x1
			msub		x3, x2, x1, x0
			cbz 		x3, MEMCPY 		//This loops if it is divisble by 16, otherwise it breaks to the amount of Memory being Copied
			ldr 		x2, [x22], 8    
			str 		x2, [x21], 8
			sub			x23, x23, 8
			cbz 		x23, bottom
			mov 		x0, x23
			mov 		x1, 8
			udiv		x2, x0, x1
			msub 		x3, x2, x1, x0
			cbz 		x3, MEMCPY
			ldr 		w3, [x22], 4
			str 		w3, [x21], 4
			sub 		x23, x23, 4
			cbz 		x23, bottom
			mov			x0, x23 
			mov 		x1, 4
			udiv 		x2, x0, x1
			msub		x3, x2, x1, x0
			cbz 		x3, MEMCPY
			ldrh 		w4, [x22], 2
			strh 		w4, [x21], 2
			sub 		x23, x23, 2
			cbz			x23, bottom
			mov 		x0, x23
			mov 		x1, 2
			udiv 		x2, x0, x1
			msub		x3, x2, x1, x20
			cbz			x3, MEMCPY
			ldrb		w5, [x22], 1
			strb 		w5, [x21], 1
			sub 		x23, x23, 1

			mov 		x0, 0
			cmp 		x23, x0
			bgt			MEMCPY

/*In the bottom function all it's doing is returing the stored pointers from the Memcpy */

bottom:		
		
	
			ldp 		x25, x26, [sp], 16
			ldp 		x23, x24, [sp], 16
			ldp 		x21, x22, [sp], 16
			ldp 		x19, x20, [sp], 16
			ldp 		x29, x30, [sp], 16
			mov			x0, xzr
			ret 		 		
		.data

		.end
