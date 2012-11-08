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