# GPS-signal-generation-and-acquisition
## Introduction
1. GPS C/A generation.
2. Conventional time-frequency space search method: test on received signal and sampled signal.

## Usage
IncomingIF: experimental received signal. (duration: 1s)
CA_generator: generate C/A code sequence for any PRN number from 1 to 32.
SampledCA: generate the sampled C/A code sequence.
ShiftedSampledCA: generate the sampled C/A code sequence with code delay. 
signal_generation: generate C/A code and calculate correaltion function.
singal_acuquisition: implement time-frequency space search method on received signal and sampled signal to acquire GPS signal.
