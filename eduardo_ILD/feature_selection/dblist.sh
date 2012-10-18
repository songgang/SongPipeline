#!/bin/bash

dbroot='/mnt/data/PUBLIC/aibs1/Data/Input/DrewWarrenLungData/ATCases'



datelist="
ImageVolumes
"

dImageVolumes(){
imglist="
1e_20080825084611750_CT
1i_20080825084220343_CT
2e_20080825085141906_CT
2i_20080825084944359_CT
3e_20080825090219671_CT
3i_20080825085919171_CT
4e_20080825090933156_CT
4i_20080825090723937_CT
5e_20080825092313125_CT
5i_20080825092014687_CT
6e_20080825093510859_CT
6i_20080825093258359_CT
7e_20080825094236937_CT
7i_20080825093933015_CT
8e_20080825095547109_CT
8i_20080825095208078_CT
9e_20080825101125453_CT
9i_20080825100647906_CT
10e_20080825101618875_CT
10i_20080825101357328_CT
11e_20080825102301718_CT
11i_20080825102038000_CT
12e_20080825103153500_CT
12i_20080825102814984_CT
13e_20080825104811484_CT
13i_20080825103748906_CT
14e_20080825110056656_CT
14i_20080825105743406_CT
15e_20080825110855250_CT
15i_20080825110714984_CT
16e_20080825114353484_CT
16i_20080825113829890_CT
17e_20080825115025171_CT
17i_20080825114812109_CT
18e_20080825115654968_CT
18i_20080825115346593_CT
19e_20080825120904906_CT
19i_20080825120621468_CT
20e_20080825122559734_CT
20i_20080825122313718_CT
21e_20080825123313312_CT
21i_20080825123036375_CT
22e_20080916072908762_CT_shrink
22i_20080916072049199_CT_shrink
23e_20080916074327902_CT_shrink
23i_20080916073812465_CT_shrink
24e_20080916075322621_CT
24i_20080916075028730_CT
25e_20080916075836402_CT
25i_20080916075611887_CT
26e_20080916080404058_CT
26i_20080916080115027_CT
27e_20080916081110215_CT
27i_20080916080658590_CT
28e_20080916110443137_CT
28i_20080916104502340_CT
29e_20080916151128637_CT
29i_20080916150932902_CT
30e_20080916153938605_CT
30i_20080916153452230_CT
31e_20080916160310793_CT
31i_20080916154738683_CT
32e_20080916173443246_CT
32i_20080916173044152_CT
33e_20080916174026715_CT
33i_20080916173814715_CT
34e_20080918110725793_CT
34i_20080918110237621_CT
35e_20080918111315074_CT
35i_20080918111040730_CT
36e_20080918112059902_CT
36i_20080918111604449_CT
37e_20080918120120980_CT
37i_20080918115115027_CT
38e_20080918120954808_CT
38i_20080918120513105_CT
39e_20080918121731746_CT
39i_20080918121431621_CT
40e_20080918122524871_CT
40i_20080918122237465_CT
41e_20080918124045183_CT
41i_20080918123703824_CT
42e_20080918124716543_CT
42i_20080918124416590_CT
43e_20080918125458949_CT
43i_20080918125125902_CT
44e_20080918130326324_CT
44i_20080918130110918_CT
45e_20080918130910902_CT
45i_20080918130629574_CT
46e_20080918131627183_CT
46i_20080918131231637_CT
47e_20080918132638699_CT_shrink
47i_20080918131953433_CT_shrink
48e_20080918133712043_CT
48i_20080918133501137_CT
49e_20080918134243996_CT
49i_20080918133954012_CT
50e_20080918135430558_CT_shrink
50i_20080918134535730_CT_shrink
51e_20081027090851640_CT
51i_20081027090625781_CT
52e_20081027091514203_CT
52i_20081027091201203_CT
53e_20081027092108781_CT
53i_20081027091832125_CT
54e_20081027093007140_CT
54i_20081027092723906_CT
55e_20081027093740687_CT
55i_20081027093248734_CT
56e_20081027094428750_CT
56i_20081027094042265_CT
57e_20081027095052515_CT
57i_20081027094805546_CT
58e_20081027095619500_CT
58i_20081027095355843_CT
59e_20081027100226812_CT
59i_20081027095947031_CT
"
}


# 60e_20091007141743562_CT
# 60i_20091007141607609_CT



