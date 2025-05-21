ASM = nasm
BOOTSTRAP_FILE = bootstrap.asm
KERNEL_FILE = test_kernel.asm
FLOPPY_IMAGE = floppy.img

build: $(BOOTSTRAP_FILE) $(KERNEL_FILE)
	$(ASM) -f bin $(BOOTSTRAP_FILE) -o bootstrap.o
	$(ASM) -f bin $(KERNEL_FILE) -o test_kernel.o
	dd if=/dev/zero of=$(FLOPPY_IMAGE) bs=512 count=2880
	dd if=bootstrap.o of=$(FLOPPY_IMAGE) conv=notrunc
	dd if=test_kernel.o of=$(FLOPPY_IMAGE) bs=512 seek=1 conv=notrunc

run: build
	bochs -f bochsrc.txt

clean:
	rm -f *.o $(FLOPPY_IMAGE)