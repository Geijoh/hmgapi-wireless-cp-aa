#!/bin/sh
# The CN7NPE engine regression (../cn7npe/test.py) for the Santa Fe: host-only, synthetic stock.
set -e
export CAR_PRODUCT=TM23.USA.0000.V016.010.260903 CAR_ONEBIN=tm23_us
exec python3 "$(dirname "$0")/../cn7npe/test.py"
