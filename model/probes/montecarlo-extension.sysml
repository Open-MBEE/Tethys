// OpenSysML's Monte Carlo form of TethysMonteCarlo: Simulation::MonteCarlo cases run with
// `-runs <n> -seed <s>`, the target case drawn by a Stochastic::Probability-weighted decision
// and the continuous inputs by RandomFunctions. Loaded after model/*.sysml; kept out of
// model/ because `make pilot` gives the pilot validator no OpenSysML library.
package TethysMonteCarloExtension {
    private import ScalarValues::*;
    private import ISQ::*;
    private import SI::*;
    private import Simulation::*;
    private import Stochastic::*;
    private import RandomFunctions::*;
    private import TethysEnvironment::*;
    private import TethysTug::*;
    private import TethysAnalyses::*;
    private import TethysMonteCarlo::*;

    action def DrawTargetCase {
        doc /* One target case per run, weighted by the pre-arrival belief: small 25 %, nominal
             * 50 %, large 25 %. */
        out bodyMassKg : Real;
        action small assign bodyMassKg := smallTarget.mass / 1 [kg];
        action nominal assign bodyMassKg := nominalTarget.mass / 1 [kg];
        action large assign bodyMassKg := largeTarget.mass / 1 [kg];
        first start; then decide pick;
        then small { @Probability { p = 0.25; } }
        then nominal { @Probability { p = 0.50; } }
        then large { @Probability { p = 0.25; } }
        first small then done; first nominal then done; first large then done;
    }

    analysis def ReturnOverTargetCases :> MonteCarlo {
        doc /* The return Δv over the weighted target cases; outOfSpec counts the runs whose
             * return objective fails. */
        subject :>> analysed : Tug;
        action draw : DrawTargetCase;
        analysis dispersion : ReturnDispersion {
            subject :>> tug = analysed;
            in bodyMassKg = draw.bodyMassKg;
        }
        attribute :>> observed = dispersion.returnDeltaVMPerS;
        objective canReturn : ReturnCapability {
            subject :>> tug = analysed;
            in returnDeltaVMPerS = dispersion.returnDeltaVMPerS;
            in requiredReturnDeltaVMPerS = 350.0;
            in totalThrustDays = dispersion.totalThrustDays;
            in thrustDayAllowance = 1930.0;
        }
    }
    analysis returnOverTargetCases : ReturnOverTargetCases { subject :>> analysed = argent; }

    analysis def ReturnOverContinuousMass :> MonteCarlo {
        doc /* The return Δv with the body mass drawn from a triangular distribution over the
             * small–nominal–large range; `-draws min` and `-draws max` give the corners. */
        subject :>> analysed : Tug;
        attribute bodyMassKg : Real = triangular(smallTarget.mass / 1 [kg], nominalTarget.mass / 1 [kg], largeTarget.mass / 1 [kg]);
        analysis dispersion : ReturnDispersion {
            subject :>> tug = analysed;
            in bodyMassKg = bodyMassKg;
        }
        attribute :>> observed = dispersion.returnDeltaVMPerS;
        objective canReturn : ReturnCapability {
            subject :>> tug = analysed;
            in returnDeltaVMPerS = dispersion.returnDeltaVMPerS;
            in requiredReturnDeltaVMPerS = 350.0;
            in totalThrustDays = dispersion.totalThrustDays;
            in thrustDayAllowance = 1930.0;
        }
    }
    analysis returnOverContinuousMass : ReturnOverContinuousMass { subject :>> analysed = argent; }
}
