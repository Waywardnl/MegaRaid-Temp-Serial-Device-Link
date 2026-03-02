#!/bin/sh

STORCLI="/usr/local/sbin/storcli64"

# Maak tijdelijke mapping DID -> mfidX
MAPFILE=$(mktemp)

camcontrol devlist -v | awk '
/target/ {
    did=$4
}
/mfid[0-9]+/ {
    # FreeBSD awk ondersteunt geen match(), dus gebruik index()
    pos = index($0, "mfid")
    if (pos > 0) {
        dev = substr($0, pos)
        sub(/\).*/, "", dev)
        if (did != "" && dev != "")
            print did, dev
    }
}' > "$MAPFILE"

# Verwerk storcli dump
$STORCLI /c0 /eall /sall show all | awk -v map="$MAPFILE" '
BEGIN {
    # Mapping inlezen
    while ((getline < map) > 0) {
        didmap[$1] = $2
    }
}

# Start van een nieuw blok
/^Drive \/c0\/e[0-9]+\/s[0-9]+ :$/ {
    if (slot != "" && temp != "" && serial != "" && did != "") {
        dev = didmap[did]
        printf "Slot %s | Temp: %s | Serial: %s | DID: %s | Device: %s\n", slot, temp, serial, did, dev
    }
    slot=$2
    temp=""
    serial=""
    did=""
}

# DID regel
/^[0-9]+:[0-9]+/ {
    did=$2
}

# Temperatuur
/Drive Temperature/ {
    temp=$4
}

# Serienummer
/^SN =/ {
    gsub(/ /, "", $3)
    serial=$3
}

END {
    if (slot != "" && temp != "" && serial != "" && did != "") {
        dev = didmap[did]
        printf "Slot %s | Temp: %s | Serial: %s | DID: %s | Device: %s\n", slot, temp, serial, did, dev
    }
}
'

#!/bin/sh

#!/bin/sh

STORCLI="/usr/local/sbin/storcli64"

$STORCLI /c0 /eall /sall show all | awk '
# Start blok
/^Drive \/c0\/e[0-9]+\/s[0-9]+ :$/ {
    if (slot != "" && temp != "" && serial != "" && dg != "") {
        printf "Slot %s | Temp: %s | Serial: %s | DG: %s | Device: mfid%s\n", slot, temp, serial, dg, dg
    }
    slot=$2
    temp=""
    serial=""
    dg=""
}

# DG staat in de tabelregel
/^[0-9]+:[0-9]+/ {
    dg=$4
}

# Temp
/Drive Temperature/ {
    temp=$4
}

# Serial
/^SN =/ {
    gsub(/ /, "", $3)
    serial=$3
}

END {
    if (slot != "" && temp != "" && serial != "" && dg != "") {
        printf "Slot %s | Temp: %s | Serial: %s | DG: %s | Device: mfid%s\n", slot, temp, serial, dg, dg
    }
}
:q
root@BSD08:/tank/vm # /bin/Mega_Raid_disktemp.sh
Slot /c0/e245/s0 | Temp: 28C | Serial: 92M0A03CFJDH | DG: 0 | Device: mfid0
Slot /c0/e245/s3 | Temp: 27C | Serial: Z5J2A01WFJDH | DG: 1 | Device: mfid1
Slot /c0/e245/s4 | Temp: 33C | Serial: Y5F2A039FJDH | DG: 4 | Device: mfid4
Slot /c0/e245/s12 | Temp: 27C | Serial: Y5F2A07UFJDH | DG: 2 | Device: mfid2
Slot /c0/e245/s14 | Temp: 27C | Serial: Y5F2A03NFJDH | DG: 3 | Device: mfid3
root@BSD08:/tank/vm # cat /bin/Mega_Raid_disktemp.sh
#!/bin/sh

STORCLI="/usr/local/sbin/storcli64"

$STORCLI /c0 /eall /sall show all | awk '
# Start blok
/^Drive \/c0\/e[0-9]+\/s[0-9]+ :$/ {
    if (slot != "" && temp != "" && serial != "" && dg != "") {
        printf "Slot %s | Temp: %s | Serial: %s | DG: %s | Device: mfid%s\n", slot, temp, serial, dg, dg
    }
    slot=$2
    temp=""
    serial=""
    dg=""
}

# DG staat in de tabelregel
/^[0-9]+:[0-9]+/ {
    dg=$4
}

# Temp
/Drive Temperature/ {
    temp=$4
}

# Serial
/^SN =/ {
    gsub(/ /, "", $3)
    serial=$3
}

END {
    if (slot != "" && temp != "" && serial != "" && dg != "") {
        printf "Slot %s | Temp: %s | Serial: %s | DG: %s | Device: mfid%s\n", slot, temp, serial, dg, dg
    }
}
'
