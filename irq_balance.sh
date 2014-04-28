#!/bin/bash

#Get the number of cpus
CPUNUM=`more /proc/cpuinfo |grep "physical id"|uniq|wc -l`
if [ $CPUNUM == 0 ] ; then
        echo "Get the number of CPUs failed"
        exit
fi

#stop the service of irqbalance
IRQSTATUS=`service irqbalance status | grep [...]`
if [ "$IRQSTATUS" ] ; then
        killall irqbalance
        echo "wait for service irqbalance to full stop..."
        sleep 5
fi

#get the rx&tx queues of all network interface
ALLDEV=`grep eth /proc/interrupts | awk '{print $1, $NF}' | grep -i - |awk '{print $2}'`

#do the binding
CURCPU=0
for DEV in $ALLDEV
do
        MASK=$((1<<$CURCPU))
        IRQ=`cat /proc/interrupts | grep $DEV | cut  -d:  -f1 | sed "s/ //g"`
        if [ -n $IRQ ] ; then
                printf "%X" $MASK > /proc/irq/$IRQ/smp_affinity
                sleep 1
                echo "bind $DEV($IRQ) to " `cat /proc/irq/$IRQ/smp_affinity`
                CURCPU=$((($CURCPU + 1)%$CPUNUM))
        fi
done
