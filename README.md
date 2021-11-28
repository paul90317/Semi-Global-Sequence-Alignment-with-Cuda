# Independent-Topic-on-Computer-Science-in-NCKU  
## DNA sequence affine gap score with GPU  
`Let y's length >> x's length.`  
`x fixed end and y free end`  
**Affine Gap of x and y**  
I used dynamic programing to save this problem, hoever, the time complex is O(nm), which is product of x's length and y's length.  
If we just want score but not alignment, it very easy to reduce the space complex from O(nm) to O(n), because the block we calculate only depend on last block(top, left, diagnal).  
**Very long y**  
y is very long so that I can't save it into array, I use stream to handle it, if just want the score.  
**Dynamic programing with GPU**  
With DP, it solve in dianal vector(from left top to right bottom), and it normal vector is independent, so we can parallel it with GPU.  
the time complex can reduce to O(m), which is y's length.  
## DNA sequence alignment with GPU  
**Bottleneck of space**  
if we save the alignment with linked list table, the space is O(nm) which must exceed the memory a computer, have.
**Save y interval**  
We can save just save the position where aligment of y start from and end, space complex is O(n), which is not alignment.  
**Alignment of x and y's interval**  
alignment of x(fixed end) and y(free end) is equivalent to alignment of x(fixed end) and y's interval(fixed end).  
the space complex of alignment is O(nn), which is smaller but still too big. However, we can save y's interval into array which make our O(n) space alignment possible.  
**Linear space alignment of x and y's interval**  
we can slice the problem into subproblem, chose yj, calculate where i(xi) the yj corresponding to, space cpmlex  
if we let j=middle of uper and lower bound, the time complex is O(nlgn),  which is least and considered with GPU parallelism.  
**Analysis**  
* if we have enough GPU threads(the number if thread >= n).  
time complex = O(m + nlgn).  
space complex = O(n).  
* else  
time complex = O(nm/t + nm/t), which t is threads we have  
space complex = O(n).  
## How to use  
`make runall1` run linear space alignment of `res/x.txt`, `res/y.txt` with GPU.  
`make runall2` run 2D space alignment of `res/x.txt`, `res/y.txt`, which is achieve by linked list table with GPU.  
`make runafg` run affine gap score with GPU.  
`make runcpu` run affine gap score with CPU.  
> `make runallx` command will output `almout.txt` in `res` folder, and print three number, which is free end y's affinegap score, fixed end alinment score, and check what the output aligment score is, if three number is same, the alignment in `res/almount.txt` is correct.  
