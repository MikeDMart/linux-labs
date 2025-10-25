obj-m += simple_monitor.o

all:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean

install:
	sudo insmod simple_monitor.ko

uninstall:
	sudo rmmod simple_monitor

test:
	cat /proc/simple_monitor
