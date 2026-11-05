#!/bin/sh
# Off-car test on the patch engine (HMGAPI_SDK=<unpacked SDK> usb-wifi-rtl8811au/test.sh): the driver goes in over the expected stock file only,
# the service is planned, and removing the mod gives the stock bytes back.
set -e
cd "$(dirname "$0")/.."
. "${HMGAPI_SDK:?set HMGAPI_SDK to the unpacked HMG-API mod SDK}/test/lib.sh"
export HMGAPI_PRODUCT=SG2EV.USA.0000.V015.012.260507 HMGAPI_ONEBIN=sg2ev_us
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
R=$T/root
sum() { python3 -c 'import hashlib,sys; print(hashlib.md5(open(sys.argv[1],"rb").read()).hexdigest())' "$1"; }
mkdir -p $R/data/hmgapi/mods $R/data/hmgapi/settings $R/system/wifi
printf 'ro.board.platform=tcc803x\n' > $R/props.txt
: > $R/settings.txt
cp -r usb-wifi-rtl8811au $R/data/hmgapi/mods/; rm $R/data/hmgapi/mods/usb-wifi-rtl8811au/test.sh
python3 - "$R/data/hmgapi/mods/usb-wifi-rtl8811au/mod.json" <<'P'
import json,sys
d=json.load(open(sys.argv[1])); d.pop("requires"); json.dump(d,open(sys.argv[1],"w"))
P
echo "not the expected stock driver" > $R/system/wifi/bcmdhd.ko
ORIG=$(sum $R/system/wifi/bcmdhd.ko)
eng apply; has "unknown stock driver refused" "$ORIG" "$out"
check "... and left alone" "$ORIG" "$(sum $R/system/wifi/bcmdhd.ko)"
python3 - "$R/data/hmgapi/settings/hmgapi.json" "$ORIG" <<'P'
import json,sys
json.dump({"overrides":{"accept_baseline":[{"path":"/system/wifi/bcmdhd.ko","md5":sys.argv[2]}]}},open(sys.argv[1],"w"))
P
eng plan; has "service planned" "usb-wifi-rtl8811au/usbguard as root, at boot" "$out"
eng apply; check "apply" 0 $rc
check "driver in place" "$(sum usb-wifi-rtl8811au/files/bcmdhd-rtl8811au.ko)" "$(sum $R/system/wifi/bcmdhd.ko)"
eng restore; check "restore" 0 $rc
check "stock bytes back" "$ORIG" "$(sum $R/system/wifi/bcmdhd.ko)"
exit $fail
