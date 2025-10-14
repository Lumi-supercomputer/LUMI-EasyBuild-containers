# Alphafold license information

The Alphafold license is different for different versions, and the full Alphafold is actually covered
by two licenses: One for the source code and one for the model parameters.

-   The Alphafold 2 source code is licensed under the Apache 2.0 license which can be found in the
    [Alphafold GitHub repository LICENSE file](https://github.com/google-deepmind/alphafold/blob/main/LICENSE).

-   The Aphafold 2 parameters and CASP15 prediction data are made available under the terms of the
    [CC BY 4.0 license](https://creativecommons.org/licenses/by/4.0/).
    See also the ["Model parameters" section in the README in the Alphafold GitHub](https://github.com/google-deepmind/alphafold?tab=readme-ov-file#model-parameters)


!!! Warning "Alphafold 3 severe license restrictions"
    
    See also the ["License and Disclaimer" section in the Alphafold 3 GitHub README](https://github.com/google-deepmind/alphafold3?tab=readme-ov-file#licence-and-disclaimer).

    -   The AlphaFold 3 source code is licensed under the 
        [Creative Commons Attribution-Non-Commercial ShareAlike International License, Version 4.0 (CC-BY-NC-SA 4.0)](https://creativecommons.org/licenses/by-nc-sa/4.0/).
        A copy is available in the [LICENSE file in the Alphafold 3 GitHub repository](https://github.com/google-deepmind/alphafold3/blob/main/LICENSE).

        This license is more restrictive than the one for Alphafold 2 source code as it forbids all use for commercial purposes,
        with a notoriously vague definition of "commercial use" leaving a lot of room for interpretation in court.

    -   The Alphafold 3 model parameters are covered by an even more restrictive license specified in the 
        [file `WEIGHTS_TERMS_OF_USE.md` in the Alphafold 3 GitHub repository](https://github.com/google-deepmind/alphafold3/blob/main/WEIGHTS_TERMS_OF_USE.md).

    The license especially for the model parameters is very restrictive 
    so we cannot offer Alphafold 3 as a pre-built container on LUMI with the model 
    parameters as that would be publishing and violate point 3 of the "key things to know". Moreover, both CSC,
    the operator of LUMI, and AMD, who has been helping us with setting up containers for ROCm(tm), are commercial
    organisations and should not touch these files. So we cannot really offer any help with setting up
    Alphafold 3.

    Note that it is the responsibility of each user to strictly follow the terms of the license.
