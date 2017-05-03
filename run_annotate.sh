#!/bin/bash -ex
#BSUB -q mpi-long+
#BSUB -o log-annotate.%J
#BSUB -e log-annotate.%J
#BSUB -W 120:00
#BSUB -n 240
#BSUB -a openmpi
#BSUB -m hh
#BSUB -R cbscratch
#BSUB -R "span[ptile=16]"

source paths-latest.sh

source uniclust/make_annotate.sh

function notExists() {
    [ ! -f "$1" ]
}

if notExists "${TARGET}/uniboost10_${RELEASE}_a3m.ffdata" \
   || notExists "${TARGET}/uniboost10_${RELEASE}_a3m.ffindex"; then
    a3m_database_extract -i "${TARGET}/uniboost10_${RELEASE}_ca3m" -o "${TARGET}/uniboost10_${RELEASE}_a3m" -d "${TARGET}/uniboost10_${RELEASE}_sequence" -q "${TARGET}/uniboost10_${RELEASE}_header"
fi

make_annotation "$TARGET" "uniboost10_${RELEASE}" "$HHDBPATH"

if notExists "${TARGET}/uniclust_${RELEASE}_annotation.tar.gz"; then
    TMPPATH="$TARGET/tmp/annotation"
    mkdir -p "$TARGET/tmp/annotation"
    make_lengths "$TARGET" "$HHDBPATH" "$TMPPATH/lengths"
    make_tsv "$TARGET" "${RELEASE}" "uniboost10" "uniclust30" "$TMPPATH/lengths" "$TMPPATH"
    make_annotation_archive "$TARGET" "${RELEASE}" "${TMPPATH}/uniclust30_${RELEASE}"
fi
