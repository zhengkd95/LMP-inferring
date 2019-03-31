# LMP-inferring
Reproduce some interesting facts about local marginal prices (LMP) in electricity market.

## Requirements
- [Matpower](http://www.pserc.cornell.edu/matpower/) for building and solving opf problems;
- [Yalmip](https://yalmip.github.io/) and [sdpt3](http://www.math.nus.edu.sg/~mattohkc/sdpt3.html) for solving semidefinite programming problems;
- [epstopdf.exe](https://ctan.org/pkg/epstopdf?lang=en) to convert .eps files to .pdf files while keeping the sizes. It usually has been contained in Texlive.

## Reference
Kekatos V, Giannakis G B, Baldick R. Online energy price matrix factorization for power grid topology tracking[J]. IEEE Transactions on Smart Grid, 2016, 7(3): 1239-1248.
