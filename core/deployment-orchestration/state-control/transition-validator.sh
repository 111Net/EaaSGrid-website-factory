#!/usr/bin/env bash

set -Eeuo pipefail

FROM="${1:-}"
TO="${2:-}"

if [[ -z "${FROM}" || -z "${TO}" ]]
then
    echo "ERROR: transition requires FROM TO"
    exit 1
fi

case "${FROM}->${TO}" in

"CREATED->PACKAGED")
;;

"PACKAGED->TARGET_RESOLVED")
;;

"TARGET_RESOLVED->EXECUTED")
;;

"EXECUTED->VERIFIED")
;;

"VERIFIED->COMPLETED")
;;

"EXECUTED->FAILED")
;;

"FAILED->ROLLED_BACK")
;;

"ROLLED_BACK->RECOVERABLE")
;;

"RECOVERABLE->RESUME_READY")
;;

*)
echo "transition_valid=false"
echo "${FROM}->${TO}"
exit 1
;;

esac
case "${FROM}->${TO}" in

"CREATED->PACKAGED")
;;

"PACKAGED->TARGET_RESOLVED")
;;

"TARGET_RESOLVED->EXECUTED")
;;

"EXECUTED->VERIFIED")
;;

"VERIFIED->COMPLETED")
;;

"EXECUTED->FAILED")
;;

"FAILED->ROLLED_BACK")
;;

"ROLLED_BACK->RECOVERABLE")
;;

"RECOVERABLE->RESUME_READY")
;;

*)
echo "transition_valid=true"
echo "${FROM}->${TO}"
exit 1
;;

esac
