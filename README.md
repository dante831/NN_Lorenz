# NN_Lorenz

This code is to produce all figures and results in the paper "Neural Networks as Geometric Chaotic Maps", 
submitted to IEEE Transactions of Neural Networks and Learning Systems. The current version of the paper 
is available at https://arxiv.org/abs/1912.05081v3

## Paper abstract

The use of artificial neural networks as models of chaotic dynamics has been rapidly expanding, but the 
theoretical understanding of how neural networks learn chaos remains lacking. Here, we employ a geometric 
perspective to show that neural networks can efficaciously model chaotic dynamics by themselves becoming 
structurally chaotic. First, we confirm the efficacy of neural networks in emulating chaos by showing that 
parsimonious neural networks trained only on few data points suffice to reconstruct strange attractors, 
extrapolate outside training data boundaries, and accurately predict local divergence rates. Second, we show 
that the trained network’s map comprises a series of geometric stretching, rotation, and compression 
operations. These geometric operations indicate topological mixing and chaos, explaining why neural networks 
are naturally suitable to emulate chaotic dynamics.

## Results

The code performs the generation of training data, training neural networks on different basis functions 
from scratch. It may take 1.5 hours to perform the whole computation. The produced analyses and figures 
showcase the efficacy of traditional feedforward neural networks in modeling chaotic dynamics. It further 
uses the example of the Hénon map to illustrate the geometric property of the neural network, proving the 
structural similarity between neural networks and dissipative chaotic maps.

## Usage

Open a Matlab prompt in the root directory, and run the following code in Matlab's window: 

    run
    
Or call Matlab directly from command line:

    matlab -r "addpath(genpath('.')); run"

## License

This code is distributed under the [MIT](http://opensource.org/licenses/mit-license.php) license

