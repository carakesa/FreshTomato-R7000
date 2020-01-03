#!/bin/sh

#set -x


### Block all traffic from listed. Use ISO code ###
ISO="cn-aggregated tw-aggregated kp-aggregated kr-aggregated ru-aggregated ir-ag                                                                                                             gregated"

#Testing
#ISO="kr-aggregated"

### Set PATH ###
IPT=/usr/sbin/iptables
WGET=/usr/bin/wget
EGREP=/bin/egrep
LOCKFILE=/tmp/ipblocklock.txt

### No editing below ###
inSPAMLIST="countrydropin"
outSPAMLIST="countrydropout"
ZONEROOT="/opt/ipblock/zones"
DLROOT="http://www.ipdeny.com/ipblocks/data/aggregated"
iBL="/opt/ipblock/zones/ipblockin.sh"
oBL="/opt/ipblock/zones/ipblockout.sh"

if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
    echo "Lock file exist.. exiting"
    exit
fi

# make sure the lockfile is removed when we exit and then claim it
trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
echo $$ > ${LOCKFILE}

cleanOldRules(){
$IPT -F countrydropin
$IPT -F countrydropout
}

# create a dir
[ ! -d $ZONEROOT ] && /bin/mkdir -p $ZONEROOT

# clean old rules
cleanOldRules
rm -f $iBL
rm -f $oBL

echo '*filter' > $iBL
echo '*filter' > $oBL

for c in $ISO
do
        # local zone file
        tDB=$ZONEROOT/$c.zone

        # get fresh zone file
        $WGET -T 30 -O $tDB $DLROOT/$c.zone

        awk -v inSPAMLIST=$inSPAMLIST '{print "-A "inSPAMLIST" -s "$1" -j DROP"}                                                                                                             ' $tDB >> $iBL
        awk -v outSPAMLIST=$outSPAMLIST '{print "-A "outSPAMLIST" -d "$1" -j REJ                                                                                                             ECT"}' $tDB >> $oBL
done

echo 'COMMIT' >> $iBL
echo 'COMMIT' >> $oBL

iptables-restore -n < $iBL
iptables-restore -n < $oBL

rm -f ${LOCKFILE}
