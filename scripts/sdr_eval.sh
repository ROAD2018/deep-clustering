#!/usr/bin/env bash
# wujian@2018


set -eu

[ $# -ne 2 ] && echo "format error: $0 <mix-scp> <sdr-scp>" && exit 1

[ ! -f spk2gender ] && echo "$0: missing spk2gender" && exit 1

src_scp=$1
sdr_scp=$2

awk '{print $1}' $src_scp | \
awk 'BEGIN{
  while (getline < "spk2gender") {
    if ($2 == 0)
      spk2gender[$1] = "F";
    else 
      spk2gender[$1] = "M";
  }
} {
  split($1, t, "_");
  s1 = spk2gender[substr(t[1], 0, 3)]
  s2 = spk2gender[substr(t[3], 0, 3)]
  printf("%s\t%s%s\n", $1, s1, s2)
}' | \
awk -v sdr=$sdr_scp 'BEGIN{
  while (getline < sdr) {
    mix2sdr[$1] = $2; 
  }
  FF = 0; nFF = 0;
  FM = 0; nFM = 0;
  MM = 0; nMM = 0;
} {
if ($2 == "FM" || $2 == "MF") {
  FM += mix2sdr[$1];
  nFM += 1;
} else if ($2 == "MM") {
  MM += mix2sdr[$1];
  nMM += 1;
} else {
  FF += mix2sdr[$1];
  nFF += 1;
}
} END {
  printf("FF sdr/num-utts = %.2f/%d\n", FF / nFF, nFF);
  printf("MM sdr/num-utts = %.2f/%d\n", MM / nMM, nMM);
  printf("FM sdr/num-utts = %.2f/%d\n", FM / nFM, nFM);
  printf("-- sdr/num-utts = %.2f/%d\n", (FF + FM + MM) / (nFF + nMM + nFM), nFF + nMM + nFM);
}'


