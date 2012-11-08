pe serial=4
failed case:
n20
n22
n24

seems random failure!



change script for betterin debugging:
1. consolidate the error output in .sh.e* also to ANTSCall.txt
2. compile using RelWithDebInfo, ANTS seems failed?
3. use ImageMath NeighborhoodCorrelation to compute correlation instead of MeasureImageSimilarity

4. first benchmark: compare:
affine only
affine + ANTS
affine + antsRegistration

5. use sphinx to generate the html

go to sbuild/
make html

5.1 how to set up
make a new directory sbuild
run:
sphinx-quickstart

modify index.rst to include ../test.rst

type make html

result is in _build/

not successfully finished using 4 slots
04: memory
08: memory
10: pthread
12: pthread? memory
15: moemory
20: pthread
22: pthread
24: memory

try 8 slots now
