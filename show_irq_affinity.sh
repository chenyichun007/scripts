#!/bin/bash

#get the rx&tx queues of all network interface
ALLDEV=`grep eth /proc/interrupts | awk '{print $1, $NF}' | grep -i - |awk '{print $2}'`

#show the affinity
for DEV in $ALLDEV
do
        IRQ=`cat /proc/interrupts | grep $DEV | cut  -d:  -f1 | sed "s/ //g"`
        if [ -n $IRQ ] ; then
                echo "$DEV($IRQ) is affinitive with " `cat /proc/irq/$IRQ/smp_affinity`
        fi
done
