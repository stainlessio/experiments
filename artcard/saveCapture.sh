#!/bin/sh

LARGEST=$(ls saved/*.pdf | cut -d- -f2 | cut -d. -f1 | sort -r | head -1)
NEXT=$(printf "%04d\n" $(($LARGEST + 1)))
PNG="capture-$NEXT.png"
PDF="capture-$NEXT.pdf"

if [ -e capture.png ]; then
  echo "Saving png"
  mv capture.png saved/$PNG
fi

if [ -e capture.pdf ]; then
  echo "Saving pdf"
  mv capture.pdf saved/$PDF
fi
